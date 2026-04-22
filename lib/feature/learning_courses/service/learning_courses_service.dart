import '../../../core/data/service/feature_service_base.dart';

class LearningCoursesService extends FeatureServiceBase {
  LearningCoursesService({super.apiClient});

  @override
  String get featureName => 'learning_courses';
}
