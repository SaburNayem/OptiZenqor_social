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

class CreatePostController extends ChangeNotifier {
  CreatePostController({
    MediaPickerService? mediaPickerService,
    ApiClientService? apiClient,
    AppSharedPreferences? storage,
  }) : _mediaPickerService = mediaPickerService ?? MediaPickerService(),
       _apiClient = apiClient ?? ApiClientService(),
       _storage = storage ?? AppSharedPreferences() {
    captionController.addListener(notifyListeners);
  }

  final MediaPickerService _mediaPickerService;
  final ApiClientService _apiClient;
  final AppSharedPreferences _storage;
  final TextEditingController captionController = TextEditingController();
  UserModel currentUser = const UserModel(
    id: '',
    name: 'Guest',
    username: 'guest',
    avatar: 'https://placehold.co/120x120',
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
    final Map<String, dynamic>? sessionUser = _readMap(session?['user']);
    if (sessionUser != null && sessionUser.isNotEmpty) {
      final UserModel resolved = UserModel.fromApiJson(sessionUser);
      if (resolved.id.isNotEmpty) {
        currentUser = resolved;
      }
    }

    try {
      final response = await _apiClient.get(ApiEndPoints.users);
      if (response.isSuccess && response.data['success'] != false) {
        availableUsers = ApiPayloadReader.readMapList(
          response.data,
          preferredKeys: const <String>['users', 'items', 'results'],
        ).map(UserModel.fromApiJson).where((UserModel item) => item.id.isNotEmpty).toList(growable: false);
      }
    } catch (_) {}
    notifyListeners();
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
    mediaPaths = paths;
    isVideo = paths.length == 1 && CreatePostSheetHelper.isVideoPath(paths.first);
    altText = null;
    notifyListeners();
  }

  Future<void> capturePhoto() async {
    final String? path = await _mediaPickerService.captureImage();
    if (path == null) {
      return;
    }
    mediaPaths = <String>[path];
    isVideo = false;
    altText = null;
    notifyListeners();
  }

  Future<void> pickVideo() async {
    final String? path = await _mediaPickerService.pickVideo();
    if (path == null) {
      return;
    }
    mediaPaths = <String>[path];
    isVideo = true;
    altText = null;
    notifyListeners();
  }

  void clearMedia() {
    mediaPaths = <String>[];
    isVideo = false;
    altText = null;
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  CreatePostResult buildResult() {
    return CreatePostResult(
      caption: captionController.text.trim(),
      mediaPaths: mediaPaths,
      isVideo: isVideo,
      audience: audience,
      location: location,
      taggedPeople: taggedPeople,
      coAuthors: coAuthors,
      altText: altText,
      editHistory: feeling == null ? const <String>[] : <String>['Feeling: $feeling'],
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
    captionController
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
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
