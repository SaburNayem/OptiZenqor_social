import 'package:flutter/material.dart';

import 'app.dart';
import 'core/data/service/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();
  runApp(const OptiZenqorApp());
}
