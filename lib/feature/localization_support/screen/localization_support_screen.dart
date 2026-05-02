import 'package:flutter/material.dart';

import '../controller/localization_support_controller.dart';

class LocalizationSupportScreen extends StatelessWidget {
  LocalizationSupportScreen({super.key});

  final LocalizationSupportController _controller =
      LocalizationSupportController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Localization Support')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_controller.errorMessage!),
                      ),
                    if (_controller.locales.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.language_outlined),
                        title: Text('No locales are available right now.'),
                      ),
                    ..._controller.locales.map(
                      (locale) => ListTile(
                        title: Text(locale.label),
                        trailing: Icon(
                          _controller.selected == locale.localeCode
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        onTap: () => _controller.setLocale(locale.localeCode),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
