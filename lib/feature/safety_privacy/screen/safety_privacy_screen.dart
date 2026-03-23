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
            ],
          );
        },
      ),
    );
  }
}
