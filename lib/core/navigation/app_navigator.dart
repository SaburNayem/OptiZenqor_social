import 'package:flutter/material.dart';

class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    final String resolved = _withParameters(routeName, parameters);
    return _navigator!.pushNamed<T>(resolved, arguments: arguments);
  }

  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    final String resolved = _withParameters(routeName, parameters);
    return _navigator!.pushReplacementNamed<T, TO>(resolved, arguments: arguments);
  }

  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    final String resolved = _withParameters(routeName, parameters);
    return _navigator!.pushNamedAndRemoveUntil<T>(
      resolved,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void back<T extends Object?>({T? result}) {
    if (_navigator?.canPop() ?? false) {
      _navigator!.pop<T>(result);
    }
  }

  static Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool showDragHandle = false,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      builder: builder,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
    );
  }

  static void showSnackBar({
    required String title,
    required String message,
  }) {
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            title.isEmpty ? message : '$title: $message',
          ),
        ),
      );
  }

  static String _withParameters(
    String routeName,
    Map<String, String>? parameters,
  ) {
    if (parameters == null || parameters.isEmpty) {
      return routeName;
    }
    final Uri uri = Uri(path: routeName, queryParameters: parameters);
    return uri.toString();
  }
}
