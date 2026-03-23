import 'package:flutter/foundation.dart';

import '../model/course_model.dart';
import '../repository/learning_courses_repository.dart';

class LearningCoursesController extends ChangeNotifier {
  LearningCoursesController({LearningCoursesRepository? repository})
      : _repository = repository ?? LearningCoursesRepository();

  final LearningCoursesRepository _repository;
  List<CourseModel> courses = <CourseModel>[];

  void load() {
    courses = _repository.load();
    notifyListeners();
  }
}
