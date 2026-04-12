import '../model/event_item_model.dart';

class EventsRepository {
  List<EventItemModel> load() => <EventItemModel>[EventItemModel(id: 'e1', title: 'Creator Meetup', date: DateTime.now().add(const Duration(days: 2)))];
}
