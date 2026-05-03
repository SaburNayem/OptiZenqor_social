import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/api_client_service.dart';
import '../../../core/data/service/media_picker_service.dart';
import '../../../core/data/shared_preference/app_shared_preferences.dart';
import '../../../core/enums/user_role.dart';
import '../../live_stream/model/live_stream_model.dart';
import '../helper/create_post_sheet_helper.dart';
import '../model/create_post_result_model.dart';
import '../service/post_media_optimizer.dart';

class CreatePostController extends ChangeNotifier {
  CreatePostController({
    MediaPickerService? mediaPickerService,
    ApiClientService? apiClient,
    AppSharedPreferences? storage,
    PostMediaOptimizer? postMediaOptimizer,
  }) : _mediaPickerService = mediaPickerService ?? MediaPickerService(),
       _apiClient = apiClient ?? ApiClientService(),
       _storage = storage ?? AppSharedPreferences(),
       _postMediaOptimizer = postMediaOptimizer ?? const PostMediaOptimizer() {
    captionController.addListener(notifyListeners);
  }

  final MediaPickerService _mediaPickerService;
  final ApiClientService _apiClient;
  final AppSharedPreferences _storage;
  final PostMediaOptimizer _postMediaOptimizer;
  final TextEditingController captionController = TextEditingController();
  bool _isDisposed = false;
  UserModel currentUser = const UserModel(
    id: '',
    name: '',
    username: '',
    avatar: '',
    bio: '',
    role: UserRole.guest,
    followers: 0,
    following: 0,
  );
  List<UserModel> availableUsers = <UserModel>[];

  List<String> mediaPaths = <String>[];
  bool isVideo = false;
  String audience = 'Everyone';
  String? location;
  String? feeling;
  String? altText;
  List<String> taggedPeople = <String>[];
  List<String> coAuthors = <String>[];

  bool get canShare =>
      captionController.text.trim().isNotEmpty || mediaPaths.isNotEmpty;

  bool get hasAnyVideo => mediaPaths.any(CreatePostSheetHelper.isVideoPath);

  Future<void> loadContext() async {
    final Map<String, dynamic>? session = await _storage.readJson(
      StorageKeys.authSession,
    );
    if (_isDisposed) {
      return;
    }
    final Map<String, dynamic>? sessionUser = _readMap(session?['user']);
    if (sessionUser != null && sessionUser.isNotEmpty) {
      final UserModel resolved = UserModel.fromApiJson(sessionUser);
      if (resolved.id.isNotEmpty) {
        currentUser = resolved;
      }
    }

    try {
      final response = await _apiClient.get(ApiEndPoints.users);
      if (_isDisposed) {
        return;
      }
      if (response.isSuccess && response.data['success'] != false) {
        availableUsers =
            ApiPayloadReader.readMapList(
                  response.data,
                  preferredKeys: const <String>['users', 'items', 'results'],
                )
                .map(UserModel.fromApiJson)
                .where((UserModel item) => item.id.isNotEmpty)
                .toList(growable: false);
      }
    } catch (_) {}
    _safeNotifyListeners();
  }

  Future<void> showMediaPickerSheet(BuildContext context) async {
    final CreatePostMediaSheetAction? action =
        await CreatePostSheetHelper.showMediaPickerSheet(context);
    switch (action) {
      case CreatePostMediaSheetAction.chooseMedia:
        await pickMediaFiles();
        return;
      case CreatePostMediaSheetAction.chooseVideo:
        await pickVideo();
        return;
      case CreatePostMediaSheetAction.capturePhoto:
        await capturePhoto();
        return;
      case null:
        return;
    }
  }

  Future<void> pickMediaFiles() async {
    final List<String> paths = await _mediaPickerService.pickPostMedia();
    if (paths.isEmpty) {
      return;
    }
    await _setOptimizedMedia(paths);
  }

  Future<void> capturePhoto() async {
    final String? path = await _mediaPickerService.captureImage();
    if (path == null) {
      return;
    }
    await _setOptimizedMedia(<String>[path]);
  }

  Future<void> pickVideo() async {
    final String? path = await _mediaPickerService.pickVideo();
    if (path == null) {
      return;
    }
    await _setOptimizedMedia(<String>[path]);
  }

  void clearMedia() {
    mediaPaths = <String>[];
    isVideo = false;
    altText = null;
    _safeNotifyListeners();
  }

  Future<void> pickFeeling(BuildContext context) async {
    final String? value = await CreatePostSheetHelper.showSimpleOptionSheet(
      context: context,
      title: 'Choose feeling',
      options: CreatePostSheetHelper.feelingOptions,
    );
    if (value == null) {
      return;
    }
    feeling = value;
    _safeNotifyListeners();
  }

  Future<void> pickLocation(BuildContext context) async {
    final String? result = await CreatePostSheetHelper.showTextInputDialog(
      context: context,
      title: 'Add location',
      hintText: 'Enter location',
      initialValue: location ?? '',
    );
    if (result == null) {
      return;
    }
    location = result.isEmpty ? null : result;
    _safeNotifyListeners();
  }

  Future<void> pickTaggedPeople(BuildContext context) async {
    final List<String> options = availableUsers
        .where((UserModel item) => item.username.trim().isNotEmpty)
        .map((UserModel item) => '@${item.username}')
        .toList(growable: false);
    if (options.isEmpty) {
      return;
    }
    final String? result = await CreatePostSheetHelper.showSimpleOptionSheet(
      context: context,
      title: 'Tag people',
      options: options,
    );
    if (result == null || taggedPeople.contains(result)) {
      return;
    }
    taggedPeople = <String>[...taggedPeople, result];
    _safeNotifyListeners();
  }

  Future<void> pickCoAuthors(BuildContext context) async {
    final List<String> options = availableUsers
        .where((UserModel item) => item.id != currentUser.id)
        .where((UserModel item) => item.username.trim().isNotEmpty)
        .map((UserModel item) => '@${item.username}')
        .toList(growable: false);
    if (options.isEmpty) {
      return;
    }
    final String? result = await CreatePostSheetHelper.showSimpleOptionSheet(
      context: context,
      title: 'Add collaborator',
      options: options,
    );
    if (result == null || coAuthors.contains(result)) {
      return;
    }
    coAuthors = <String>[...coAuthors, result];
    _safeNotifyListeners();
  }

  Future<void> editAltText(BuildContext context) async {
    final String? result = await CreatePostSheetHelper.showTextInputDialog(
      context: context,
      title: 'Add alt text',
      hintText: 'Describe this image for accessibility',
      initialValue: altText ?? '',
      maxLines: 3,
    );
    if (result == null) {
      return;
    }
    altText = result.isEmpty ? null : result;
    _safeNotifyListeners();
  }

  Future<void> pickPrivacy(BuildContext context) async {
    final String? result = await CreatePostSheetHelper.showSimpleOptionSheet(
      context: context,
      title: 'Choose privacy',
      options: CreatePostSheetHelper.privacyOptions,
    );
    if (result == null) {
      return;
    }
    audience = result;
    _safeNotifyListeners();
  }

  CreatePostResult buildResult() {
    final Map<String, UserModel> availableByUsername = <String, UserModel>{
      for (final UserModel item in availableUsers)
        item.username.trim().toLowerCase(): item,
    };
    final List<String> resolvedTaggedUserIds = taggedPeople
        .map((String item) => item.replaceFirst('@', '').trim().toLowerCase())
        .map((String username) => availableByUsername[username]?.id ?? '')
        .where((String id) => id.isNotEmpty)
        .toList(growable: false);
    final List<String> resolvedMentionUsernames = coAuthors
        .map((String item) => item.replaceFirst('@', '').trim())
        .where((String username) => username.isNotEmpty)
        .toList(growable: false);

    return CreatePostResult(
      caption: captionController.text.trim(),
      mediaPaths: mediaPaths,
      isVideo: isVideo,
      audience: audience,
      location: location,
      taggedPeople: taggedPeople,
      taggedUserIds: resolvedTaggedUserIds,
      coAuthors: coAuthors,
      mentionUsernames: resolvedMentionUsernames,
      altText: altText,
      editHistory: feeling == null
          ? const <String>[]
          : <String>['Feeling: $feeling'],
      feeling: feeling,
    );
  }

  String liveTitleFor(String userName) {
    final String liveTitle = captionController.text.trim();
    return liveTitle.isEmpty ? '$userName is going live' : liveTitle;
  }

  LiveAudienceVisibility get liveAudienceVisibility {
    switch (audience) {
      case 'Followers':
      case 'Close Friends':
        return LiveAudienceVisibility.friends;
      default:
        return LiveAudienceVisibility.public;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    captionController
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  Future<void> _setOptimizedMedia(List<String> paths) async {
    final List<String> optimizedPaths = await _postMediaOptimizer.optimizePaths(
      paths,
    );
    mediaPaths = optimizedPaths;
    isVideo =
        optimizedPaths.length == 1 &&
        CreatePostSheetHelper.isVideoPath(optimizedPaths.first);
    altText = null;
    _safeNotifyListeners();
  }

  Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
