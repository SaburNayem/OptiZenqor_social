class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.lessons,
    this.progress = 0,
    this.instructor = '',
    this.saved = false,
    this.certificateSummary = '',
    this.quizSummary = '',
  });
  final String id;
  final String title;
  final List<String> lessons;
  final double progress;
  final String instructor;
  final bool saved;
  final String certificateSummary;
  final String quizSummary;
}
