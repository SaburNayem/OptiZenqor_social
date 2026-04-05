import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../route/route_names.dart';
import '../widget/settings_tiles.dart';

class HelpSafetySettingsScreen extends StatelessWidget {
  const HelpSafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Safety')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsNavigationTile(
            title: 'Support & help center',
            subtitle: 'FAQs, contact, and troubleshooting',
            icon: Icons.support_agent_outlined,
            onTap: () => AppGet.toNamed(RouteNames.supportHelp),
          ),
          SettingsNavigationTile(
            title: 'Safety & privacy',
            subtitle: 'Safety resources and reporting',
            icon: Icons.health_and_safety_outlined,
            onTap: () => AppGet.toNamed(RouteNames.safetyPrivacy),
          ),
          SettingsNavigationTile(
            title: 'Report center',
            subtitle: 'Track your reports and appeals',
            icon: Icons.report_outlined,
            onTap: () => AppGet.toNamed(RouteNames.reportCenter),
          ),
          SettingsNavigationTile(
            title: 'Legal & compliance',
            subtitle: 'Policies and legal notices',
            icon: Icons.gavel_outlined,
            onTap: () => AppGet.toNamed(RouteNames.legalCompliance),
          ),
        ],
      ),
    );
  }
}
