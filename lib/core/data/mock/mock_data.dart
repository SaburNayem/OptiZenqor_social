import '../models/group_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/post_model.dart';
import '../models/product_model.dart';
import '../models/reel_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../../enums/user_role.dart';
import '../../../feature/blocked_muted_accounts/model/restricted_account_model.dart';
import '../../../feature/drafts_and_scheduling/model/draft_item_model.dart';
import '../../../feature/events/model/event_model.dart';
import '../../../feature/notifications/model/notification_payload_model.dart';
import '../../../feature/pages/model/page_model.dart';
import '../../../feature/report_center/model/report_item_model.dart';
import '../../../feature/settings/model/settings_item_model.dart';
import '../../../feature/subscriptions/model/subscription_plan_model.dart';
import '../../../feature/upload_manager/model/upload_task_model.dart';
import '../../../feature/wallet_payments/model/wallet_transaction_model.dart';
import '../../../app_route/route_names.dart';

class MockData {
  MockData._();

  static final users = <UserModel>[
    const UserModel(
      id: 'u1',
      name: 'Maya Quinn',
      username: 'mayaquinn',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
      bio: 'Creator | Product storyteller | Travel visuals',
      role: UserRole.creator,
      followers: 82340,
      following: 512,
      verified: true,
      verificationStatus: 'verified',
      verificationReason: 'Recognized creator identity confirmed',
      badgeStyle: 'creator',
      publicProfileUrl: 'https://optizenqor.app/@mayaquinn',
      profilePreview:
          'Creator profile featuring reels, collabs, and featured launches.',
      note: 'Editing a new reel tonight',
      notePrivacy: 'followers',
      supporterBadge: true,
    ),
    const UserModel(
      id: 'u2',
      name: 'Nexa Studio',
      username: 'nexa.studio',
      avatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      bio: 'Design-driven business page for digital products.',
      role: UserRole.business,
      followers: 15400,
      following: 91,
      verified: true,
      verificationStatus: 'verified',
      verificationReason: 'Business documents verified',
      badgeStyle: 'business',
      publicProfileUrl: 'https://optizenqor.app/@nexa.studio',
      profilePreview:
          'Business page with campaigns, launches, and page insights.',
      note: 'Launch review at 6 PM',
      notePrivacy: 'public',
    ),
    const UserModel(
      id: 'u3',
      name: 'Rafi Ahmed',
      username: 'rafiahmed',
      avatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      bio: 'Mobile engineer and coffee explorer.',
      role: UserRole.user,
      followers: 9780,
      following: 640,
      verified: false,
      verificationStatus: 'pending',
      verificationReason: 'Identity review in progress',
      badgeStyle: 'standard',
      publicProfileUrl: 'https://optizenqor.app/@rafiahmed',
      profilePreview:
          'Engineer profile with devlogs, tagged posts, and note replies.',
      note: 'Inbox open for coffee chats',
      notePrivacy: 'connections',
    ),
    const UserModel(
      id: 'u4',
      name: 'Luna Crafts',
      username: 'luna.crafts',
      avatar:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
      bio: 'Handmade decor and cozy studio stories.',
      role: UserRole.seller,
      followers: 21400,
      following: 220,
      isPrivate: true,
      verified: true,
      verificationStatus: 'verified',
      verificationReason: 'Seller storefront verified',
      badgeStyle: 'seller',
      publicProfileUrl: 'https://optizenqor.app/@luna.crafts',
      profilePreview:
          'Shop profile with handmade drops and tagged product posts.',
      note: 'Packing weekend orders',
      notePrivacy: 'followers',
      supporterBadge: true,
    ),
    const UserModel(
      id: 'u5',
      name: 'Arif Talent Hub',
      username: 'arif.talent',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      bio: 'Hiring product and growth talent worldwide.',
      role: UserRole.recruiter,
      followers: 6400,
      following: 105,
      verified: false,
      verificationStatus: 'eligible',
      verificationReason: 'Recruiter badge available after company review',
      badgeStyle: 'recruiter',
      publicProfileUrl: 'https://optizenqor.app/@arif.talent',
      profilePreview:
          'Recruiter profile with open roles, hiring updates, and network signals.',
      note: 'Reviewing product candidates',
      notePrivacy: 'connections',
    ),
  ];

  static final posts = <PostModel>[
    PostModel(
      id: 'p1',
      authorId: 'u1',
      caption: 'Building social products that feel fast, calm, and human.',
      tags: const ['#design', '#mobile', '#creator'],
      media: const [
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1200',
      ],
      likes: 2341,
      comments: 302,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      viewCount: 12890,
      shareCount: 210,
      taggedUserIds: <String>['u2', 'u3'],
      mentionUsernames: <String>['nexa.studio'],
      location: 'Dhaka, Bangladesh',
      audience: 'Followers',
      altText: 'Laptop workspace with social product wireframes',
      editHistory: <String>['Caption refined after publishing'],
      brandCollaborationLabel: 'Design Sprint Partner',
    ),
    PostModel(
      id: 'p2',
      authorId: 'u2',
      caption: 'Launch week visuals are live. Which card style looks best?',
      tags: const ['#branding', '#productlaunch'],
      media: const [
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200',
      ],
      likes: 1890,
      comments: 224,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      viewCount: 10140,
      shareCount: 124,
      taggedUserIds: <String>['u1'],
      mentionUsernames: <String>['mayaquinn'],
      location: 'Remote Team Launch',
      audience: 'Everyone',
      altText: 'Launch cards displayed on a desk',
      editHistory: <String>['Updated card question for better engagement'],
      isSponsored: true,
      brandCollaborationLabel: 'Brand Collaboration',
      repostHistory: <String>['creator_club'],
    ),
    PostModel(
      id: 'p3',
      authorId: 'u3',
      caption: 'Shipping a cleaner chat composer tonight. Tiny details matter.',
      tags: const ['#flutter', '#devlog'],
      media: const [
        'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1200',
      ],
      likes: 954,
      comments: 118,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      viewCount: 6240,
      shareCount: 53,
      taggedUserIds: <String>['u1'],
      mentionUsernames: <String>['mayaquinn'],
      location: 'OptiZenqor Labs',
      audience: 'Close Friends',
      altText: 'Code editor with chat composer UI',
      editHistory: <String>['Added release note mention'],
    ),
    PostModel(
      id: 'p4',
      authorId: 'u4',
      caption: 'Weekend drop: new handcrafted lamp collection now in stock.',
      tags: const ['#shop', '#handmade'],
      media: const [
        'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1200',
      ],
      likes: 3210,
      comments: 410,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      viewCount: 18400,
      shareCount: 311,
      taggedUserIds: <String>['u4'],
      location: 'Studio Shop Floor',
      audience: 'Everyone',
      altText: 'Warm lamp collection arranged on shelves',
      editHistory: <String>['Inventory status updated'],
      isSponsored: true,
      brandCollaborationLabel: 'Shop Partner',
    ),
    PostModel(
      id: 'p5',
      authorId: 'u5',
      caption:
          'Open roles this month: Product Designer, Flutter Engineer, PMM.',
      tags: const ['#jobs', '#hiring'],
      media: const [
        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1200',
      ],
      likes: 780,
      comments: 96,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      viewCount: 5510,
      shareCount: 39,
      taggedUserIds: <String>['u5'],
      location: 'Global Remote',
      audience: 'Everyone',
      altText: 'Hiring board with role cards',
      editHistory: <String>['Added PMM role'],
    ),
    PostModel(
      id: 'p6',
      authorId: 'u1',
      caption: 'Behind the scenes from our creator meetup in Dhaka.',
      tags: const ['#community', '#creatorlife'],
      media: const [
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200',
      ],
      likes: 2760,
      comments: 332,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      viewCount: 14580,
      shareCount: 178,
      taggedUserIds: <String>['u2', 'u3', 'u4'],
      mentionUsernames: <String>['rafiahmed', 'luna.crafts'],
      location: 'Dhaka Creator Hub',
      audience: 'Everyone',
      altText: 'Creator meetup group photo',
      editHistory: <String>['Added meetup location tag'],
      repostHistory: <String>['community_highlights'],
    ),
  ];

  static final reels = <ReelModel>[
    const ReelModel(
      id: 'r1',
      authorId: 'u1',
      caption: '3 transitions for premium onboarding in 20 seconds.',
      audioName: 'Future Groove Mix',
      thumbnail:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1000',
      videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      likes: 34200,
      comments: 510,
      shares: 220,
      viewCount: 230100,
      coverUrl:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1000',
      textOverlays: <String>[
        'Hook in 2 sec',
        'Show transition',
        'End with CTA',
      ],
      subtitleEnabled: true,
      trimInfo: '00:00-00:05',
      remixEnabled: true,
    ),
  ];

  static final stories = <StoryModel>[
    const StoryModel(
      id: 's1',
      userId: 'u1',
      media:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800',
      seen: false,
    ),
    const StoryModel(
      id: 's2',
      userId: 'u2',
      media:
          'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=800',
      seen: false,
    ),
    const StoryModel(
      id: 's3',
      userId: 'u3',
      media:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
      seen: true,
    ),
    const StoryModel(
      id: 's4',
      userId: 'u4',
      media:
          'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=800',
      seen: false,
    ),
    const StoryModel(
      id: 's5',
      userId: 'u5',
      media:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
      seen: true,
    ),
  ];

  static final messages = <MessageModel>[
    MessageModel(
      id: 'm1',
      chatId: 'c1',
      senderId: 'u1',
      text: 'Let us launch the creator challenge this evening.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
      read: true,
    ),
  ];

  static final notifications = <NotificationModel>[
    NotificationModel(
      id: 'n1',
      title: 'New follower',
      body: 'nexa.studio followed you.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      payload: const NotificationPayloadModel(
        type: NotificationType.social,
        routeName: RouteNames.postDetail,
        entityId: 'u2',
      ),
      unread: true,
      actorName: 'nexa.studio',
      entityType: 'follow',
    ),
    NotificationModel(
      id: 'n2',
      title: 'Order update',
      body: 'Your marketplace order has shipped.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      payload: const NotificationPayloadModel(
        type: NotificationType.commerce,
        routeName: RouteNames.marketplace,
        entityId: 'order-1024',
      ),
      unread: true,
      actorName: 'Marketplace',
      entityType: 'order',
    ),
    NotificationModel(
      id: 'n3',
      title: 'Security alert',
      body: 'New device sign-in detected.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      payload: const NotificationPayloadModel(
        type: NotificationType.security,
        routeName: RouteNames.activitySessions,
        entityId: 'session-77',
      ),
      unread: false,
      actorName: 'Security Center',
      entityType: 'session',
    ),
  ];

  static final groups = <GroupModel>[
    const GroupModel(
      id: 'g1',
      name: 'Flutter Scale Circle',
      description: 'Architecture, performance, and app growth discussion.',
      members: 12400,
    ),
  ];

  static final products = <ProductModel>[
    const ProductModel(
      id: 'pr1',
      title: 'Creator Lighting Kit',
      price: 149.0,
      location: 'San Francisco',
      image:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900',
    ),
  ];

  static final pages = <PageModel>[
    const PageModel(
      id: 'page1',
      name: 'OptiZenqor Creators',
      about: 'Creator education, launches, and community updates.',
      posts: <String>['p1', 'p6'],
      category: 'Creator',
      actionButtonLabel: 'View Page',
    ),
  ];

  static final events = <EventModel>[
    const EventModel(
      id: 'e1',
      title: 'Creator Meetup Dhaka',
      imageUrl:
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=1200',
      date: '2026-04-12',
      time: '6:30 PM',
      location: 'Dhaka',
      price: 0,
      attendeeAvatars: <String>[
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
      ],
      attendeeCount: 120,
    ),
  ];

  static final walletTransactions = <WalletTransactionModel>[
    WalletTransactionModel(
      title: 'Creator payout',
      amount: 245.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WalletTransactionModel(
      title: 'Premium subscription',
      amount: -19.99,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static final subscriptions = <SubscriptionPlanModel>[
    const SubscriptionPlanModel(id: 'sub1', name: 'Starter', price: 4.99),
    const SubscriptionPlanModel(id: 'sub2', name: 'Creator Pro', price: 14.99),
  ];

  static final settingsValues = <SettingsItemModel>[
    const SettingsItemModel(
      title: 'Account',
      subtitle: 'Manage your public profile details',
      routeName: RouteNames.accountSettings,
    ),
    const SettingsItemModel(
      title: 'Notifications',
      subtitle: 'Choose what you want to receive',
      routeName: RouteNames.notificationsSettings,
    ),
    const SettingsItemModel(
      title: 'Privacy',
      subtitle: 'Control visibility, mentions, and comments',
      routeName: RouteNames.privacySettings,
    ),
  ];

  static final reports = <ReportItemModel>[
    const ReportItemModel(reason: 'Spam content', status: 'resolved'),
    const ReportItemModel(reason: 'Harassment', status: 'under_review'),
  ];

  static final blockedUsers = <RestrictedAccountModel>[
    const RestrictedAccountModel(
      id: 'rb1',
      name: 'Muted Profile',
      handle: '@muted.profile',
      status: 'blocked',
    ),
  ];

  static final drafts = <DraftItemModel>[
    DraftItemModel(
      id: 'draft1',
      title: 'Launch note for creator campaign',
      type: PublishType.post,
      scheduledAt: DateTime.now().add(const Duration(days: 1)),
      audience: 'Followers',
    ),
  ];

  static final uploads = <UploadTaskModel>[
    const UploadTaskModel(
      id: 'upload1',
      fileName: 'creator_intro.mp4',
      progress: 1,
      status: UploadStatus.completed,
    ),
    const UploadTaskModel(
      id: 'upload2',
      fileName: 'launch_banner.png',
      progress: 0.45,
      status: UploadStatus.uploading,
    ),
  ];
}

