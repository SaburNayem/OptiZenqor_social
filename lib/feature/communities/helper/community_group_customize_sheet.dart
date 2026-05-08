import 'package:flutter/material.dart';

import '../../../core/functions/app_feedback.dart';
import '../model/community_group_model.dart';
import '../bloc/community_group_cubit.dart';
import 'community_group_formatters.dart';

Future<void> showCommunityGroupCustomizeSheet(
  BuildContext context,
  CommunityGroupCubit controller,
) async {
  final nameController = TextEditingController(text: controller.group.name);
  final descriptionController = TextEditingController(
    text: controller.group.description,
  );
  final categoryController = TextEditingController(
    text: controller.group.category,
  );
  var privacy = controller.group.privacy;
  var approvalRequired = controller.group.approvalRequired;
  var allowEvents = controller.group.allowEvents;
  var allowLive = controller.group.allowLive;
  var allowPolls = controller.group.allowPolls;
  var allowMarketplace = controller.group.allowMarketplace;
  var allowChatRoom = controller.group.allowChatRoom;
  var notifyLevel = controller.group.notificationLevel;
  var isSaving = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customize group',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  const _SheetHeader('General'),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Edit group name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Edit description',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category selection',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showSnack(context, 'Change cover locally'),
                          child: const Text('Change cover'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showSnack(context, 'Change avatar locally'),
                          child: const Text('Change avatar'),
                        ),
                      ),
                    ],
                  ),
                  const _SheetHeader('Privacy'),
                  Wrap(
                    spacing: 8,
                    children: CommunityPrivacy.values
                        .map(
                          (item) => ChoiceChip(
                            label: Text(privacyLabel(item)),
                            selected: privacy == item,
                            onSelected: (_) =>
                                setModalState(() => privacy = item),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Approval required'),
                    value: approvalRequired,
                    onChanged: (value) =>
                        setModalState(() => approvalRequired = value),
                  ),
                  const _SheetHeader('Notifications'),
                  Wrap(
                    spacing: 8,
                    children: CommunityNotificationLevel.values
                        .map(
                          (item) => ChoiceChip(
                            label: Text(notificationLabel(item)),
                            selected: notifyLevel == item,
                            onSelected: (_) =>
                                setModalState(() => notifyLevel = item),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const _SheetHeader('Features toggle'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable events'),
                    value: allowEvents,
                    onChanged: (value) =>
                        setModalState(() => allowEvents = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable live'),
                    value: allowLive,
                    onChanged: (value) =>
                        setModalState(() => allowLive = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable polls'),
                    value: allowPolls,
                    onChanged: (value) =>
                        setModalState(() => allowPolls = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable marketplace inside group'),
                    value: allowMarketplace,
                    onChanged: (value) =>
                        setModalState(() => allowMarketplace = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable chat room'),
                    value: allowChatRoom,
                    onChanged: (value) =>
                        setModalState(() => allowChatRoom = value),
                  ),
                  const _SheetHeader('Backend-managed scope'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Only settings backed by the live backend are editable here. Advanced moderation, monetization, and region restrictions are managed from the admin dashboard until mobile APIs for those controls are available.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              final bool generalSaved = await controller
                                  .updateGeneral(
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    category: categoryController.text,
                                  );
                              final bool privacySaved = await controller
                                  .updatePrivacy(
                                    privacy: privacy,
                                    approvalRequired: approvalRequired,
                                  );
                              final bool featuresSaved = await controller
                                  .updateFeatures(
                                    events: allowEvents,
                                    live: allowLive,
                                    polls: allowPolls,
                                    marketplace: allowMarketplace,
                                    chatRoom: allowChatRoom,
                                  );
                              final bool notificationSaved = await controller
                                  .updateNotificationLevel(notifyLevel);
                              if (!context.mounted) {
                                return;
                              }
                              setModalState(() => isSaving = false);
                              if (generalSaved &&
                                  privacySaved &&
                                  featuresSaved &&
                                  notificationSaved) {
                                AppFeedback.showSnackbar(
                                  title: 'Community settings',
                                  message:
                                      'Group settings saved from the backend.',
                                );
                                Navigator.of(context).pop();
                                return;
                              }
                              AppFeedback.showSnackbar(
                                title: 'Community settings',
                                message:
                                    'Some changes could not be saved to the backend.',
                              );
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save settings'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
