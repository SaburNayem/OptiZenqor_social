import 'package:flutter/material.dart';

import '../functions/app_feedback.dart';
import 'app_navigator.dart';

class SnackPosition {
  const SnackPosition._();

  static const SnackPosition top = SnackPosition._();
  static const SnackPosition bottom = SnackPosition._();
}

class AppGet {
  AppGet._();

  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    return AppNavigator.toNamed<T>(
      routeName,
      parameters: parameters,
      arguments: arguments,
    );
  }

  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    return AppNavigator.offNamed<T, TO>(
      routeName,
      parameters: parameters,
      arguments: arguments,
    );
  }

  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    Map<String, String>? parameters,
    Object? arguments,
  }) {
    return AppNavigator.offAllNamed<T>(
      routeName,
      parameters: parameters,
      arguments: arguments,
    );
  }

  static void back<T extends Object?>({T? result}) {
    AppNavigator.back<T>(result: result);
  }

  static Future<T?> bottomSheet<T>(
    Widget bottomSheet, {
    bool isScrollControlled = false,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return AppNavigator.showBottomSheet<T>(
      builder: (_) => bottomSheet,
      isScrollControlled: isScrollControlled,
    );
  }

  static void snackbar(String title, String message, {Object? snackPosition}) {
    AppFeedback.showSnackbar(title: title, message: message);
  }
}
