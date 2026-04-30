import 'package:flutter/foundation.dart';

import '../model/course_model.dart';
import '../repository/learning_courses_repository.dart';

class LearningCoursesController extends ChangeNotifier {
  LearningCoursesController({LearningCoursesRepository? repository})
    : _repository = repository ?? LearningCoursesRepository();

  final LearningCoursesRepository _repository;
  List<CourseModel> courses = <CourseModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      courses = await _repository.load();
    } catch (error) {
      courses = const <CourseModel>[];
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
