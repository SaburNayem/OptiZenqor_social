import 'settings_item_model.dart';

class SettingsSectionModel {
  const SettingsSectionModel({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<SettingsItemModel> items;
}
