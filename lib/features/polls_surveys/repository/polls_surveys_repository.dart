import '../model/poll_model.dart';

class PollsSurveysRepository {
  List<PollModel> activeEntries() => const <PollModel>[
    PollModel(
      id: 'poll_1',
      title: 'Weekly content direction',
      question: 'What would you like to see next on my profile?',
      options: <String>[
        'Behind-the-scenes reels',
        'Career growth tips',
        'Design breakdowns',
      ],
      votes: <int>[42, 28, 36],
      type: PollEntryType.poll,
      statusLabel: 'Live now',
      audienceLabel: 'Followers only',
      endsInLabel: 'Ends in 18 hours',
      responseCount: 106,
      accentHex: 0xFF0EA5E9,
    ),
    PollModel(
      id: 'survey_1',
      title: 'Community feedback survey',
      question: 'Which area of the app still needs the most improvement?',
      options: <String>[
        'Profile customization',
        'Messaging reliability',
        'Content discovery',
        'Creator monetization',
      ],
      votes: <int>[18, 11, 22, 15],
      type: PollEntryType.survey,
      statusLabel: 'Collecting answers',
      audienceLabel: 'Public',
      endsInLabel: 'Ends in 3 days',
      responseCount: 66,
      accentHex: 0xFF14B8A6,
    ),
  ];

  List<PollModel> draftEntries() => const <PollModel>[
    PollModel(
      id: 'draft_1',
      title: 'Brand collab interest check',
      question: 'Would you want early access to brand collab calls?',
      options: <String>['Yes, send invites', 'Maybe later', 'Not interested'],
      votes: <int>[0, 0, 0],
      type: PollEntryType.poll,
      statusLabel: 'Draft',
      audienceLabel: 'Close friends',
      endsInLabel: 'Not scheduled',
      responseCount: 0,
      accentHex: 0xFFF59E0B,
    ),
    PollModel(
      id: 'draft_2',
      title: 'Audience research form',
      question: 'How often do you want long-form educational posts?',
      options: <String>[
        'Every week',
        'Twice a month',
        'Only when relevant',
      ],
      votes: <int>[0, 0, 0],
      type: PollEntryType.survey,
      statusLabel: 'Draft',
      audienceLabel: 'Subscribers',
      endsInLabel: 'Not scheduled',
      responseCount: 0,
      accentHex: 0xFF8B5CF6,
    ),
  ];

  List<String> quickTemplates() => const <String>[
    'Feature feedback',
    'Event attendance check',
    'Content preference vote',
    'Product research survey',
  ];
}
