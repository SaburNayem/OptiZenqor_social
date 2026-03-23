import 'package:flutter/foundation.dart';

import '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model. _import '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model. _import '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model. _import '../mode 1import '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model. _import '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_model.daimport '../model/group_moder.dart';

class GroupsScreen extends StatelessWidget {
  GroupsScreen({super.key}) { _controller.load(); }
  final GroupsController _controller = GroupsController();
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [Expanded(child: TextField(controller: _name, decoration: const InputDecoration(hintText: 'Create group'))), IconButton(onPressed: () => _controller.createGroup(_name.text), icon: const Icon(Icons.group_add_outlined))]),
            ..._controller.groups.map((g) => Card(child: ListTile(title: Text(g.name), subtitle: Text('${g.members} members'), trailing: FilledButton(onPressed: () => _controller.toggleJoin(g.id), child: Text(g.joined ? 'Leave' : 'Join'))))),
          ],
        ),
      ),
    );
  }
}
