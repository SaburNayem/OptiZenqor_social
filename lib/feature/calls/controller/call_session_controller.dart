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
  }) : isSpeakerOn = mode == CallType.video,
       _videoEnabled = mode == CallType.video,
       _callsRepository = callsRepository ?? CallsRepository(),
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
  bool isSpeakerOn;
  bool isCameraOff = false;
  bool isFrontCamera = true;
  bool isRemoteMuted = false;
  bool isRemoteCameraOff = false;
  String? errorMessage;
  bool _videoEnabled;
  bool _disposed = false;
  bool _joiningSession = false;
  bool _offerCreated = false;
  bool _connectedNotified = false;
  bool _videoRenderersInitialized = false;

  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCPeerConnection? _peerConnection;
  RTCRtpSender? _localVideoSender;
  StreamSubscription<SocketEnvelope>? _callSubscription;
  Future<void>? _initializeFuture;
  Future<void>? _videoEnableFuture;
  Future<void>? _videoRendererInitialization;
  Timer? _ticker;
  int elapsedSeconds = 0;

  bool get isVideoCall => _videoEnabled;
  bool get hasRemoteVideo =>
      (_remoteStream?.getVideoTracks().isNotEmpty ?? false) &&
      remoteRenderer.srcObject != null;

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

  Future<void> initialize() {
    _initializeFuture ??= _initialize();
    return _initializeFuture!;
  }

  Future<void> _initialize() async {
    try {
      await _ensureVideoRenderersInitialized();
      await _authRepository.currentUser();
      final bool socketConnected = await _socketService.connect(force: true);
      debugPrint(
        '[CallSessionController] socket connect result=$socketConnected state=${_socketService.state}',
      );
      if (!socketConnected) {
        _failInitialization(
          'Realtime connection failed. Please check the signaling server.',
        );
        return;
      }
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
      await _socketService.send(
        'call.join',
        data: <String, dynamic>{'sessionId': sessionId},
      );

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
    } on PlatformException {
      _failInitialization(
        isVideoCall
            ? 'Camera or microphone permission is required for video calls.'
            : 'Microphone permission is required for audio calls.',
      );
    } catch (_) {
      _failInitialization('Unable to start the call right now.');
    }
  }

  Future<void> toggleMute() async {
    isMuted = !isMuted;
    for (final MediaStreamTrack track
        in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
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
    await _applyAudioRoute();
    _notify();
  }

  Future<void> toggleCamera() async {
    if (!isVideoCall && !hasLocalVideo) {
      return;
    }
    if (_localStream?.getVideoTracks().isEmpty ?? true) {
      await enableVideoIfNeeded();
      return;
    }
    isCameraOff = !isCameraOff;
    for (final MediaStreamTrack track
        in _localStream?.getVideoTracks() ?? <MediaStreamTrack>[]) {
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
      await enableVideoIfNeeded();
    }
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
      if (kIsWeb) {
        final List<MediaDeviceInfo> cameras = await Helper.cameras;
        if (cameras.length < 2 || _localStream == null) {
          return;
        }
        final String currentDeviceId = _readString(
          track.getSettings()['deviceId'],
        );
        final int currentIndex = cameras.indexWhere(
          (MediaDeviceInfo camera) => camera.deviceId == currentDeviceId,
        );
        final int nextIndex = currentIndex < 0
            ? (isFrontCamera ? 1 : 0)
            : (currentIndex + 1) % cameras.length;
        final MediaDeviceInfo nextCamera = cameras[nextIndex];
        await Helper.switchCamera(track, nextCamera.deviceId, _localStream);
        final MediaStreamTrack? newTrack =
            _localStream!.getVideoTracks().isEmpty
            ? null
            : _localStream!.getVideoTracks().first;
        if (newTrack != null) {
          await _sendLocalVideoTrack(newTrack);
        }
        final String label = nextCamera.label.toLowerCase();
        if (label.contains('front') || label.contains('user')) {
          isFrontCamera = true;
        } else if (label.contains('back') || label.contains('rear')) {
          isFrontCamera = false;
        } else {
          isFrontCamera = !isFrontCamera;
        }
      } else {
        await Helper.switchCamera(track);
        isFrontCamera = !isFrontCamera;
      }
      _notify();
    } catch (_) {}
  }

  bool get hasLocalVideo =>
      (_localStream?.getVideoTracks().isNotEmpty ?? false) &&
      localRenderer.srcObject != null;

  Future<void> enableVideoIfNeeded() {
    final Future<void>? pending = _videoEnableFuture;
    if (pending != null) {
      return pending;
    }
    final Future<void> operation = _enableVideoIfNeeded(
      renegotiate: true,
      waitForInitialization: true,
    );
    _videoEnableFuture = operation;
    return operation.whenComplete(() {
      if (identical(_videoEnableFuture, operation)) {
        _videoEnableFuture = null;
      }
    });
  }

  Future<void> _enableVideoIfNeeded({
    required bool renegotiate,
    required bool waitForInitialization,
  }) async {
    if (waitForInitialization) {
      final Future<void>? initializing = _initializeFuture;
      if (isInitializing && initializing != null) {
        await initializing;
      }
      if (_peerConnection == null) {
        errorMessage = 'Call is still connecting. Try video again in a moment.';
        _notify();
        return;
      }
    }
    try {
      await _ensureVideoRenderersInitialized();
      final List<MediaStreamTrack> existingTracks =
          _localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
      if (existingTracks.isNotEmpty) {
        for (final MediaStreamTrack track in existingTracks) {
          track.enabled = true;
        }
        localRenderer.srcObject = _localStream;
        _videoEnabled = true;
        isCameraOff = false;
        errorMessage = null;
        _notify();
        return;
      }

      final MediaStream media = await navigator.mediaDevices.getUserMedia(
        <String, dynamic>{
          'audio': false,
          'video': _videoConstraints(front: isFrontCamera),
        },
      );
      final MediaStreamTrack? track = media.getVideoTracks().isEmpty
          ? null
          : media.getVideoTracks().first;
      if (track == null) {
        return;
      }
      _localStream ??= await createLocalMediaStream('local_call_stream');
      await _localStream!.addTrack(track);
      localRenderer.srcObject = _localStream;
      await _sendLocalVideoTrack(track);
      _videoEnabled = true;
      isCameraOff = false;
      errorMessage = null;
      if (renegotiate) {
        await _createRenegotiationOffer();
      }
      _notify();
    } on MissingPluginException {
      errorMessage = 'Video calling is not available on this platform.';
      _notify();
    } on PlatformException {
      errorMessage = 'Camera permission is required for video calls.';
      _notify();
    } catch (_) {
      errorMessage = 'Unable to open the camera right now.';
      _notify();
    }
  }

  Future<void> disableVideo() async {
    final List<MediaStreamTrack> videoTracks = List<MediaStreamTrack>.from(
      _localStream?.getVideoTracks() ?? <MediaStreamTrack>[],
    );
    if (videoTracks.isEmpty && !_videoEnabled) {
      return;
    }
    try {
      await _localVideoSender?.replaceTrack(null);
      for (final MediaStreamTrack track in videoTracks) {
        track.enabled = false;
        await track.stop();
        await _localStream?.removeTrack(track);
      }
      localRenderer.srcObject = null;
      _videoEnabled = false;
      isCameraOff = true;
      await _sendControlSignal(<String, dynamic>{
        'control': 'camera',
        'cameraOff': true,
      });
      _notify();
    } catch (_) {}
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
        await _socketService.send(
          'call.end',
          data: <String, dynamic>{
            'sessionId': activeSessionId,
            'reason': 'completed',
          },
        );
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
      await _socketService.send(
        'call.leave',
        data: <String, dynamic>{'sessionId': activeSessionId},
      );
      await _callsRepository.leaveCallSession(activeSessionId!);
    } catch (_) {}
  }

  Future<void> _initializePeerConnection() async {
    final Map<String, dynamic> rtcConfig = await _callsRepository
        .fetchRtcConfig();
    _peerConnection = await createPeerConnection(rtcConfig);
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate == null || (sessionId ?? '').trim().isEmpty) {
        return;
      }
      unawaited(
        _socketService.send(
          'call.signal',
          data: <String, dynamic>{
            'sessionId': sessionId,
            if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
            'type': 'ice-candidate',
            'payload': <String, dynamic>{
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          },
        ),
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
    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      unawaited(_attachRemoteStream(stream));
      _markConnected();
    };
    _peerConnection!.onRemoveStream = (MediaStream stream) {
      if (identical(_remoteStream, stream)) {
        _remoteStream = null;
      }
      if (identical(remoteRenderer.srcObject, stream)) {
        remoteRenderer.srcObject = null;
      }
      _notify();
    };
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      unawaited(_handleRemoteTrack(event));
      isRemoteMuted = event.track.kind == 'audio'
          ? !event.track.enabled
          : isRemoteMuted;
      isRemoteCameraOff = event.track.kind == 'video'
          ? !event.track.enabled
          : isRemoteCameraOff;
      _markConnected();
      _notify();
    };
  }

  Future<void> _createLocalMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': isVideoCall ? _videoConstraints(front: isFrontCamera) : false,
    });
    if (_localStream!.getVideoTracks().isNotEmpty) {
      await _ensureVideoRenderersInitialized();
      localRenderer.srcObject = _localStream;
      _videoEnabled = true;
    }
    for (final MediaStreamTrack track in _localStream!.getTracks()) {
      final RTCRtpSender? sender = await _peerConnection?.addTrack(
        track,
        _localStream!,
      );
      if (track.kind == 'video') {
        _localVideoSender = sender;
      }
    }
    await _applyAudioRoute();
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
    await _socketService.send(
      'call.signal',
      data: <String, dynamic>{
        'sessionId': sessionId,
        if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
        'type': 'offer',
        'payload': <String, dynamic>{'sdp': offer.sdp, 'type': offer.type},
      },
    );
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
    await _socketService.send(
      'call.signal',
      data: <String, dynamic>{
        'sessionId': sessionId,
        if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
        'type': 'renegotiate',
        'payload': <String, dynamic>{
          'control': 'video-upgrade',
          'sdp': offer.sdp,
          'type': offer.type,
        },
      },
    );
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
        final bool remoteWantsVideo = _sdpIncludesVideo(payload);
        if (remoteWantsVideo) {
          _videoEnabled = true;
          await _ensureVideoRenderersInitialized();
        }
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(
            _readString(payload['sdp']),
            _readString(payload['type'], fallback: 'offer'),
          ),
        );
        if (remoteWantsVideo) {
          await _enableVideoIfNeeded(
            renegotiate: false,
            waitForInitialization: false,
          );
        }
        final RTCSessionDescription answer = await _peerConnection!
            .createAnswer(<String, dynamic>{
              'offerToReceiveAudio': true,
              'offerToReceiveVideo': isVideoCall || remoteWantsVideo,
            });
        await _peerConnection!.setLocalDescription(answer);
        await _socketService.send(
          'call.signal',
          data: <String, dynamic>{
            'sessionId': sessionId,
            'type': 'answer',
            'payload': <String, dynamic>{
              'sdp': answer.sdp,
              'type': answer.type,
            },
          },
        );
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
          _videoEnabled = true;
          await _ensureVideoRenderersInitialized();
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(
              _readString(payload['sdp']),
              _readString(payload['type'], fallback: 'offer'),
            ),
          );
          await _enableVideoIfNeeded(
            renegotiate: false,
            waitForInitialization: false,
          );
          final RTCSessionDescription answer = await _peerConnection!
              .createAnswer(<String, dynamic>{
                'offerToReceiveAudio': true,
                'offerToReceiveVideo': true,
              });
          await _peerConnection!.setLocalDescription(answer);
          await _socketService.send(
            'call.signal',
            data: <String, dynamic>{
              'sessionId': sessionId,
              'type': 'answer',
              'payload': <String, dynamic>{
                'sdp': answer.sdp,
                'type': answer.type,
              },
            },
          );
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
      await _socketService.send(
        'call.signal',
        data: <String, dynamic>{
          'sessionId': sessionId,
          if ((recipientId ?? '').trim().isNotEmpty) 'toUserId': recipientId,
          'type': 'renegotiate',
          'payload': payload,
        },
      );
    } catch (_) {}
  }

  Future<void> _ensureVideoRenderersInitialized() {
    if (_videoRenderersInitialized) {
      return Future<void>.value();
    }
    final Future<void>? pending = _videoRendererInitialization;
    if (pending != null) {
      return pending;
    }
    final Future<void> initialization =
        Future.wait<void>(<Future<void>>[
              localRenderer.initialize(),
              remoteRenderer.initialize(),
            ])
            .then((_) {
              _videoRenderersInitialized = true;
            })
            .whenComplete(() {
              _videoRendererInitialization = null;
            });
    _videoRendererInitialization = initialization;
    return initialization;
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    MediaStream? stream = event.streams.isNotEmpty
        ? event.streams.first
        : _remoteStream;
    if (stream == null) {
      stream = await createLocalMediaStream('remote_call_stream');
      _remoteStream = stream;
    }
    if (event.streams.isEmpty) {
      await stream.addTrack(event.track);
    }
    _remoteStream = stream;
    await _attachRemoteStream(stream);
  }

  Future<void> _attachRemoteStream(MediaStream stream) async {
    try {
      await _ensureVideoRenderersInitialized();
      if (_disposed) {
        return;
      }
      for (final MediaStreamTrack track in stream.getAudioTracks()) {
        track.enabled = true;
      }
      remoteRenderer.srcObject = stream;
      if (stream.getVideoTracks().isNotEmpty) {
        _videoEnabled = true;
      }
      await _applyAudioRoute();
      _notify();
    } catch (_) {}
  }

  Future<void> _applyAudioRoute() async {
    try {
      await Helper.setSpeakerphoneOn(isSpeakerOn);
    } catch (_) {}
  }

  Future<void> _sendLocalVideoTrack(MediaStreamTrack track) async {
    final RTCRtpSender? localVideoSender = _localVideoSender;
    if (localVideoSender != null) {
      await localVideoSender.replaceTrack(track);
      return;
    }
    final List<RTCRtpSender> senders =
        await _peerConnection?.getSenders() ?? <RTCRtpSender>[];
    for (final RTCRtpSender sender in senders) {
      if (sender.track?.kind == 'video') {
        _localVideoSender = sender;
        await sender.replaceTrack(track);
        return;
      }
    }
    if (_localStream != null) {
      _localVideoSender = await _peerConnection?.addTrack(track, _localStream!);
    }
  }

  Map<String, dynamic> _videoConstraints({required bool front}) {
    return <String, dynamic>{
      'facingMode': front ? 'user' : 'environment',
      'width': 1280,
      'height': 720,
      'frameRate': 24,
    };
  }

  bool _sdpIncludesVideo(Map<String, dynamic> payload) {
    final String sdp = _readString(payload['sdp']).toLowerCase();
    return sdp.contains('m=video');
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
    unawaited(_releaseCallResources());
    super.dispose();
  }

  Future<void> _releaseCallResources() async {
    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
      for (final MediaStreamTrack track
          in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
        await track.stop();
      }
      for (final MediaStreamTrack track
          in _remoteStream?.getTracks() ?? <MediaStreamTrack>[]) {
        await track.stop();
      }
      await _peerConnection?.close();
      await _localStream?.dispose();
      await _remoteStream?.dispose();
    } catch (_) {
      // Keep widget disposal resilient.
    } finally {
      await localRenderer.dispose();
      await remoteRenderer.dispose();
    }
  }
}
