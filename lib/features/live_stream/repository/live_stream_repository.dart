import 'package:flutter/material.dart';

import '../model/live_stream_model.dart';

class LiveStreamRepository {
  LiveStreamModel load({
    String? initialTitle,
    String? initialPhotoPath,
    LiveAudienceVisibility? initialAudience,
  }) {
    return LiveStreamModel(
      creatorName: 'Maya Quinn',
      username: '@mayaquinn',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
      previewLabel: 'Describe what your live video is about',
      liveTitle: initialTitle?.trim().isNotEmpty == true
          ? initialTitle!.trim()
          : 'Studio Check-in',
      description:
          'Quick behind-the-scenes stream with Q&A and live product highlights.',
      audience: initialAudience ?? LiveAudienceVisibility.public,
      viewerCount: 284,
      category: 'Creator Studio',
      location: 'Dhaka, Bangladesh',
      previewPhotoPath: initialPhotoPath,
      quickOptions: const <LiveQuickOptionModel>[
        LiveQuickOptionModel(
          id: 'live',
          label: 'Live video',
          icon: Icons.videocam_rounded,
          selected: true,
        ),
        LiveQuickOptionModel(
          id: 'friend',
          label: 'Bring a friend',
          icon: Icons.group_add_outlined,
        ),
        LiveQuickOptionModel(
          id: 'fundraiser',
          label: 'Raise money',
          icon: Icons.volunteer_activism_outlined,
        ),
        LiveQuickOptionModel(
          id: 'event',
          label: 'Event',
          icon: Icons.event_outlined,
        ),
        LiveQuickOptionModel(
          id: 'audio',
          label: 'Audio room',
          icon: Icons.graphic_eq_rounded,
        ),
        LiveQuickOptionModel(
          id: 'poll',
          label: 'Poll',
          icon: Icons.poll_outlined,
        ),
        LiveQuickOptionModel(
          id: 'qa',
          label: 'Q&A',
          icon: Icons.quiz_outlined,
        ),
        LiveQuickOptionModel(
          id: 'products',
          label: 'Sell products',
          icon: Icons.shopping_bag_outlined,
        ),
        LiveQuickOptionModel(
          id: 'screen',
          label: 'Share screen',
          icon: Icons.screen_share_outlined,
        ),
      ],
      comments: const <LiveCommentModel>[
        LiveCommentModel(
          id: 'c1',
          username: 'sadia.designs',
          avatarUrl:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500',
          message: 'The setup looks so clean today.',
          verified: true,
        ),
        LiveCommentModel(
          id: 'c2',
          username: 'rahul.codes',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
          message: 'Please talk about your creator workflow.',
        ),
        LiveCommentModel(
          id: 'c3',
          username: 'lina.photo',
          avatarUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
          message: 'Love the colors in this preview.',
        ),
      ],
    );
  }
}
