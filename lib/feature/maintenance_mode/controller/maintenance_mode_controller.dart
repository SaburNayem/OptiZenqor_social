import '../model/maintenance_mode_model.dart';

class MaintenanceModeController {
  final MaintenanceModeModel state = const MaintenanceModeModel(
    title: 'Scheduled Maintenance',
    message: 'We are improving your experience. Please retry shortly.',
    isActive: false,
  );
}
