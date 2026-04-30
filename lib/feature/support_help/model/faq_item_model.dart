class FaqItemModel {
  const FaqItemModel({required this.question, required this.answer});
  final String question;
  final String answer;

  factory FaqItemModel.fromApiJson(Map<String, dynamic> json) {
    return FaqItemModel(
      question: (json['question'] ?? '').toString().trim(),
      answer: (json['answer'] ?? '').toString().trim(),
    );
  }
}
