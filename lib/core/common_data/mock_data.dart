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
