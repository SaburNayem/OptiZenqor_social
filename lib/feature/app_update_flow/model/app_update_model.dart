import '../../../core/data/api/api_payload_reader.dart';

enum UpdateType { none, optional, forced, maintenance }

class AppUpdateModel {
  const AppUpdateModel({required this.type, required this.message});

  final UpdateType type;
  final String message;

  factory AppUpdateModel.fromApiJson(Map<String, dynamic> json) {
    final String rawType = ApiPayloadReader.readString(
      json['type'] ?? json['status'],
      fallback: UpdateType.none.name,
    );
    return AppUpdateModel(
      type: UpdateType.values.firstWhere(
        (UpdateType item) => item.name == rawType,
        orElse: () => UpdateType.none,
      ),
      message: ApiPayloadReader.readString(
        json['message'] ?? json['description'],
        fallback: 'Your app is up to date.',
      ),
    );
  }
}
