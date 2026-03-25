import 'package:flutter/material.dart';

class SettingsItemModel {
  const SettingsItemModel({
    required this.title,
<<<<<<< HEAD
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
=======
    required this.icon,
    this.routeName,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? routeName;
  final String? subtitle;
>>>>>>> 08433d8 (update)
}
