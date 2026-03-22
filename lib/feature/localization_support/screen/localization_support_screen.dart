import 'package:flutter/material.dart';

import '../controller/localization_support_controller.dart';

class LocalizationSupportScreen extends StatefulWidget {
  const LocalizationSupportScreen({super.key});

  @override
  State<LocalizationSupportScreen> createState() =>
      _LocalizationSupportScreenState();
}

class _LocalizationSupportScreenState extends State<LocalizationSupportScreen> {
  final LocalizationSupportController _controller = LocalizationSupportController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Localization Support')),
          body: ListView(
            children: _controller.locales
                .map(
                  (locale) => ListTile(
                    title: Text(locale.label),
                    trailing: Icon(
                      _controller.selected == locale.localeCode
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    onTap: () => _controller.setLocale(locale.localeCode),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
