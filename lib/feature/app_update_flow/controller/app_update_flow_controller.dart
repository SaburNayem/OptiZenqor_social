import '../model/app_update_model.dart';

class AppUpdateFlowController {
  final AppUpdateModel update = const AppUpdateModel(
    type: UpdateType.optional,
    message: 'Version 2.1 has performance improvements and chat upgrades.',
  );
}
