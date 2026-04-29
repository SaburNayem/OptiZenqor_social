class EventItemModel {
  const EventItemModel({
    required this.id,
    required this.title,
    required this.date,
    this.rsvped = false,
    this.saved = false,
    this.mediaGallery = const <String>[],
    this.hostToolsSummary = '',
    this.location = '',
    this.priceLabel = '',
    this.statsLabel = '',
    this.attendeeAvatarUrls = const <String>[],
  });
  final String id;
  final String title;
  final DateTime date;
  final bool rsvped;
  final bool saved;
  final List<String> mediaGallery;
  final String hostToolsSummary;
  final String location;
  final String priceLabel;
  final String statsLabel;
  final List<String> attendeeAvatarUrls;
  EventItemModel copyWith({bool? rsvped, bool? saved}) => EventItemModel(
        id: id,
        title: title,
        date: date,
        rsvped: rsvped ?? this.rsvped,
        saved: saved ?? this.saved,
        mediaGallery: mediaGallery,
        hostToolsSummary: hostToolsSummary,
        location: location,
        priceLabel: priceLabel,
        statsLabel: statsLabel,
        attendeeAvatarUrls: attendeeAvatarUrls,
      );
}
