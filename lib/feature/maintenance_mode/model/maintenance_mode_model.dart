import '../../../core/data/api/api_payload_reader.dart';

class MaintenanceModeModel {
  const MaintenanceModeModel({
    required this.title,
    required this.message,
    required this.isActive,
  });

  final String title;
  final String message;
  final bool isActive;

  factory MaintenanceModeModel.fromApiJson(Map<String, dynamic> json) {
    return MaintenanceModeModel(
      title: ApiPayloadReader.readString(
        json['title'],
        fallback: 'Scheduled Maintenance',
      ),
      message: ApiPayloadReader.readString(
        json['message'] ?? json['description'],
        fallback: 'We are improving your experience. Please retry shortly.',
      ),
      isActive:
          ApiPayloadReader.readBool(json['isActive'] ?? json['active']) ??
          false,
    );
  }
}
