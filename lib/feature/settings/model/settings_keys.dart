class SettingsKeys {
  SettingsKeys._();

  // Privacy
  static const profilePrivate = 'privacy.profile_private';
  static const activityStatus = 'privacy.activity_status';
  static const allowTagging = 'privacy.allow_tagging';
  static const allowMentions = 'privacy.allow_mentions';
  static const allowReposts = 'privacy.allow_reposts';
  static const allowComments = 'privacy.allow_comments';
  static const hideSensitive = 'privacy.hide_sensitive';
  static const hideLikes = 'privacy.hide_likes';

  // Notifications
  static const pushEnabled = 'notifications.push_enabled';
  static const emailEnabled = 'notifications.email_enabled';
  static const inAppSounds = 'notifications.in_app_sounds';
  static const marketing = 'notifications.marketing';

  // Messages & Calls
  static const messageRequests = 'messages.message_requests';
  static const readReceipts = 'messages.read_receipts';
  static const allowCalls = 'messages.allow_calls';
  static const autoDownloadMedia = 'messages.auto_download';

  // Security
  static const twoFactor = 'security.two_factor';

  // Feed & Content
  static const autoplay = 'feed.autoplay';
  static const dataSaver = 'feed.data_saver';
  static const hideTopics = 'feed.hide_topics';
  static const resetRecommendations = 'feed.reset_recommendations';

  // Creator tools
  static const professionalDashboard = 'creator.professional_dashboard';
  static const brandedContent = 'creator.branded_content';
  static const tips = 'creator.tips';
  static const subscriptions = 'creator.subscriptions';

  // Monetization
  static const payoutsEnabled = 'monetization.payouts_enabled';
  static const payoutOnHold = 'monetization.payout_on_hold';
  static const showSubscriberBadges = 'monetization.subscriber_badges';

  // Communities
  static const communityInvites = 'communities.invites';
  static const groupMentions = 'communities.group_mentions';
  static const eventsReminders = 'communities.events_reminders';

  // Data & Privacy Center
  static const dataExport = 'data.export_requested';
  static const adPersonalization = 'data.ad_personalization';
  static const dataCollection = 'data.data_collection';

  // Accessibility
  static const captions = 'accessibility.captions';
  static const highContrast = 'accessibility.high_contrast';
  static const reduceMotion = 'accessibility.reduce_motion';
  static const textSize = 'accessibility.text_size';

  // Language & Region
  static const language = 'locale.language';
  static const region = 'locale.region';

  // Connected Apps
  static const connectedApps = 'connected.apps';
}
