import 'package:flutter/foundation.dart';

import '../model/event_item_model.dart';
import '../repository/events_repository.dart';

class EventsController extends ChangeNotifier {
  EventsController({EventsRepository? repository})
      : _repository = repository ?? EventsRepository();

  final EventsRepository _repository;
  List<EventItemModel> events = <EventItemModel>[];

  void load() {
    events = _repository.load();
    notifyListeners();
  }

  void create(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return;
    }
    events = <EventItemModel>[
      EventItemModel(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        title: trimmed,
        date: DateTime.now().add(const Duration(days: 7)),
      ),
      ...events,
    ];
    notifyListeners();
  }

  void rsvp(String id) {
    events = events
        .map(
          (event) => event.id == id
              ? event.copyWith(rsvped: !event.rsvped)
              : event,
        )
        .toList();
    notifyListeners();
  }

  void save(String id) {
    events = events
        .map(
          (event) => event.id == id
              ? event.copyWith(saved: !event.saved)
              : event,
        )
        .toList();
    notifyListeners();
  }
}
