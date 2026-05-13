import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/socket/socket_handler.dart';
import '../../../core/socket/socket_service.dart';
import '../../auth/repository/auth_repository.dart';
import '../model/call_item_model.dart';
import '../repository/calls_repository.dart';

class CallSessionController extends ChangeNotifier {
  CallSessionController({
    required this.displayName,
    required this.avatarUrl,
    required this.mode,
    this.recipientId,
    this.sessionId,
    this.connectedAt,
    CallsRepository? callsRepository,
    AuthRepository? authRepository,
    SocketService? socketService,
  }) : _callsRepository = callsRepository ?? CallsRepository(),
       _authRepository = authRepository ?? AuthRepository(),
       _socketService = socketService ?? SocketService.instance;

  final CallsRepository _callsRepository;
  final AuthRepository _authRepository;
  final SocketService _socketService;

  final String displayName;
  final String avatarUrl;
  final CallType mode;
  final String? recipientId;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  String? sessionId;
  DateTime? connectedAt;
  String callState = 'connecting';
  bool isInitializing = true;
  bool isEnding = false;
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isCameraOff = false;
  bool isFrontCamera = true;
  bool isRemoteMuted = false;
  bool isRemoteCameraOff = false;
  String? errorMessage;
  bool _disposed = false;
  bool _joiningSession = false;
  bool _offerCreated = false;
  bool _connectedNotified = false;

  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCPeerConnection? _peerConnection;
  StreamSubscription<SocketEnvelope>? _callSubscription;
  Timer? _ticker;
  int elapsedSeconds = 0;

  bool get isVideoCall => mode == CallType.video;
  String get statusLabel {
    if ((errorMessage ?? '').trim().isNotEmpty) {
      return errorMessage!.trim();
    }
    if (isInitializing) {
      return 'Connecting...';
    }
    switch (callState.toLowerCase()) {
      case 'connected':
      case 'ongoing':
      case 'answered':
        return isVideoCall ? 'Video call' : 'In audio call';
      case 'failed':
        return 'Call failed';
      case 'ended':
        return 'Call ended';
      case 'ringing':
        return 'Ringing...';
      default:
        return 'Calling...';
    }
  }

  String get durationLabel {
    final String minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final String seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> initialize() async {
    try {
      if (isVideoCall) {
        await localRenderer.initialize();
        await remoteRenderer.initialize();
      }
      await _authRepository.currentUser();
      await _socketService.connect();
      _callSubscription = _socketService.callEvents.listen(_handleCallEvent);

      if ((sessionId ?? '').trim().isEmpty) {
        final session = await _callsRepository.startCallSession(
          recipientId: (recipientId ?? '').trim().isNotEmpty
              ? recipientId!.trim()
              : displayName.trim(),
          type: mode,
        );
        sessionId = session.sessionId;
        connectedAt = session.startedAt;
        callState = session.state;
      } else {
        final session = await _callsRepository.getSession(sessionId!.trim());
        sessionId = session.sessionId;
        connectedAt = session.startedAt ?? connectedAt;
        callState = session.state;
      }

      await _callsRepository.joinCallSession(sessionId!);
      await _socketService.send('call.join', data: <String, dynamic>{
        'sessionId': sessionId,
      });

      await _initializePeerConnection();
      await _createLocalMedia();
      await _createOfferIfNeeded();
      isInitializing = false;
      _notify();
    } on MissingPluginException {
      _failInitialization(
        isVideoCall
            ? 'Video calling is not available on this platform.'
            : 'Calling is not available on this platform.',
      );
    } catch (_) {
      _failInitialization('Unable to start the call right now.');
    }
  }

  Future<void> toggleMute() async {
    isMuted = !isMuted;
    for (final MediaStreamTrack track in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !isMuted;
    }
    await _sendControlSignal(<String, dynamic>{
      'control': 'mute',
      'muted': isMuted,
    });
    _notify();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;
    try {
      await Helper.setSpeakerphoneOn(isSpeakerOn);
    } catch (_) {}
    _notify();
  }

  Future<void> toggleCamera() async {
    if (!isVideoCall) {
      return;
    }
    isCameraOff = !isCameraOff;
    for (final MediaStreamTrack track in _localStream?.getVideoTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !isCameraOff;
    }
    await _sendControlSignal(<String, dynamic>{
      'control': 'camera',
      'cameraOff': isCameraOff,
    });
    _notify();
  }

  Future<void> switchCamera() async {
    if (!hasLocalVideo) {
      return;
    }
    final List<MediaStreamTrack> tracks =
        _localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    final MediaStreamTrack? track = tracks.isEmpty ? null : tracks.first;
    if (track == null) {
      return;
    }
    try {
      await Helper.switchCamera(track);
      isFrontCamera = !isFrontCamera;
      _notify();
    } catch (_) {}
  }

  bool get hasLocalVideo =>
      (_localStream?.getVideoTracks().isNotEmpty ?? false) &&
      localRenderer.srcObject != null;

  Future<void> enableVideoIfNeeded() async {
    if (hasLocalVideo) {
      return;
    }
    final MediaStream media = await navigator.mediaDevices.getUserMedia(
      <String, dynamic>{
        'audio': false,
        'video': <String, dynamic>{
          'facingMode': 'user',
          'width': 1280,
          'height': 720,
          'frameRate': 24,
        },
      },
    );
    final MediaStreamTrack? track =
        media.getVideoTracks().isEmpty ? null : media.getVideoTracks().first;
    if (track == null) {
      return;
    }
    _localStream ??= await createLocalMediaStream('local_call_stream');
    await _localStream!.addTrack(track);
    localRenderer.srcObject = _localStream;
    await _peerConnection?.addTrack(track, _localStream!);
    isCameraOff = false;
    await _createRenegotiationOffer();
    _notify();
  }

  Future<void> endCall() async {
    if (isEnding) {
      return;
    }
    isEnding = true;
    _notify();
    final String? activeSessionId = sessionId;
    try {
      if ((activeSessionId ?? '').trim().isNotEmpty) {
        await _socketService.send('call.end', data: <String, dynamic>{
          'sessionId': activeSessionId,
          'reason': 'completed',
        });
        await _callsRepository.endCallSession(activeSessionId!);
      }
    } catch (_) {
      // Keep the exit path resilient.
    }
  }

  Future<void> leaveCall() async {
    final String? activeSessionId = sessionId;
    if ((activeSessionId ?? '').trim().isEmpty) {
      return;
    }
    try {
      await _socketService.send('call.leave', data: <String, dynamic>{
        'sessionId': activeSessionId,
      });
      await _callsRepository.leaveCallSession(activeSessionId!);
    } catch (_) {}
  }

  Future<void> _initializePeerConnection() async {
    final Map<String, dynamic> rtcConfig = await _callsRepository.fetchRtcConfig();
    _peerConnection = await createPeerConnection(rtcConfig);
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate == null || (sessionId ?? '').trim().isEmpty) {
        return;
      }
      unawaited(
        _socketService.send('call.signal', data: <String, dynamic>{
          'sessionId': sessionId,
          if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
          'type': 'ice-candidate',
          'payload': <String, dynamic>{
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        }),
      );
    };
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _markConnected();
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        callState = 'ended';
        _notify();
      }
    };
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        remoteRenderer.srcObject = _remoteStream;
      }
      isRemoteMuted = event.track.kind == 'audio' ? !event.track.enabled : isRemoteMuted;
      isRemoteCameraOff =
          event.track.kind == 'video' ? !event.track.enabled : isRemoteCameraOff;
      _markConnected();
      _notify();
    };
  }

  Future<void> _createLocalMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': isVideoCall
          ? <String, dynamic>{
              'facingMode': 'user',
              'width': 1280,
              'height': 720,
              'frameRate': 24,
            }
          : false,
    });
    localRenderer.srcObject = _localStream;
    for (final MediaStreamTrack track in _localStream!.getTracks()) {
      await _peerConnection?.addTrack(track, _localStream!);
    }
    if (!isVideoCall) {
      try {
        await Helper.setSpeakerphoneOn(false);
      } catch (_) {}
    }
  }

  Future<void> _createOfferIfNeeded() async {
    if (_offerCreated || _peerConnection == null) {
      return;
    }
    final RTCSessionDescription offer = await _peerConnection!.createOffer(
      <String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideoCall,
      },
    );
    await _peerConnection!.setLocalDescription(offer);
    _offerCreated = true;
    await _socketService.send('call.signal', data: <String, dynamic>{
      'sessionId': sessionId,
      if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
      'type': 'offer',
      'payload': <String, dynamic>{
        'sdp': offer.sdp,
        'type': offer.type,
      },
    });
  }

  Future<void> _createRenegotiationOffer() async {
    if (_peerConnection == null || (sessionId ?? '').trim().isEmpty) {
      return;
    }
    final RTCSessionDescription offer = await _peerConnection!.createOffer(
      <String, dynamic>{
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      },
    );
    await _peerConnection!.setLocalDescription(offer);
    await _socketService.send('call.signal', data: <String, dynamic>{
      'sessionId': sessionId,
      if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
      'type': 'renegotiate',
      'payload': <String, dynamic>{
        'control': 'video-upgrade',
        'sdp': offer.sdp,
        'type': offer.type,
      },
    });
  }

  Future<void> _handleCallEvent(SocketEnvelope envelope) async {
    if (_disposed) {
      return;
    }
    final String activeSessionId = (sessionId ?? '').trim();
    if (activeSessionId.isEmpty) {
      return;
    }
    final String incomingSessionId = _readString(
      envelope.data['sessionId'] ?? envelope.data['id'],
    );
    if (incomingSessionId.isNotEmpty && incomingSessionId != activeSessionId) {
      return;
    }

    switch (envelope.event) {
      case 'call.session.created':
        if (callState == 'connecting') {
          callState = 'ringing';
          _notify();
        }
        return;
      case 'call.participant.joined':
        _markConnected();
        return;
      case 'call.participant.left':
        callState = 'ended';
        _notify();
        return;
      case 'call.ended':
        callState = 'ended';
        _notify();
        return;
      case 'call.signal':
        await _handleSignal(envelope.data);
        return;
    }
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final String type = _readString(data['type']);
    final Map<String, dynamic> payload = _readMap(data['payload']);
    if (type.isEmpty || payload.isEmpty || _peerConnection == null) {
      return;
    }

    switch (type) {
      case 'offer':
        if (_joiningSession) {
          return;
        }
        _joiningSession = true;
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            _readString(payload['sdp']),
            _readString(payload['type'], fallback: 'offer'),
          ),
        );
        final RTCSessionDescription answer = await _peerConnection!.createAnswer(
          <String, dynamic>{
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': isVideoCall,
          },
        );
        await _peerConnection!.setLocalDescription(answer);
        await _socketService.send('call.signal', data: <String, dynamic>{
          'sessionId': sessionId,
          'type': 'answer',
          'payload': <String, dynamic>{
            'sdp': answer.sdp,
            'type': answer.type,
          },
        });
        _joiningSession = false;
        callState = 'connected';
        _markConnected();
        return;
      case 'answer':
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            _readString(payload['sdp']),
            _readString(payload['type'], fallback: 'answer'),
          ),
        );
        callState = 'connected';
        _markConnected();
        return;
      case 'ice-candidate':
        final String candidate = _readString(payload['candidate']);
        if (candidate.isEmpty) {
          return;
        }
        await _peerConnection!.addCandidate(
          RTCIceCandidate(
            candidate,
            _readString(payload['sdpMid']),
            _readInt(payload['sdpMLineIndex']),
          ),
        );
        return;
      default:
        final String control = _readString(payload['control']);
        if (control == 'video-upgrade') {
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(
              _readString(payload['sdp']),
              _readString(payload['type'], fallback: 'offer'),
            ),
          );
          final RTCSessionDescription answer = await _peerConnection!.createAnswer(
            <String, dynamic>{
              'offerToReceiveAudio': true,
              'offerToReceiveVideo': true,
            },
          );
          await _peerConnection!.setLocalDescription(answer);
          await _socketService.send('call.signal', data: <String, dynamic>{
            'sessionId': sessionId,
            'type': 'answer',
            'payload': <String, dynamic>{
              'sdp': answer.sdp,
              'type': answer.type,
            },
          });
        } else if (control == 'mute') {
          isRemoteMuted = _readBool(payload['muted']);
          _notify();
        } else if (control == 'camera') {
          isRemoteCameraOff = _readBool(payload['cameraOff']);
          _notify();
        }
    }
  }

  Future<void> _sendControlSignal(Map<String, dynamic> payload) async {
    if ((sessionId ?? '').trim().isEmpty) {
      return;
    }
    try {
      await _socketService.send('call.signal', data: <String, dynamic>{
        'sessionId': sessionId,
        if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
        'type': 'renegotiate',
        'payload': payload,
      });
    } catch (_) {}
  }

  void _markConnected() {
    if (_connectedNotified) {
      return;
    }
    _connectedNotified = true;
    callState = 'connected';
    connectedAt ??= DateTime.now();
    _ticker?.cancel();
    _updateElapsed();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
      _notify();
    });
    _notify();
  }

  void _updateElapsed() {
    final DateTime? value = connectedAt;
    if (value == null) {
      elapsedSeconds = 0;
      return;
    }
    elapsedSeconds = DateTime.now().difference(value).inSeconds;
  }

  String _readString(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }

  Map<String, dynamic> _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  void _notify() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  void _failInitialization(String message) {
    errorMessage = message;
    callState = 'failed';
    isInitializing = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    unawaited(_callSubscription?.cancel());
    unawaited(leaveCall());
    unawaited(_peerConnection?.close());
    unawaited(_localStream?.dispose());
    unawaited(_remoteStream?.dispose());
    unawaited(localRenderer.dispose());
    unawaited(remoteRenderer.dispose());
    super.dispose();
  }
}
