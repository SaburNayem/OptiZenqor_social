class ApiEndPoints {
  ApiEndPoints._();

  static const documentedHttpEndpointCount = 349;

  // Tooling
  static const root = '/';
  static const docs = '/docs';
  static const docsJson = '/docs-json';
  static const docsYaml = '/docs-yaml';

  // System API Module

  // HealthController
  static const health = '/health';
  static const healthDatabase = '/health/database';

  // BootstrapController
  static const appBootstrap = '/app/bootstrap';
  static const appConfig = '/app/config';
  static const appSessionInit = '/app/session-init';

  // AuthController
  static const authDemoAccounts = '/auth/demo-accounts';
  static const authLogin = '/auth/login';
  static const authGoogle = '/auth/google';
  static const authRefreshToken = '/auth/refresh-token';
  static const authLogout = '/auth/logout';
  static const authSignup = '/auth/signup';
  static const authVerifyEmailConfirm = '/auth/verify-email/confirm';
  static const authForgotPassword = '/auth/forgot-password';
  static const authResetPassword = '/auth/reset-password';
  static const authMe = '/auth/me';

  // OnboardingController
  static const onboardingSlides = '/onboarding/slides';
  static const onboardingState = '/onboarding/state';
  static const onboardingInterests = '/onboarding/interests';
  static const onboardingComplete = '/onboarding/complete';

  // AccountOpsController
  static const authSendOtp = '/auth/send-otp';
  static const authResendOtp = '/auth/resend-otp';
  static const authVerifyOtp = '/auth/verify-otp';
  static const recommendations = '/recommendations';
  static const chatPresence = '/chat/presence';
  static const chatPreferences = '/chat/preferences';
  static const notificationPreferences = '/notification-preferences';
  static const safetyConfig = '/safety/config';
  static const supportChat = '/support/chat';
  static const walletLedger = '/wallet/ledger';
  static const masterData = '/master-data';
  static const legalConsents = '/legal/consents';
  static const legalAccountDeletion = '/legal/account-deletion';
  static const legalDataExport = '/legal/data-export';
  static const securityState = '/security/state';
  static const securityLogoutAll = '/security/logout-all';

  // Content API Module

  // UsersController
  static const users = '/users';
  static String userById(String userId) => '/users/$userId';
  static String userFollowers(String userId) => '/users/$userId/followers';
  static String userFollowing(String userId) => '/users/$userId/following';
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userUnfollow(String userId) => '/users/$userId/unfollow';
  static const usersChangePassword = '/users/change-password';

  // ContentController
  static const feed = '/feed';
  static const feedHome = '/feed/home';

  // PostsController
  static const posts = '/posts';
  static const postsCreate = '/posts/create';
  static String postById(String postId) => '/posts/$postId';

  // LikesController
  static String postReactions(String postId) => '/posts/$postId/reactions';
  static String postLike(String postId) => '/posts/$postId/like';
  static String postUnlike(String postId) => '/posts/$postId/unlike';

  // MediaViewerController
  static const mediaViewer = '/media-viewer';
  static String mediaViewerById(String mediaId) => '/media-viewer/$mediaId';

  // MessagesController
  static const messages = '/messages';
  static String messageById(String messageId) => '/messages/$messageId';

  // StoriesController
  static const stories = '/stories';
  static String storyById(String storyId) => '/stories/$storyId';
  static String storyComments(String storyId) => '/stories/$storyId/comments';
  static String storyReactions(String storyId) => '/stories/$storyId/reactions';

  // ReelsController
  static const reels = '/reels';
  static String reelById(String reelId) => '/reels/$reelId';
  static String reelComments(String reelId) => '/reels/$reelId/comments';
  static String reelReactions(String reelId) => '/reels/$reelId/reactions';

  // UploadsController
  static const uploads = '/uploads';
  static String uploadById(String uploadId) => '/uploads/$uploadId';
  static const uploadManager = '/upload-manager';
  static String uploadManagerById(String uploadId) =>
      '/upload-manager/$uploadId';

  // CommentsController
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentReplies(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/replies';
  static String postCommentReact(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/react';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';

  // CreatorFlowController
  static const drafts = '/drafts';
  static const postsDrafts = '/posts/drafts';
  static String draftById(String draftId) => '/drafts/$draftId';
  static const scheduling = '/scheduling';
  static const postsScheduled = '/posts/scheduled';
  static const draftsScheduling = '/drafts-scheduling';

  // ChatController
  static const chat = '/chat';
  static const chatDetail = '/chat/detail';
  static String chatDetailById(String chatId) => '/chat/detail/$chatId';
  static const chatSettings = '/chat/settings';
  static const chatThreads = '/chat/threads';
  static String chatThreadById(String threadId) => '/chat/threads/$threadId';
  static String chatThreadMessages(String threadId) =>
      '/chat/threads/$threadId/messages';
  static String chatThreadRead(String threadId) =>
      '/chat/threads/$threadId/read';
  static String chatThreadArchive(String threadId) =>
      '/chat/threads/$threadId/archive';
  static String chatThreadMute(String threadId) =>
      '/chat/threads/$threadId/mute';
  static String chatThreadPin(String threadId) => '/chat/threads/$threadId/pin';
  static String chatThreadUnread(String threadId) =>
      '/chat/threads/$threadId/unread';
  static String chatThreadClear(String threadId) =>
      '/chat/threads/$threadId/clear';

  // RealtimeController
  static const groupChat = '/group-chat';
  static String groupChatById(String chatId) => '/group-chat/$chatId';
  static const calls = '/calls';
  static String callById(String callId) => '/calls/$callId';
  static const liveStream = '/live-stream';
  static const liveStreamSetup = '/live-stream/setup';
  static const liveStreamStudio = '/live-stream/studio';
  static String liveStreamComments(String streamId) =>
      '/live-stream/$streamId/comments';
  static String liveStreamReactions(String streamId) =>
      '/live-stream/$streamId/reactions';
  static String liveStreamById(String streamId) => '/live-stream/$streamId';
  static const socketContract = '/socket/contract';
  static const callsRtcConfig = '/calls/rtc-config';
  static const callSessions = '/calls/sessions';
  static String callSessionById(String sessionId) =>
      '/calls/sessions/$sessionId';
  static String callSessionEnd(String sessionId) =>
      '/calls/sessions/$sessionId/end';

  // Experience API Module

  // AccountSwitchingController
  static const accountSwitching = '/account-switching';
  static const accountSwitchingActive = '/account-switching/active';

  // ActivitySessionsController
  static const activitySessions = '/activity-sessions';
  static const activitySessionsHistory = '/activity-sessions/history';
  static const activitySessionsLogoutOthers =
      '/activity-sessions/logout-others';
  static String activitySessionById(String sessionId) =>
      '/activity-sessions/$sessionId';

  // AppUpdateFlowController
  static const appUpdateFlow = '/app-update-flow';
  static const appUpdateFlowStart = '/app-update-flow/start';

  // BlockController
  static const block = '/block';
  static String blockByTargetId(String targetId) => '/block/$targetId';

  // BookmarksController
  static const bookmarks = '/bookmarks';
  static String bookmarkById(String bookmarkId) => '/bookmarks/$bookmarkId';
  static String bookmarkPost(String postId) => '/bookmarks/posts/$postId';

  // DeepLinkHandlerController
  static const deepLinkHandler = '/deep-link-handler';
  static const deepLinkHandlerResolve = '/deep-link-handler/resolve';

  // HiddenPostsController
  static const hiddenPosts = '/hidden-posts';
  static String hiddenPostByTargetId(String targetId) =>
      '/hidden-posts/$targetId';
  static const archivePosts = '/archive/posts';
  static const archiveStories = '/archive/stories';
  static const archiveReels = '/archive/reels';

  // HideController
  static const hide = '/hide';
  static const hidePostsAll = '/hide/posts/all';
  static const hideHiddenPosts = '/hide/hidden-posts';
  static String hidePost(String postId) => '/hide/posts/$postId';
  static String hideHiddenPostByTargetId(String targetId) =>
      '/hide/hidden-posts/$targetId';
  static String hideByTargetId(String targetId) => '/hide/$targetId';

  // DiscoveryController
  static const hashtags = '/hashtags';
  static const trending = '/trending';
  static const search = '/search';
  static const searchDiscovery = '/search-discovery';
  static const savedCollections = '/saved-collections';
  static String savedCollectionById(String collectionId) =>
      '/saved-collections/$collectionId';

  // CommunitiesController
  static const communities = '/communities';
  static String communityById(String communityId) =>
      '/communities/$communityId';
  static String communityJoin(String communityId) =>
      '/communities/$communityId/join';
  static String communityLeave(String communityId) =>
      '/communities/$communityId/leave';
  static String communityPosts(String communityId) =>
      '/communities/$communityId/posts';
  static String communityMembers(String communityId) =>
      '/communities/$communityId/members';
  static String communityEvents(String communityId) =>
      '/communities/$communityId/events';
  static String communityPinnedPosts(String communityId) =>
      '/communities/$communityId/pinned-posts';
  static String communityTrendingPosts(String communityId) =>
      '/communities/$communityId/trending-posts';
  static String communityAnnouncements(String communityId) =>
      '/communities/$communityId/announcements';
  static const pages = '/pages';
  static const pagesCreate = '/pages/create';
  static const pagesDetail = '/pages/detail';
  static String pageDetailById(String pageId) => '/pages/detail/$pageId';
  static String pageById(String pageId) => '/pages/$pageId';
  static const groups = '/groups';
  static String groupById(String groupId) => '/groups/$groupId';
  static String groupPosts(String groupId) => '/groups/$groupId/posts';
  static String groupMembers(String groupId) => '/groups/$groupId/members';

  // EventsController
  static const events = '/events';
  static const eventsCreate = '/events/create';
  static const eventsPoolCreate = '/events/pool/create';
  static const eventsDetail = '/events/detail';
  static String eventById(String eventId) => '/events/$eventId';
  static String eventRsvp(String eventId) => '/events/$eventId/rsvp';
  static String eventSave(String eventId) => '/events/$eventId/save';

  // JobsController
  static const jobs = '/jobs';
  static const jobsNetworking = '/jobs-networking';
  static const jobsCreate = '/jobs/create';
  static const jobsDetail = '/jobs/detail';
  static String jobDetailById(String jobId) => '/jobs/detail/$jobId';
  static const jobsApply = '/jobs/apply';
  static String jobApply(String jobId) => '/jobs/$jobId/apply';
  static const jobsApplications = '/jobs/applications';
  static const jobsAlerts = '/jobs/alerts';
  static const jobsCompanies = '/jobs/companies';
  static const jobsProfile = '/jobs/profile';
  static const jobsEmployerStats = '/jobs/employer-stats';
  static const jobsEmployerProfile = '/jobs/employer-profile';
  static const jobsApplicants = '/jobs/applicants';
  static String jobById(String jobId) => '/jobs/$jobId';
  static const professionalProfiles = '/professional-profiles';

  // EngagementController
  static const inviteReferral = '/invite-referral';
  static const premiumMembership = '/premium-membership';
  static const premium = '/premium';
  static const walletPayments = '/wallet-payments';
  static const subscriptions = '/subscriptions';

  // LearningCoursesController
  static const learningCourses = '/learning-courses';

  // LocalizationSupportController
  static const localizationSupport = '/localization-support';

  // MaintenanceModeController
  static const maintenanceMode = '/maintenance-mode';
  static const maintenanceModeRetry = '/maintenance-mode/retry';

  // OfflineSyncController
  static const offlineSync = '/offline-sync';
  static const offlineSyncRetry = '/offline-sync/retry';

  // PersonalizationOnboardingController
  static const personalizationOnboarding = '/personalization-onboarding';
  static const personalizationOnboardingInterests =
      '/personalization-onboarding/interests';

  // PollsSurveysController
  static const pollsSurveys = '/polls-surveys';
  static const pollsSurveysActive = '/polls-surveys/active';
  static const pollsSurveysDrafts = '/polls-surveys/drafts';
  static String pollsSurveyVote(String pollId) => '/polls-surveys/$pollId/vote';

  // PreferencesController
  static const advancedPrivacyControls = '/advanced-privacy-controls';
  static const safetyPrivacy = '/safety-privacy';
  static const accessibilitySupport = '/accessibility-support';
  static const exploreRecommendation = '/explore-recommendation';
  static const pushNotificationPreferences = '/push-notification-preferences';
  static const legalCompliance = '/legal-compliance';
  static const blockedMutedAccounts = '/blocked-muted-accounts';

  // ReportCenterController
  static const reportCenter = '/report-center';

  // ProfilesController
  static const profile = '/profile';
  static String profileById(String profileId) => '/profile/$profileId';
  static String profileTaggedPosts(String profileId) =>
      '/profile/$profileId/tagged-posts';
  static String profileMentionHistory(String profileId) =>
      '/profile/$profileId/mention-history';
  static const userProfileEdit = '/user-profile/edit';
  static const userProfile = '/user-profile';
  static const userProfileFollowers = '/user-profile/followers';
  static const userProfileFollowing = '/user-profile/following';
  static String userProfileById(String profileId) => '/user-profile/$profileId';
  static String followUnfollowFollowers(String profileId) =>
      '/follow-unfollow/$profileId/followers';
  static String followUnfollowFollowing(String profileId) =>
      '/follow-unfollow/$profileId/following';
  static String followUnfollowFollow(String profileId) =>
      '/follow-unfollow/$profileId/follow';
  static String followUnfollowUnfollow(String profileId) =>
      '/follow-unfollow/$profileId/unfollow';
  static String followUnfollowMutuals(String profileId) =>
      '/follow-unfollow/$profileId/mutuals';
  static String userFollowState(String userId) => '/users/$userId/follow-state';
  static const creatorDashboard = '/creator-dashboard';
  static const businessProfile = '/business-profile';
  static const sellerProfile = '/seller-profile';
  static const recruiterProfile = '/recruiter-profile';

  // ShareRepostController
  static const shareRepostOptions = '/share-repost/options';
  static const shareRepostTrack = '/share-repost/track';

  // SupportController
  static const supportFaqs = '/support/faqs';
  static const supportTickets = '/support/tickets';
  static const supportHelp = '/support-help';
  static const supportHelpFaq = '/support-help/faq';
  static const supportHelpChat = '/support-help/chat';
  static const supportHelpMail = '/support-help/mail';

  // VerificationRequestController
  static const verificationRequest = '/verification-request';
  static const verificationRequestDocuments = '/verification-request/documents';
  static const verificationRequestSubmit = '/verification-request/submit';
  static const verificationRequestStatus = '/verification-request/status';
  static const storiesArchive = '/stories/archive';
  static String storyViewers(String storyId) => '/stories/$storyId/viewers';

  // MarketplaceController
  static const marketplace = '/marketplace';
  static const marketplaceCreate = '/marketplace/create';
  static const marketplaceDetail = '/marketplace/detail';
  static String marketplaceDetailById(String productId) =>
      '/marketplace/detail/$productId';
  static const marketplaceCheckout = '/marketplace/checkout';
  static const marketplaceProducts = '/marketplace/products';
  static String marketplaceProductById(String productId) =>
      '/marketplace/products/$productId';

  // MonetizationController
  static const monetizationOverview = '/monetization/overview';
  static const monetizationWallet = '/monetization/wallet';
  static const monetizationSubscriptions = '/monetization/subscriptions';
  static const monetizationPlans = '/monetization/plans';

  // NotificationsController
  static const notifications = '/notifications';
  static const notificationsInbox = '/notifications/inbox';
  static const notificationsPreferences = '/notifications/preferences';
  static const notificationsCampaigns = '/notifications/campaigns';
  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  // InviteFriendsController
  static const inviteFriends = '/invite-friends';

  // WalletController
  static const wallet = '/wallet';

  // PremiumPlansController
  static const premiumPlans = '/premium-plans';

  // SettingsController
  static const settings = '/settings';
  static const settingsSections = '/settings/sections';
  static const settingsItems = '/settings/items';
  static const settingsState = '/settings/state';
  static String settingsItemByKey(String itemKey) => '/settings/items/$itemKey';
  static String settingsBySectionKey(String sectionKey) =>
      '/settings/$sectionKey';

  // Admin API Module

  // AdminOpsController
  static const adminAuthDemoAccounts = '/admin/auth/demo-accounts';
  static const adminAuthLogin = '/admin/auth/login';
  static const adminAuthMe = '/admin/auth/me';
  static const adminAuthSessions = '/admin/auth/sessions';
  static String adminAuthSessionRevoke(String sessionId) =>
      '/admin/auth/sessions/$sessionId/revoke';
  static const adminVerificationQueue = '/admin/verification-queue';
  static String adminVerificationQueueById(String queueId) =>
      '/admin/verification-queue/$queueId';
  static const adminModerationCases = '/admin/moderation-cases';
  static String adminModerationCaseById(String caseId) =>
      '/admin/moderation-cases/$caseId';
  static const adminChatControl = '/admin/chat-control';
  static String adminChatControlById(String controlId) =>
      '/admin/chat-control/$controlId';
  static const adminBroadcastCampaigns = '/admin/broadcast-campaigns';
  static const adminAudienceSegments = '/admin/audience-segments';
  static const adminAnalyticsPipeline = '/admin/analytics-pipeline';
  static const adminRbac = '/admin/rbac';
  static const adminOperationalSettings = '/admin/operational-settings';
  static const adminAuditLogSystem = '/admin/audit-log-system';
  static const adminContentOperations = '/admin/content-operations';
  static const adminCommerceRisk = '/admin/commerce-risk';
  static const adminSupportOperations = '/admin/support-operations';

  // AdminController
  static const adminDashboard = '/admin/dashboard';
  static const adminUsers = '/admin/users';
  static const adminContent = '/admin/content';
  static const adminReports = '/admin/reports';
  static const adminChatCases = '/admin/chat-cases';
  static const adminEvents = '/admin/events';
  static const adminMonetization = '/admin/monetization';
  static const adminNotifications = '/admin/notifications';
  static const adminAnalytics = '/admin/analytics';
  static const adminRoles = '/admin/roles';
  static const adminSettings = '/admin/settings';
  static const adminAuditLogs = '/admin/audit-logs';

  static Uri uri(String endpoint, {Map<String, dynamic>? queryParameters}) {
    final Map<String, String>? query = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri(path: endpoint, queryParameters: query);
  }

  // Legacy aliases kept to avoid breaking older mock-based call sites.
  static const homeFeed = feed;
  static const createPost = posts;
  static const scheduledPosts = scheduling;

  static String postDetail(String postId) => postById(postId);
  static String userBlock(String userId) => blockByTargetId(userId);
}
