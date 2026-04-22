class ApiEndPoints {
  ApiEndPoints._();

  static const health = '/health';

  static const appBootstrap = '/app/bootstrap';
  static const appConfig = '/app/config';
  static const appSessionInit = '/app/session-init';

  static const onboardingSlides = '/onboarding/slides';
  static const onboardingState = '/onboarding/state';
  static const onboardingInterests = '/onboarding/interests';
  static const onboardingComplete = '/onboarding/complete';

  static const authLogin = '/auth/login';
  static const authSignup = '/auth/signup';
  static const authForgotPassword = '/auth/forgot-password';
  static const authResetPassword = '/auth/reset-password';
  static const authSendOtp = '/auth/send-otp';
  static const authResendOtp = '/auth/resend-otp';
  static const authVerifyOtp = '/auth/verify-otp';
  static const authDemoAccounts = '/auth/demo-accounts';
  static const authVerifyEmailConfirm = '/auth/verify-email/confirm';
  static const authMe = '/auth/me';

  static const users = '/users';
  static String userById(String userId) => '/users/$userId';
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userBlock(String userId) => '/users/$userId/block';

  static const feed = '/feed';

  static const posts = '/posts';
  static String postById(String postId) => '/posts/$postId';
  static String postLike(String postId) => '/posts/$postId/like';
  static String postDetail(String postId) => '/posts/$postId/detail';
  static String postComments(String postId) => '/posts/$postId/comments';

  static const stories = '/stories';
  static const reels = '/reels';

  static const drafts = '/drafts';
  static String draftById(String draftId) => '/drafts/$draftId';
  static const scheduling = '/scheduling';

  static const uploadManager = '/upload-manager';
  static String uploadManagerById(String uploadId) => '/upload-manager/$uploadId';

  static const chatThreads = '/chat/threads';
  static String chatThreadById(String threadId) => '/chat/threads/$threadId';
  static String chatThreadMessages(String threadId) =>
      '/chat/threads/$threadId/messages';
  static String chatThreadArchive(String threadId) =>
      '/chat/threads/$threadId/archive';
  static String chatThreadMute(String threadId) => '/chat/threads/$threadId/mute';
  static String chatThreadPin(String threadId) => '/chat/threads/$threadId/pin';
  static String chatThreadUnread(String threadId) =>
      '/chat/threads/$threadId/unread';
  static String chatThreadClear(String threadId) =>
      '/chat/threads/$threadId/clear';
  static const chatPresence = '/chat/presence';
  static const chatPreferences = '/chat/preferences';

  static const events = '/events';

  static const marketplaceProducts = '/marketplace/products';

  static const monetizationOverview = '/monetization/overview';
  static const monetizationWallet = '/monetization/wallet';
  static const monetizationSubscriptions = '/monetization/subscriptions';
  static const monetizationPlans = '/monetization/plans';

  static const notificationsCampaigns = '/notifications/campaigns';
  static const notificationsInbox = '/notifications/inbox';

  static const hashtags = '/hashtags';
  static const trending = '/trending';
  static const search = '/search';
  static const bookmarks = '/bookmarks';

  static const savedCollections = '/saved-collections';
  static String savedCollectionById(String collectionId) =>
      '/saved-collections/$collectionId';

  static const communities = '/communities';
  static String communityById(String communityId) => '/communities/$communityId';
  static const pages = '/pages';
  static String pageById(String pageId) => '/pages/$pageId';
  static const groups = '/groups';

  static const jobs = '/jobs';
  static String jobById(String jobId) => '/jobs/$jobId';
  static String jobApply(String jobId) => '/jobs/$jobId/apply';
  static const professionalProfiles = '/professional-profiles';

  static const inviteReferral = '/invite-referral';
  static const premiumMembership = '/premium-membership';
  static const walletPayments = '/wallet-payments';
  static const subscriptions = '/subscriptions';
  static const walletLedger = '/wallet/ledger';
  static const recommendations = '/recommendations';

  static const notificationPreferences = '/notification-preferences';
  static const settingsSections = '/settings/sections';
  static const safetyConfig = '/safety/config';

  static const supportFaqs = '/support/faqs';
  static const supportTickets = '/support/tickets';
  static const supportChat = '/support/chat';

  static const groupChat = '/group-chat';
  static const calls = '/calls';
  static const liveStream = '/live-stream';
  static const socketContract = '/socket/contract';
  static const masterData = '/master-data';

  static const legalConsents = '/legal/consents';
  static const legalAccountDeletion = '/legal/account-deletion';
  static const legalDataExport = '/legal/data-export';

  static const securityState = '/security/state';
  static const securityLogoutAll = '/security/logout-all';

  static Uri uri(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    final Map<String, String>? query = queryParameters?.map(
            (key, value) => MapEntry(key, value.toString()),
          );
    return Uri(path: endpoint, queryParameters: query);
  }

  // Legacy aliases kept to avoid breaking older mock-based call sites.
  static const homeFeed = feed;
  static const createPost = posts;
  static const scheduledPosts = scheduling;
  static const notifications = notificationsInbox;
  static const messages = chatThreads;
  static const settings = settingsSections;
  static const profile = authMe;
  static const marketplace = marketplaceProducts;
}
