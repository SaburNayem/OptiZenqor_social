import 'package:flutter/material.dart';

import '../core/data/models/message_model.dart';
import '../core/data/models/story_model.dart';
import '../core/data/models/user_model.dart';
import '../feature/auth/auth_feature_screens.dart';
import '../feature/calls/screen/audio_call_screen.dart';
import '../feature/calls/screen/video_call_screen.dart';
import '../feature/chat/screen/chat_detail_screen.dart';
import '../feature/feature_screens.dart';
import '../feature/media_viewer/model/media_viewer_item_model.dart';
import '../feature/media_viewer/model/media_viewer_route_arguments.dart';
import '../feature/settings/settings_feature_screens.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static const initialRoute = RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? RouteNames.splash);
    final String routeName = uri.path;
    final Map<String, String> params = uri.queryParameters;
    final Object? arguments = settings.arguments;

    final Widget page = _buildPage(routeName, params, arguments);

    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }

  static Widget _buildPage(
    String routeName,
    Map<String, String> params,
    Object? arguments,
  ) {
    final String? postDetailPathId = _postDetailPathId(routeName);
    if (postDetailPathId != null) {
      return PostDetailScreen(
        postId:
            _postIdFromArguments(arguments) ?? params['id'] ?? postDetailPathId,
      );
    }

    switch (routeName) {
      case RouteNames.splash:
        return SplashScreen();
      case RouteNames.login:
        return LoginScreen();
      case RouteNames.signup:
        return SignupScreen();
      case RouteNames.emailVerification:
        return EmailVerificationScreen(email: _emailFromArguments(arguments));
      case RouteNames.forgotPassword:
        return ForgotPasswordScreen(email: _emailFromArguments(arguments));
      case RouteNames.otpVerification:
        return OtpVerificationScreen(email: _emailFromArguments(arguments));
      case RouteNames.resetPassword:
        return ResetPasswordScreen(
          email: _emailFromArguments(arguments),
          otp: _otpFromArguments(arguments),
        );
      case RouteNames.accountSuspended:
        return AccountSuspendedScreen(user: _userFromArguments(arguments));
      case RouteNames.shell:
        return MainShellScreen(arguments: arguments);
      case RouteNames.searchDiscovery:
        return SearchDiscoveryScreen();
      case RouteNames.communities:
        return CommunitiesScreen();
      case RouteNames.marketplace:
        return MarketplaceScreen();
      case RouteNames.notifications:
        return NotificationsScreen();
      case RouteNames.creatorDashboard:
        return const CreatorDashboardScreen();
      case RouteNames.premium:
        return PremiumMembershipScreen();
      case RouteNames.paymentCheckout:
        return PaymentCheckoutScreen(arguments: arguments);
      case RouteNames.settings:
        return SettingsScreen();
      case RouteNames.accountSettings:
        return const AccountSettingsScreen();
      case RouteNames.passwordSecurity:
        return const PasswordSecurityScreen();
      case RouteNames.devicesSessions:
        return DevicesSessionsScreen();
      case RouteNames.blockedUsers:
        return BlockedUsersScreen();
      case RouteNames.archiveCenter:
        return const ArchiveCenterScreen();
      case RouteNames.privacySettings:
        return const PrivacySettingsScreen();
      case RouteNames.notificationsSettings:
        return const NotificationsSettingsScreen();
      case RouteNames.messagesCallsSettings:
        return const MessagesCallsSettingsScreen();
      case RouteNames.feedContentPreferences:
        return const FeedContentPreferencesScreen();
      case RouteNames.creatorToolsSettings:
        return const CreatorToolsSettingsScreen();
      case RouteNames.monetizationPayments:
        return const MonetizationPaymentsSettingsScreen();
      case RouteNames.communitiesGroups:
        return const CommunitiesGroupsSettingsScreen();
      case RouteNames.dataPrivacyCenter:
        return const DataPrivacyCenterScreen();
      case RouteNames.accessibilitySettings:
        return const AccessibilitySettingsScreen();
      case RouteNames.languageRegion:
        return const LanguageRegionSettingsScreen();
      case RouteNames.connectedApps:
        return const ConnectedAppsScreen();
      case RouteNames.helpSafety:
        return const HelpSafetySettingsScreen();
      case RouteNames.aboutSettings:
        return const AboutSettingsScreen();
      case RouteNames.languageAccessibility:
        return const LanguageAccessibilityScreen();
      case RouteNames.draftsScheduling:
        return DraftsAndSchedulingScreen();
      case RouteNames.drafts:
        return DraftsScreen();
      case RouteNames.scheduling:
        return SchedulingScreen();
      case RouteNames.uploadManager:
        return UploadManagerScreen();
      case RouteNames.offlineSync:
        return OfflineSyncScreen();
      case RouteNames.verificationRequest:
        return VerificationRequestScreen();
      case RouteNames.personalizationOnboarding:
        return PersonalizationOnboardingScreen();
      case RouteNames.advancedPrivacyControls:
        return AdvancedPrivacyControlsScreen();
      case RouteNames.shareRepostSystem:
        return ShareRepostSystemScreen();
      case RouteNames.mediaViewer:
        return MediaViewerScreen(arguments: _mediaViewerArguments(arguments));
      case RouteNames.postDetail:
        return PostDetailScreen(
          postId: _postIdFromArguments(arguments) ?? params['id'],
        );
      case RouteNames.accountSwitching:
        return AccountSwitchingScreen();
      case RouteNames.pushNotificationPreferences:
        return PushNotificationPreferencesScreen();
      case RouteNames.reportCenter:
        return ReportCenterScreen(arguments: arguments);
      case RouteNames.reportHistory:
        return const ReportHistoryScreen();
      case RouteNames.activitySessions:
        return ActivitySessionsScreen();
      case RouteNames.deepLinkHandler:
        return const DeepLinkHandlerScreen();
      case RouteNames.appUpdateFlow:
        return AppUpdateFlowScreen();
      case RouteNames.localizationSupport:
        return LocalizationSupportScreen();
      case RouteNames.accessibilitySupport:
        return AccessibilitySupportScreen();
      case RouteNames.exploreRecommendation:
        return const ExploreRecommendationScreen();
      case RouteNames.blockedMutedAccounts:
        return BlockedMutedAccountsScreen();
      case RouteNames.maintenanceMode:
        return MaintenanceModeScreen();
      case RouteNames.inviteReferral:
        return const InviteReferralScreen();
      case RouteNames.legalCompliance:
        return LegalComplianceScreen();
      case RouteNames.groupChat:
        return GroupChatScreen();
      case RouteNames.calls:
        final String? sessionId = _callSessionIdFromArguments(
          arguments,
          params,
        );
        if (sessionId != null) {
          final String mode = _callModeFromArguments(arguments, params);
          final String displayName = _callDisplayNameFromArguments(
            arguments,
            params,
          );
          final String avatarUrl = _callAvatarFromArguments(arguments, params);
          final String? recipientId = _callRecipientIdFromArguments(
            arguments,
            params,
          );
          if (mode == 'video') {
            return VideoCallScreen(
              name: displayName,
              avatarUrl: avatarUrl,
              recipientId: recipientId,
              sessionId: sessionId,
            );
          }
          return AudioCallScreen(
            name: displayName,
            avatarUrl: avatarUrl,
            recipientId: recipientId,
            sessionId: sessionId,
          );
        }
        return CallsScreen();
      case RouteNames.groups:
        return GroupsScreen();
      case RouteNames.pages:
        return PagesScreen();
      case RouteNames.hashtags:
        return HashtagsScreen();
      case RouteNames.trending:
        return TrendingScreen();
      case RouteNames.jobsNetworking:
        return JobsNetworkingScreen();
      case RouteNames.businessProfile:
        return BusinessProfileScreen();
      case RouteNames.bookmarks:
        return BookmarksScreen();
      case RouteNames.hiddenPosts:
        return const HiddenPostsScreen();
      case RouteNames.savedCollections:
        return const SavedCollectionsScreen();
      case RouteNames.walletPayments:
        return WalletPaymentsScreen();
      case RouteNames.subscriptions:
        return SubscriptionsScreen();
      case RouteNames.events:
        return EventsScreen();
      case RouteNames.eventsCreate:
        return const CreateEventScreen();
      case RouteNames.eventsPoolCreate:
        return const CreatePoolScreen();
      case RouteNames.liveStream:
        return LiveStreamScreen();
      case RouteNames.safetyPrivacy:
        return SafetyPrivacyScreen();
      case RouteNames.learningCourses:
        return LearningCoursesScreen();
      case RouteNames.pollsSurveys:
        return PollsSurveysScreen();
      case RouteNames.supportHelp:
        return SupportHelpScreen();
      case RouteNames.userProfile:
        return UserProfileScreen(userId: params['id']);
      case RouteNames.userProfileFollowers:
        return FollowListScreen(
          userId: params['id'],
          initialTab: FollowListTab.followers,
        );
      case RouteNames.userProfileFollowing:
        return FollowListScreen(
          userId: params['id'],
          initialTab: FollowListTab.following,
        );
      case RouteNames.userProfileEdit:
        return const EditProfileScreen();
      case RouteNames.chat:
        return ChatScreen();
      case RouteNames.chatDetail:
        return ChatDetailScreen(
          user: _chatUserFromArguments(arguments, params),
          initialMessage: _chatInitialMessageFromArguments(arguments, params),
        );
      case RouteNames.storiesCreate:
        return AddStoryScreen(userId: _storyUserIdFromArguments(arguments));
      case RouteNames.buddy:
        return const BuddyScreen();
      case RouteNames.storiesView:
        final List<StoryModel> stories = _storiesFromArguments(arguments);
        if (stories.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Stories are unavailable right now')),
          );
        }
        final String initialStoryId =
            params['id'] ??
            _storyInitialIdFromArguments(arguments) ??
            stories.first.id;
        return StoryViewScreen(
          stories: stories,
          users: _storyUsersFromArguments(arguments),
          initialStoryId: initialStoryId,
        );
      default:
        return const Scaffold(body: Center(child: Text('Route not found')));
    }
  }

  static String? _emailFromArguments(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }
    if (arguments is Map) {
      final Object? email = arguments['email'];
      if (email is String && email.trim().isNotEmpty) {
        return email.trim();
      }
    }
    return null;
  }

  static String? _otpFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? otp = arguments['otp'];
      if (otp is String && otp.trim().isNotEmpty) {
        return otp.trim();
      }
    }
    return null;
  }

  static UserModel? _userFromArguments(Object? arguments) {
    if (arguments is UserModel) {
      return arguments;
    }
    if (arguments is Map<String, dynamic>) {
      final Object? user = arguments['user'];
      if (user is UserModel) {
        return user;
      }
      if (user is Map<String, dynamic>) {
        return UserModel.fromApiJson(user);
      }
    }
    if (arguments is Map) {
      final Object? user = arguments['user'];
      if (user is UserModel) {
        return user;
      }
      if (user is Map) {
        return UserModel.fromApiJson(Map<String, dynamic>.from(user));
      }
    }
    return null;
  }

  static UserModel _chatUserFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    if (arguments is Map) {
      final Object? user = arguments['user'];
      if (user is UserModel) {
        return user;
      }
      if (user is Map) {
        return UserModel.fromApiJson(Map<String, dynamic>.from(user));
      }
    }

    final String userId = _valueFromArguments(arguments, <String>[
      'senderId',
      'actorId',
      'userId',
      'profileId',
      'recipientId',
      'targetId',
    ], params);
    final String name = _valueFromArguments(arguments, <String>[
      'actorName',
      'senderName',
      'displayName',
      'name',
      'username',
    ], params);
    final String username = _valueFromArguments(arguments, <String>[
      'username',
      'senderUsername',
      'actorUsername',
    ], params);
    final String avatar = _valueFromArguments(arguments, <String>[
      'avatar',
      'avatarUrl',
      'senderAvatar',
      'actorAvatar',
    ], params);

    return UserModel.fromApiJson(<String, dynamic>{
      'id': userId,
      'name': name.isEmpty ? 'Conversation' : name,
      'username': username.isEmpty ? userId : username,
      'avatar': avatar,
    });
  }

  static MessageModel _chatInitialMessageFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    final String threadId = _valueFromArguments(arguments, <String>[
      'threadId',
      'chatId',
      'conversationId',
      'targetId',
    ], params);
    return MessageModel(
      id: _valueFromArguments(arguments, <String>['messageId', 'id'], params),
      chatId: threadId,
      senderId: _valueFromArguments(arguments, <String>[
        'senderId',
        'actorId',
        'userId',
      ], params),
      text: _valueFromArguments(arguments, <String>[
        'text',
        'body',
        'message',
      ], params),
      timestamp: DateTime.now(),
      read: false,
    );
  }

  static String? _callSessionIdFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    final String value = _valueFromArguments(arguments, <String>[
      'sessionId',
      'callSessionId',
      'entityId',
      'targetId',
      'id',
    ], params);
    return value.isEmpty ? null : value;
  }

  static String _callModeFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    final String value = _valueFromArguments(arguments, <String>[
      'mode',
      'callMode',
      'type',
    ], params).toLowerCase();
    return value.contains('video') ? 'video' : 'voice';
  }

  static String _callDisplayNameFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    final String value = _valueFromArguments(arguments, <String>[
      'actorName',
      'initiatorName',
      'callerName',
      'senderName',
      'displayName',
      'name',
    ], params);
    return value.isEmpty ? 'Incoming call' : value;
  }

  static String _callAvatarFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    return _valueFromArguments(arguments, <String>[
      'avatar',
      'avatarUrl',
      'initiatorAvatar',
      'callerAvatar',
      'actorAvatar',
    ], params);
  }

  static String? _callRecipientIdFromArguments(
    Object? arguments,
    Map<String, String> params,
  ) {
    final String value = _valueFromArguments(arguments, <String>[
      'initiatorId',
      'callerId',
      'actorId',
      'senderId',
      'userId',
    ], params);
    return value.isEmpty ? null : value;
  }

  static String _valueFromArguments(
    Object? arguments,
    List<String> keys, [
    Map<String, String> params = const <String, String>{},
  ]) {
    for (final String key in keys) {
      final String? value = params[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    if (arguments is Map) {
      final Object? value = _valueFromMap(arguments, keys);
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }
    return '';
  }

  static Object? _valueFromMap(Map<dynamic, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value == null) {
        continue;
      }
      if (value is String && value.trim().isEmpty) {
        continue;
      }
      return value;
    }
    for (final String key in <String>['metadata', 'payload', 'data']) {
      final Object? nested = map[key];
      if (nested is Map) {
        final Object? value = _valueFromMap(nested, keys);
        if (value != null) {
          return value;
        }
      }
    }
    return null;
  }

  static MediaViewerRouteArguments? _mediaViewerArguments(Object? arguments) {
    if (arguments is MediaViewerRouteArguments) {
      return arguments;
    }
    if (arguments is Map) {
      final Object? rawItems = arguments['items'];
      final Object? rawInitialIndex = arguments['initialIndex'];
      final Object? rawTitle = arguments['title'];

      if (rawItems is List<MediaViewerItemModel>) {
        return MediaViewerRouteArguments(
          items: rawItems,
          initialIndex: rawInitialIndex is int ? rawInitialIndex : 0,
          title: rawTitle is String ? rawTitle : null,
        );
      }
      if (rawItems is List<String>) {
        return MediaViewerRouteArguments(
          items: rawItems
              .map(MediaViewerItemModel.fromSource)
              .toList(growable: false),
          initialIndex: rawInitialIndex is int ? rawInitialIndex : 0,
          title: rawTitle is String ? rawTitle : null,
        );
      }
    }
    return null;
  }

  static List<StoryModel> _storiesFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? stories = arguments['stories'];
      if (stories is List<StoryModel>) {
        return stories;
      }
    }
    return const <StoryModel>[];
  }

  static List<UserModel> _storyUsersFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? users = arguments['users'];
      if (users is List<UserModel>) {
        return users;
      }
    }
    return const <UserModel>[];
  }

  static String? _storyInitialIdFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? initialStoryId = arguments['initialStoryId'];
      if (initialStoryId is String && initialStoryId.trim().isNotEmpty) {
        return initialStoryId.trim();
      }
    }
    return null;
  }

  static String _storyUserIdFromArguments(Object? arguments) {
    if (arguments is Map) {
      final Object? userId = arguments['userId'];
      if (userId is String && userId.trim().isNotEmpty) {
        return userId.trim();
      }
    }
    return '';
  }

  static String? _postIdFromArguments(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }
    if (arguments is Map) {
      final Object? postId = arguments['postId'];
      if (postId is String && postId.trim().isNotEmpty) {
        return postId.trim();
      }
      final Object? id = arguments['id'];
      if (id is String && id.trim().isNotEmpty) {
        return id.trim();
      }
    }
    return null;
  }

  static String? _postDetailPathId(String routeName) {
    for (final String prefix in <String>['/post-detail/', '/post/']) {
      if (!routeName.startsWith(prefix)) {
        continue;
      }
      final String postId = routeName.substring(prefix.length).trim();
      if (postId.isNotEmpty) {
        return Uri.decodeComponent(postId);
      }
    }
    return null;
  }
}
