import 'settings_item_model.dart';

class SettingsSectionModel {
  const SettingsSectionModel({
    required this.title,
<<<<<<< HEAD
    required this.items,
    this.description,
  });

  final String title;
  final String? description;
=======
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
>>>>>>> 08433d8 (update)
  final List<SettingsItemModel> items;
}
