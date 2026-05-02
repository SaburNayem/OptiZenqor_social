import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/course_model.dart';
import '../service/learning_courses_service.dart';

class LearningCoursesRepository {
  LearningCoursesRepository({LearningCoursesService? service})
    : _service = service ?? LearningCoursesService();

  final LearningCoursesService _service;

  Future<List<CourseModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('learning_courses');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load learning courses.');
    }

    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(response.data['data']) ?? response.data;
    return ApiPayloadReader.readMapList(
          payload,
          preferredKeys: const <String>['courses', 'items', 'results'],
        )
        .map(_courseFromApiJson)
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  CourseModel _courseFromApiJson(Map<String, dynamic> json) {
    return CourseModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(json['title'], fallback: 'Course'),
      lessons: ApiPayloadReader.readStringList(json['lessons']),
      progress: ApiPayloadReader.readDouble(json['progress']),
      instructor: ApiPayloadReader.readString(
        json['instructor'],
        fallback: 'Instructor profile',
      ),
      saved: ApiPayloadReader.readBool(json['saved']) ?? false,
      certificateSummary: ApiPayloadReader.readString(
        json['certificateSummary'],
      ),
      quizSummary: ApiPayloadReader.readString(json['quizSummary']),
    );
  }
}
