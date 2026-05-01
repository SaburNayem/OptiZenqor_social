import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/community_group_model.dart';
import '../repository/communities_repository_impl.dart';
import '../usecase/get_communities_use_case.dart';
import '../bloc/communities_cubit.dart';
import '../bloc/communities_state.dart';
import '../widget/community_list_widgets.dart';
import 'community_group_screen.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({
    this.showJoinedFirst = false,
    this.title = 'Communities',
    super.key,
  });

  final bool showJoinedFirst;
  final String title;

  @override
  Widget build(BuildContext context) {
    final CommunitiesRepositoryImpl repository = CommunitiesRepositoryImpl();
    return BlocProvider(
      create: (_) => CommunitiesCubit(
        getCommunitiesUseCase: GetCommunitiesUseCase(repository),
        repository: repository,
        showJoinedFirst: showJoinedFirst,
      )..load(),
      child: _CommunitiesView(title: title),
    );
  }
}

class _CommunitiesView extends StatelessWidget {
  const _CommunitiesView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunitiesCubit, CommunitiesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateCommunitySheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  children: [
                    TextField(
                      onChanged: context.read<CommunitiesCubit>().updateQuery,
                      decoration: InputDecoration(
                        hintText: 'Search communities',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Discover'),
                          selected: !state.showJoinedOnly,
                          onSelected: (_) => context
                              .read<CommunitiesCubit>()
                              .showJoinedOnly(false),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Joined'),
                          selected: state.showJoinedOnly,
                          onSelected: (_) => context
                              .read<CommunitiesCubit>()
                              .showJoinedOnly(true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const CommunitySectionTitle('Featured communities'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 244,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.groups.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return FeaturedCommunityCard(
                            group: group,
                            onTap: () => _openGroup(context, group),
                            onJoinTap: () => context
                                .read<CommunitiesCubit>()
                                .toggleJoin(group.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    CommunitySectionTitle(
                      state.showJoinedOnly ? 'Your communities' : 'Browse all',
                    ),
                    const SizedBox(height: 12),
                    ...state.filteredGroups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommunityListTileCard(
                          group: group,
                          onTap: () => _openGroup(context, group),
                          onJoinTap: () => context
                              .read<CommunitiesCubit>()
                              .toggleJoin(group.id),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openGroup(
    BuildContext context,
    CommunityGroupModel group,
  ) async {
    final updated = await Navigator.of(context).push<CommunityGroupModel>(
      MaterialPageRoute(builder: (_) => CommunityGroupScreen(group: group)),
    );
    if (updated != null && context.mounted) {
      context.read<CommunitiesCubit>().applyUpdatedGroup(updated);
    }
  }

  Future<void> _showCreateCommunitySheet(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create community',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<CommunitiesCubit>().createCommunity(
                      name: nameController.text,
                      description: descriptionController.text,
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Create community'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
