import 'package:flutter/painting.dart';

import '../../constants/storage_keys.dart';
import '../../database/app_database.dart';
import '../shared_preference/app_shared_preferences.dart';

class UserDataCleanupService {
  UserDataCleanupService({AppSharedPreferences? storage})
    : _storage = storage ?? AppSharedPreferences();

  final AppSharedPreferences _storage;

  static const List<String> userScopedStorageKeys = <String>[
    StorageKeys.authSession,
    StorageKeys.accessToken,
    StorageKeys.refreshToken,
    StorageKeys.currentUser,
    StorageKeys.searchHistory,
    StorageKeys.draftPosts,
    StorageKeys.cachedFeed,
    StorageKeys.localCreatedPosts,
    StorageKeys.localStories,
    StorageKeys.seenStoryIds,
    StorageKeys.cachedProfile,
    StorageKeys.offlineQueue,
    StorageKeys.feedScrollOffset,
    StorageKeys.settingsState,
    StorageKeys.followState,
    StorageKeys.bookmarks,
    StorageKeys.savedCollections,
    StorageKeys.uploadTasks,
    StorageKeys.callHistory,
    StorageKeys.groupChats,
    StorageKeys.activeAccountId,
    StorageKeys.linkedAccounts,
    StorageKeys.verificationRequest,
    StorageKeys.blockedAccounts,
    StorageKeys.mutedAccounts,
    StorageKeys.mutedGroups,
    StorageKeys.activeSessions,
    StorageKeys.loginHistory,
    StorageKeys.recommendationPreferences,
    StorageKeys.notePreferences,
    StorageKeys.postCreationSettings,
    StorageKeys.chatPreferences,
    StorageKeys.dataExportRequests,
    StorageKeys.hiddenWords,
    StorageKeys.contentSafetySettings,
    StorageKeys.activeSubscriptionPlan,
  ];

  Future<void> clearUserData() async {
    await Future.wait<void>(
      userScopedStorageKeys.map(_storage.remove),
      eagerError: false,
    );
    try {
      await AppDatabase.instance.clearTable('communities_cache');
    } catch (_) {}
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}
