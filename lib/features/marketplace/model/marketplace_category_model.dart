import 'package:flutter/material.dart';

class MarketplaceCategoryModel {
  const MarketplaceCategoryModel({
    required this.name,
    required this.icon,
    required this.subcategories,
    this.isFollowed = false,
  });

  final String name;
  final IconData icon;
  final List<String> subcategories;
  final bool isFollowed;

  MarketplaceCategoryModel copyWith({bool? isFollowed}) {
    return MarketplaceCategoryModel(
      name: name,
      icon: icon,
      subcategories: subcategories,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
