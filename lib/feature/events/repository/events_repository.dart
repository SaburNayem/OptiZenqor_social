import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/event_item_model.dart';
import '../service/events_service.dart';

class EventsRepository {
  EventsRepository({EventsService? service})
    : _service = service ?? EventsService();

  final EventsService _service;

  Future<List<EventItemModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.getEndpoint('events');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load events.');
    }

    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      response.data,
      preferredKeys: const <String>['events', 'items', 'data'],
    );
    return items
        .map(_eventFromApiJson)
        .where((EventItemModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<EventItemModel?> create({
    required String title,
    String? location,
    DateTime? date,
  }) async {
    final ServiceResponseModel<Map<String, dynamic>> response =
        await _service.apiClient.post(
      _service.endpoints['events']!,
      <String, dynamic>{
        'title': title.trim(),
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (date != null) 'date': date.toIso8601String(),
      },
    );
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic>? payload =
        ApiPayloadReader.readMap(response.data['event']) ??
        ApiPayloadReader.readMap(response.data['data']) ??
        ApiPayloadReader.readMap(response.data);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    return _eventFromApiJson(payload);
  }

  EventItemModel _eventFromApiJson(Map<String, dynamic> json) {
    final DateTime date =
        ApiPayloadReader.readDateTime(
          json['date'] ?? json['startsAt'] ?? json['eventDate'],
        ) ??
        DateTime.now();
    return EventItemModel(
      id: ApiPayloadReader.readString(json['id']),
      title: ApiPayloadReader.readString(json['title'], fallback: 'Event'),
      date: date,
      rsvped: ApiPayloadReader.readBool(json['rsvped']) ?? false,
      saved: ApiPayloadReader.readBool(json['saved']) ?? false,
      mediaGallery: ApiPayloadReader.readStringList(
        json['mediaGallery'] ?? json['images'] ?? json['media'],
      ),
      hostToolsSummary: ApiPayloadReader.readString(
        json['hostToolsSummary'] ?? json['summary'],
      ),
      location: ApiPayloadReader.readString(
        json['location'] ?? json['venue'] ?? json['address'],
      ),
      priceLabel: ApiPayloadReader.readString(
        json['priceLabel'] ?? json['price'],
      ),
      statsLabel: ApiPayloadReader.readString(
        json['statsLabel'] ?? json['attendeeLabel'] ?? json['stats'],
      ),
      attendeeAvatarUrls: ApiPayloadReader.readStringList(
        json['attendeeAvatarUrls'] ?? json['attendees'] ?? json['avatars'],
      ),
    );
  }
}
