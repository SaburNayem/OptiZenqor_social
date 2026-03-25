import 'package:flutter/material.dart';

class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.postedTime,
    required this.logoColor,
    required this.logoInitial,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String postedTime;
  final Color logoColor;
  final String logoInitial;
}
