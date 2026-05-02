import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/safety_privacy_controller.dart';
import '../model/safety_privacy_model.dart';

class SafetyPrivacyScreen extends StatelessWidget {
  const SafetyPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SafetyPrivacyController>(
      create: (_) => SafetyPrivacyController()..load(),
      child: BlocBuilder<SafetyPrivacyController, SafetyPrivacyModel>(
        builder: (context, settings) {
          final controller = context.read<SafetyPrivacyController>();
          return Scaffold(
            appBar: AppBar(title: const Text('Safety & Privacy')),
            body: ListView(
              children: [
                SwitchListTile(
                  value: settings.isPrivate,
                  onChanged: (value) {
                    controller.update(settings.copyWith(isPrivate: value));
                  },
                  title: const Text('Private account'),
                ),
                SwitchListTile(
                  value: settings.hideContentFromUnknown,
                  onChanged: (value) {
                    controller.update(
                      settings.copyWith(hideContentFromUnknown: value),
                    );
                  },
                  title: const Text('Hide content from unknown users'),
                ),
                SwitchListTile(
                  value: settings.allowMentions,
                  onChanged: (value) {
                    controller.update(settings.copyWith(allowMentions: value));
                  },
                  title: const Text('Allow mentions'),
                ),
                const Divider(height: 24),
                const ListTile(
                  leading: Icon(Icons.report_gmailerrorred_outlined),
                  title: Text(
                    'Use the report center for account safety issues',
                  ),
                  subtitle: Text(
                    'Copyright, impersonation, harassment, and appeals are handled through backend moderation flows.',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text(
                    'Discoverability is controlled by your privacy settings',
                  ),
                  subtitle: Text(
                    'Private account and sensitive-content preferences are saved to your backend profile.',
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
