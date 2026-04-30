import 'package:flutter/foundation.dart';

import '../model/event_item_model.dart';
import '../repository/events_repository.dart';

class EventsController extends ChangeNotifier {
  EventsController({EventsRepository? repository})
    : _repository = repository ?? EventsRepository();

  final EventsRepository _repository;
  List<EventItemModel> events = <EventItemModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      events = await _repository.load();
    } catch (error) {
      events = const <EventItemModel>[];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(String title, {String? location, DateTime? date}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final EventItemModel? created = await _repository.create(
      title: trimmed,
      location: location,
      date: date,
    );
    if (created != null) {
      events = <EventItemModel>[created, ...events];
    }
    notifyListeners();
  }

  void rsvp(String id) {
    events = events
        .map(
          (event) =>
              event.id == id ? event.copyWith(rsvped: !event.rsvped) : event,
        )
        .toList();
    notifyListeners();
  }

  void save(String id) {
    events = events
        .map(
          (event) =>
              event.id == id ? event.copyWith(saved: !event.saved) : event,
        )
        .toList();
    notifyListeners();
  }
}
