import 'package:flutter/material.dart';

import '../../../core/helpers/format_helper.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../route/route_names.dart';
import '../controller/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileController _controller = UserProfileController();

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final user = _controller.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                AppAvatar(imageUrl: user.avatar, radius: 38, verified: user.verified),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                      Text('@${user.username}'),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed(RouteNames.settings),
                  child: const Text('Settings'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(user.bio),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatTile(label: 'Followers', value: FormatHelper.formatCompactNumber(user.followers)),
                const SizedBox(width: 12),
                _StatTile(label: 'Following', value: FormatHelper.formatCompactNumber(user.following)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Tabs: Posts • Reels • Saved • Tagged • About'),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                title: Text('Safety actions'),
                subtitle: Text('Block • Report • Mute options ready for policy integration'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
