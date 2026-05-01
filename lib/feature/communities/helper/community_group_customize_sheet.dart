import 'package:flutter/material.dart';

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
  var paidMembership = false;
  var donations = true;
  var subscriptions = false;
  var contentRestrictions = true;
  var ageRestriction = false;
  var regionRestriction = 'Global';

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
                  const _SheetHeader('Posting permissions'),
                  ...[
                    'Who can post',
                    'Who can comment',
                    'Post approval toggle',
                    'Allow anonymous posts',
                  ].map(_placeholderTile),
                  const _SheetHeader('Moderation'),
                  ...[
                    'Keyword filter',
                    'Reported posts list',
                    'Blocked users',
                    'Muted users',
                  ].map(_placeholderTile),
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
                  const _SheetHeader('Monetization'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Paid membership'),
                    value: paidMembership,
                    onChanged: (value) =>
                        setModalState(() => paidMembership = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Donations'),
                    value: donations,
                    onChanged: (value) =>
                        setModalState(() => donations = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Subscriptions'),
                    value: subscriptions,
                    onChanged: (value) =>
                        setModalState(() => subscriptions = value),
                  ),
                  const _SheetHeader('Safety'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Content restrictions'),
                    value: contentRestrictions,
                    onChanged: (value) =>
                        setModalState(() => contentRestrictions = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Age restriction'),
                    value: ageRestriction,
                    onChanged: (value) =>
                        setModalState(() => ageRestriction = value),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: regionRestriction,
                    items: const [
                      DropdownMenuItem(value: 'Global', child: Text('Global')),
                      DropdownMenuItem(value: 'Asia', child: Text('Asia')),
                      DropdownMenuItem(value: 'Europe', child: Text('Europe')),
                    ],
                    onChanged: (value) => setModalState(
                      () => regionRestriction = value ?? 'Global',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Region restriction',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        controller.updateGeneral(
                          name: nameController.text,
                          description: descriptionController.text,
                          category: categoryController.text,
                        );
                        controller.updatePrivacy(
                          privacy: privacy,
                          approvalRequired: approvalRequired,
                        );
                        controller.updateFeatures(
                          events: allowEvents,
                          live: allowLive,
                          polls: allowPolls,
                          marketplace: allowMarketplace,
                          chatRoom: allowChatRoom,
                        );
                        controller.setNotificationLevel(notifyLevel);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save settings'),
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

ListTile _placeholderTile(String title) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    trailing: const Icon(Icons.chevron_right_rounded),
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
