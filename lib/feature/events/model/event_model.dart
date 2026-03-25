import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String date;
  final String time;
  final String location;
  final double price;
  final List<String> attendeeAvatars;
  final int attendeeCount;

  const EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.attendeeAvatars,
    required this.attendeeCount,
  });
}

class CalendarDateModel {
  final String dayName;
  final String dayNumber;
  final bool isSelected;

  const CalendarDateModel({
    required this.dayName,
    required this.dayNumber,
    this.isSelected = false,
  });
}
