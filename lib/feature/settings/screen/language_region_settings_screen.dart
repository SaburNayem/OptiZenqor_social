import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_loader.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';

class LanguageRegionSettingsScreen extends StatelessWidget {
  const LanguageRegionSettingsScreen({super.key});

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
  Widget build(BuildContext context) {
    return BlocProvider<SettingsStateController>(
      create: (_) => SettingsStateController()..load(),
      child: BlocBuilder<SettingsStateController, SettingsState>(
        builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Language & Region')),
              body: Center(child: AppLoader()),
            );
          }
          final language = state.getString(
            SettingsKeys.language,
            fallback: _languages.first,
          );
          final region = state.getString(
            SettingsKeys.region,
            fallback: _regions.first,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Language & Region')),
            body: ListView(
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
                        controller.setString(SettingsKeys.language, value);
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
                        controller.setString(SettingsKeys.region, value);
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
            ),
          );
        },
      ),
    );
  }
}
