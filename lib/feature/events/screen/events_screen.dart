import 'package:flutter/material.dart';

import '../controller/events_controller.dart';

class EventsScreen extends StatelessWidget {
  EventsScreen({super.key}) {
    _controller.load();
  }

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _title,
                    decoration: const InputDecoration(hintText: 'Create event'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _controller.create(_title.text);
                    _title.clear();
                  },
                  icon: const Icon(Icons.event_available_outlined),
                ),
              ],
            ),
            ..._controller.events.map(
              (event) => Card(
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.date.toString()),
                  trailing: FilledButton(
                    onPressed: () => _controller.rsvp(event.id),
                    child: Text(event.rsvped ? 'RSVPed' : 'RSVP'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
