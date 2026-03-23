import 'package:flutter/foundation.dart';

import '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport 'ryimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport 'ryimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../n(import '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mimport 'ryimport '../mimport '../mimport '../mimport '../mimport '../mimport '../mi
import '../controller/events_controller.dart';

class EventsScreen extends StatelessWidget {
  EventsScreen({super.key}) { _controller.load(); }
  final EventsController _controller = EventsController();
  final TextEditingController _title = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [Expanded(child: TextField(controller: _title, decoration: const InputDecoration(hintText: 'Create event'))), IconButton(onPressed: () => _controller.create(_title.text), icon: const Icon(Icons.event_available_outlined))]),
            ..._controller.events.map((e) => Card(child: ListTile(title: Text(e.title), subtitle: Text(e.date.toString()), trailing: FilledButton(onPressed: () => _controller.rsvp(e.id), child: Text(e.rsvped ? 'RSVPed' : 'RSVP'))))),
          ],
        ),
      ),
    );
  }
}
