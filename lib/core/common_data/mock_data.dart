import '../common_models/group_model.dart';
import '../common_models/message_model.dart';
import '../common_models/notification_model.dart';
import '../common_models/post_model.dart';
import '../common_models/product_model.dart';
import '../common_models/reel_model.dart';
import '../common_models/story_model.dart';
import '../common_models/user_model.dart';
import '../enums/user_role.dart';

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
    ),
    const UserModel(
      id: 'u3',
      name: 'Rafi Ahmed',
      username: 'rafiahmed',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      bio: 'Mobile engineer and coffee explorer.',
      role: UserRole.user,
      followers: 9780,
      following: 640,
      verified: false,
    ),
    const UserModel(
      id: 'u4',
      name: 'Luna Crafts',
      username: 'luna.crafts',
      avatar: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=500',
      bio: 'Handmade decor and cozy studio stories.',
      role: UserRole.seller,
      followers: 21400,
      following: 220,
      verified: true,
    ),
    const UserModel(
      id: 'u5',
      name: 'Arif Talent Hub',
      username: 'arif.talent',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      bio: 'Hiring product and growth talent worldwide.',
      role: UserRole.recruiter,
      followers: 6400,
      following: 105,
      verified: false,
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
    ),
    PostModel(
      id: 'p5',
      authorId: 'u5',
      caption: 'Open roles this month: Product Designer, Flutter Engineer, PMM.',
      tags: const ['#jobs', '#hiring'],
      media: const [
        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1200',
      ],
      likes: 780,
      comments: 96,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
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
      likes: 34200,
      comments: 510,
      shares: 220,
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
      unread: true,
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
}
