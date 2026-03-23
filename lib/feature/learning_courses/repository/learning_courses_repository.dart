import '../model/course_model.dart';

class LearningCoursesRepository {
  List<CourseModel> load() => const <CourseModel>[
        CourseModel(id: 'c1', title: 'Flutter Social App Architecture', lessons: <String>['Intro', 'State', 'Routing'], progress: 0.4),
      ];
}
