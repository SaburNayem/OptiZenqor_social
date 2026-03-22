enum UpdateType { none, optional, forced, maintenance }

class AppUpdateModel {
  const AppUpdateModel({required this.type, required this.message});

  final UpdateType type;
  final String message;
}
