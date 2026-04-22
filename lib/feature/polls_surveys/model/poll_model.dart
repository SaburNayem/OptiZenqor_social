enum PollEntryType { poll, survey }

class PollModel {
  const PollModel({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
    required this.votes,
    required this.type,
    required this.statusLabel,
    required this.audienceLabel,
    required this.endsInLabel,
    required this.responseCount,
    required this.accentHex,
  });

  final String id;
  final String title;
  final String question;
  final List<String> options;
  final List<int> votes;
  final PollEntryType type;
  final String statusLabel;
  final String audienceLabel;
  final String endsInLabel;
  final int responseCount;
  final int accentHex;

  PollModel copyWith({
    String? id,
    String? title,
    String? question,
    List<String>? options,
    List<int>? votes,
    PollEntryType? type,
    String? statusLabel,
    String? audienceLabel,
    String? endsInLabel,
    int? responseCount,
    int? accentHex,
  }) {
    return PollModel(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      options: options ?? this.options,
      votes: votes ?? this.votes,
      type: type ?? this.type,
      statusLabel: statusLabel ?? this.statusLabel,
      audienceLabel: audienceLabel ?? this.audienceLabel,
      endsInLabel: endsInLabel ?? this.endsInLabel,
      responseCount: responseCount ?? this.responseCount,
      accentHex: accentHex ?? this.accentHex,
    );
  }
}
