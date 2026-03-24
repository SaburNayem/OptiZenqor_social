import 'package:flutter/material.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';

class LanguageRegionSettingsScreen extends StatefulWidget {
  const LanguageRegionSettingsScreen({super.key});

  @override
  State<LanguageRegionSettingsScreen> createState() =>
      _LanguageRegionSettingsScreenState();
}

class _LanguageRegionSettingsScreenState
    extends State<LanguageRegionSettingsScreen> {
  final SettingsStateController _controller = SettingsStateController();

  final List<String> _languages = const [
    'English',
    'Bangla',
    'Spanish',
    'French',
  ];

  final List<String> _regions = const [
    'United States',
    'Bangladesh',
    'United Kingdom',
    'Canada',
  ];

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language & Region')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          final language =
              _controller.getString(SettingsKeys.language, fallback: _languages.first);
          final region =
              _controller.getString(SettingsKeys.region, fallback: _regions.first);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('App language'),
                subtitle: Text(language),
                trailing: DropdownButton<String>(
                  value: language,
                  onChanged: (value) {
                    if (value != null) {
                      _controller.setString(SettingsKeys.language, value);
                    }
                  },
                  items: _languages
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.public_outlined),
                title: const Text('Region'),
                subtitle: Text(region),
                trailing: DropdownButton<String>(
                  value: region,
                  onChanged: (value) {
                    if (value != null) {
                      _controller.setString(SettingsKeys.region, value);
                    }
                  },
                  items: _regions
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
