import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class MonetizationPaymentsSettingsScreen extends StatefulWidget {
  const MonetizationPaymentsSettingsScreen({super.key});

  @override
  State<MonetizationPaymentsSettingsScreen> createState() =>
      _MonetizationPaymentsSettingsScreenState();
}

class _MonetizationPaymentsSettingsScreenState
    extends State<MonetizationPaymentsSettingsScreen> {
  final SettingsStateController _controller = SettingsStateController();

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
      appBar: AppBar(title: const Text('Monetization & Payments')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.loaded) {
            return const Center(child: AppLoader());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSwitchTile(
                title: 'Payouts enabled',
                subtitle: 'Allow payouts to your default method',
                icon: Icons.payments_outlined,
                value: _controller.getBool(SettingsKeys.payoutsEnabled, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.payoutsEnabled, value),
              ),
              SettingsSwitchTile(
                title: 'Hold payouts',
                subtitle: 'Temporarily pause payouts',
                icon: Icons.pause_circle_outline,
                value: _controller.getBool(SettingsKeys.payoutOnHold),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.payoutOnHold, value),
              ),
              SettingsSwitchTile(
                title: 'Show subscriber badges',
                subtitle: 'Display subscriber badges on profile',
                icon: Icons.shield_outlined,
                value: _controller.getBool(SettingsKeys.showSubscriberBadges, fallback: true),
                onChanged: (value) =>
                    _controller.setBool(SettingsKeys.showSubscriberBadges, value),
              ),
              const SizedBox(height: 12),
              SettingsNavigationTile(
                title: 'Wallet',
                subtitle: 'View balance and payout methods',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => Get.toNamed(RouteNames.walletPayments),
              ),
              SettingsNavigationTile(
                title: 'Subscriptions',
                subtitle: 'Manage subscriber tiers',
                icon: Icons.subscriptions_outlined,
                onTap: () => Get.toNamed(RouteNames.subscriptions),
              ),
            ],
          );
        },
      ),
    );
  }
}
