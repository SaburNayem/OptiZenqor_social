import 'settings_item_model.dart';

class SettingsSectionModel {
  const SettingsSectionModel({
    required this.title,
    required this.items,
    this.description,
  });

  final String title;
  final String? description;
  final List<SettingsItemModel> items;
}
