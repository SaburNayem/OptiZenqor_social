import 'package:flutter/material.dart';

class SettingsItemModel {
  const SettingsItemModel({
    required this.title,
    this.subtitle,
    this.icon,
    this.routeName,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? routeName;
  final bool isDestructive;
}
