import 'package:flutter/material.dart';

import '../../home_feed/screen/main_shell_screen.dart' as home_shell;

class AppMainShellScreen extends StatelessWidget {
  const AppMainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrapper to keep a dedicated main_shell feature while reusing existing shell implementation.
    return home_shell.MainShellScreen();
  }
}
