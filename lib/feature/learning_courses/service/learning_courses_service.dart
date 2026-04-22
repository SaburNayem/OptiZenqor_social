import '../../../core/data/api/api_end_points.dart';
import '../../../core/data/service/feature_service_base.dart';

class LearningCoursesService extends FeatureServiceBase {
  LearningCoursesService({super.apiClient});

  @override
  String get featureName => 'learning_courses';

  @override
  Map<String, String> get endpoints => <String, String>{
    'learning_courses': ApiEndPoints.learningCourses,
  };
}
