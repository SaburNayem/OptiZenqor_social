import 'package:flutter/material.dart';

class MainShellDrawerItemModel {
  const MainShellDrawerItemModel({
    required this.title,
    required this.icon,
    required this.routeName,
  });

  final String title;
  final IconData icon;
  final String routeName;
}

class MainShellDrawerSectionModel {
  const MainShellDrawerSectionModel({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<MainShellDrawerItemModel> items;
}
