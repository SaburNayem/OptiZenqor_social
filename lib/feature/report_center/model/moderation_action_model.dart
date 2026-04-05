class ModerationActionModel {
  const ModerationActionModel({
    required this.id,
    required this.type,
    required this.targetId,
  });

  final String id;
  final String type;
  final String targetId;
}
