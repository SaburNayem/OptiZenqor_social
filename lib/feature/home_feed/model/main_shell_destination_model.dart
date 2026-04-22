import 'package:flutter/material.dart';

class MainShellDestinationModel {
  const MainShellDestinationModel({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.title,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String title;
}
