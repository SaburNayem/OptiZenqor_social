import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/data/service/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();
  Bloc.observer = AppBlocObserver();
  runApp(const OptiZenqorApp());
}
