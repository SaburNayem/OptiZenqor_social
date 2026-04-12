class PollModel {
  const PollModel({required this.id, required this.question, required this.options, required this.votes});
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;
}
