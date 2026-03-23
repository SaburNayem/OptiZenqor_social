class EventItemModel {
  const EventItemModel({required this.id, required this.title, required this.date, this.rsvped = false});
  final String id;
  final String title;
  final DateTime date;
  final bool rsvped;
  EventItemModel copyWith({bool? rsvped}) => EventItemModel(id: id, title: title, date: date, rsvped: rsvped ?? this.rsvped);
}
