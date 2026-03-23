import 'package:flutter/material.dart';

import '../controller/support_help_controller.dart';

class SupportHelpScreen extends StatelessWidget {
  SupportHelpScreen({super.key}) {
    _controller.load();
  }

  final SupportHelpController _controller = SupportHelpController();
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Help')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700)),
            ..._controller.faqs.map(
              (faq) => ExpansionTile(
                title: Text(faq.question),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(faq.answer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subject,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support request submitted')),
                );
                _subject.clear();
                _message.clear();
              },
              child: const Text('Send'),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.bug_report_outlined),
                    title: Text('Feedback / report bug screen'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.new_releases_outlined),
                    title: Text('Changelog screen'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.flag_outlined),
                    title: Text('Remote config placeholder'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.toggle_on_outlined),
                    title: Text('Feature flag placeholder'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.health_and_safety_outlined),
                    title: Text('Crash reporting placeholder'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
