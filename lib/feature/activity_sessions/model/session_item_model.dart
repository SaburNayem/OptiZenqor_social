class SessionItemModel {
  const SessionItemModel({
    required this.device,
    required this.location,
    required this.active,
  });

  final String device;
  final String location;
  final bool active;
}
