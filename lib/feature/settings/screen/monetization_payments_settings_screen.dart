import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/widgets/app_loader.dart';
import '../../../route/route_names.dart';
import '../controller/settings_state_controller.dart';
import '../model/settings_keys.dart';
import '../widget/settings_tiles.dart';

class MonetizationPaymentsSettingsScreen extends StatelessWidget {
  const MonetizationPaymentsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsStateController, SettingsState>(
      builder: (context, state) {
          final controller = context.read<SettingsStateController>();
          if (!state.loaded) {
            return Scaffold(
              appBar: AppBar(title: Text('Monetization & Payments')),
              body: Center(child: AppLoader()),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Monetization & Payments')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsSwitchTile(
                  title: 'Payouts enabled',
                  subtitle: 'Allow payouts to your default method',
                  icon: Icons.payments_outlined,
                  value: state.getBool(
                    SettingsKeys.payoutsEnabled,
                    fallback: true,
                  ),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.payoutsEnabled, value),
                ),
                SettingsSwitchTile(
                  title: 'Hold payouts',
                  subtitle: 'Temporarily pause payouts',
                  icon: Icons.pause_circle_outline,
                  value: state.getBool(SettingsKeys.payoutOnHold),
                  onChanged: (value) =>
                      controller.setBool(SettingsKeys.payoutOnHold, value),
                ),
                SettingsSwitchTile(
                  title: 'Show subscriber badges',
                  subtitle: 'Display subscriber badges on profile',
                  icon: Icons.shield_outlined,
                  value: state.getBool(
                    SettingsKeys.showSubscriberBadges,
                    fallback: true,
                  ),
                  onChanged: (value) => controller.setBool(
                    SettingsKeys.showSubscriberBadges,
                    value,
                  ),
                ),
                const SizedBox(height: 12),
                SettingsNavigationTile(
                  title: 'Wallet',
                  subtitle: 'View balance and payout methods',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => AppGet.toNamed(RouteNames.walletPayments),
                ),
                SettingsNavigationTile(
                  title: 'Subscriptions',
                  subtitle: 'Manage subscriber tiers',
                  icon: Icons.subscriptions_outlined,
                  onTap: () => AppGet.toNamed(RouteNames.subscriptions),
                ),
              ],
            ),
          );
      },
    );
  }
}
