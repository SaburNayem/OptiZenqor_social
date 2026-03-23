class EventItemModel {
  const EventItemModel({
    required this.id,
    required this.title,
    required this.date,
    this.rsvped = false,
    this.saved = false,
    this.mediaGallery = const <String>[],
    this.hostToolsSummary = 'Host tools placeholder',
  });
  final String id;
  final String title;
  final DateTime date;
  final bool rsvped;
  final bool saved;
  final List<String> mediaGallery;
  final String hostToolsSummary;
  EventItemModel copyWith({bool? rsvped, bool? saved}) => EventItemModel(
        id: id,
        title: title,
        date: date,
        rsvped: rsvped ?? this.rsvped,
        saved: saved ?? this.saved,
        mediaGallery: mediaGallery,
        hostToolsSummary: hostToolsSummary,
      );
}
