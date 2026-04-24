import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/navigation/app_get.dart';
import '../../auth/repository/auth_repository.dart';

class StoryBuddiesScreen extends StatefulWidget {
  const StoryBuddiesScreen({super.key});

  @override
  State<StoryBuddiesScreen> createState() => _StoryBuddiesScreenState();
}

class _StoryBuddiesScreenState extends State<StoryBuddiesScreen> {
  final AuthRepository _authRepository = AuthRepository();
  Future<UserModel?>? _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _authRepository.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Buddies')),
      body: FutureBuilder<UserModel?>(
        future: _currentUserFuture,
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserModel? currentUser = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser == null
                          ? 'Manage your story buddies'
                          : 'Manage story buddies for ${currentUser.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use this space to control the people you want close to your story sharing, similar to a friends list.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => AppGet.toNamed(RouteNames.privacySettings),
                          icon: const Icon(Icons.privacy_tip_outlined),
                          label: const Text('Story privacy'),
                        ),
                        OutlinedButton.icon(
                          onPressed: currentUser == null
                              ? null
                              : () => AppGet.toNamed(
                                  RouteNames.userProfileFollowing,
                                  parameters: <String, String>{'id': currentUser.id},
                                ),
                          icon: const Icon(Icons.people_outline_rounded),
                          label: const Text('Following list'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const EmptyStateView(
                title: 'Buddy list is ready for live data',
                message:
                    'When backend buddy management is added, selected people will appear here and you will be able to add or remove them.',
              ),
            ],
          );
        },
      ),
    );
  }
}
