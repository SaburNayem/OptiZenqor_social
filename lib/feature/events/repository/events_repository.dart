import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/event_item_model.dart';
import '../service/events_service.dart';

class EventsRepository {
  EventsRepository({EventsService? service})
    : _service = service ?? EventsService();

  final EventsService _service;

  Future<List<EventItemModel>> load() async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .getEndpoint('events');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load events.');
    }

    final List<Map<String, dynamic>> items = ApiPayloadReader.readMapList(
      ApiPayloadReader.requireDataMap(
        response.data,
        fallbackMessage: 'Events response did not include a data payload.',
      ),
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
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .post(_service.endpoints['events']!, <String, dynamic>{
          'title': title.trim(),
          if (location != null && location.trim().isNotEmpty)
            'location': location.trim(),
          if (date != null) 'date': date.toIso8601String(),
        });
    if (!response.isSuccess || response.data['success'] == false) {
      return null;
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'Event creation response did not include data.',
    );
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(data['event']) ?? data;
    if (payload.isEmpty) {
      return null;
    }
    return _eventFromApiJson(payload);
  }

  Future<EventItemModel> toggleRsvp(String id) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/events/$id/rsvp', <String, dynamic>{});
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to update RSVP.');
    }
    return fetchById(id);
  }

  Future<EventItemModel> toggleSave(String id) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .patch('/events/$id/save', <String, dynamic>{});
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(
        response.message ?? 'Unable to update saved event state.',
      );
    }
    return fetchById(id);
  }

  Future<EventItemModel> fetchById(String id) async {
    final ServiceResponseModel<Map<String, dynamic>> response = await _service
        .apiClient
        .get('/events/$id');
    if (!response.isSuccess || response.data['success'] == false) {
      throw Exception(response.message ?? 'Unable to load event details.');
    }
    final Map<String, dynamic> data = ApiPayloadReader.requireDataMap(
      response.data,
      fallbackMessage: 'The backend returned no event payload.',
    );
    final Map<String, dynamic> payload =
        ApiPayloadReader.readMap(data['event']) ?? data;
    if (payload.isEmpty) {
      throw Exception('The backend returned no event payload.');
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
      title: ApiPayloadReader.readString(json['title']),
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
