import 'package:flutter/material.dart';

import '../controller/safety_privacy_controller.dart';

class SafetyPrivacyScreen extends StatefulWidget {
  const SafetyPrivacyScreen({super.key});

  @override
  State<SafetyPrivacyScreen> createState() => _SafetyPrivacyScreenState();
}

class _SafetyPrivacyScreenState extends State<SafetyPrivacyScreen> {
  final SafetyPrivacyController _controller = SafetyPrivacyController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety & Privacy')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final settings = _controller.settings;
          return ListView(
            children: [
              SwitchListTile(
                value: settings.isPrivate,
                onChanged: (value) {
                  _controller.update(settings.copyWith(isPrivate: value));
                },
                title: const Text('Private account'),
              ),
              SwitchListTile(
                value: settings.hideContentFromUnknown,
                onChanged: (value) {
                  _controller.update(
                    settings.copyWith(hideContentFromUnknown: value),
                  );
                },
                title: const Text('Hide content from unknown users'),
              ),
              SwitchListTile(
                value: settings.allowMentions,
                onChanged: (value) {
                  _controller.update(settings.copyWith(allowMentions: value));
                },
                title: const Text('Allow mentions'),
              ),
              const ListTile(
                leading: Icon(Icons.gpp_maybe_outlined),
                title: Text('Copyright report placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.person_search_outlined),
                title: Text('Impersonation report placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.sentiment_very_dissatisfied_outlined),
                title: Text('Harassment / bullying report flow'),
              ),
              const ListTile(
                leading: Icon(Icons.self_improvement_outlined),
                title: Text('Self-harm concern placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.rotate_right_outlined),
                title: Text('Appeal flow placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.family_restroom_outlined),
                title: Text('Supervised account placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined),
                title: Text('Guardian controls placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Teen privacy defaults placeholder'),
              ),
              const ListTile(
                leading: Icon(Icons.visibility_off_outlined),
                title: Text('Restricted discoverability placeholder'),
              ),
            ],
          );
        },
      ),
    );
  }
}
