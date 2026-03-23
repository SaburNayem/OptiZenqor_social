class CourseModel {
  const CourseModel({required this.id, required this.title, required this.lessons, this.progress = 0});
  final String id;
  final String title;
  final List<String> lessons;
  final double progress;
}
