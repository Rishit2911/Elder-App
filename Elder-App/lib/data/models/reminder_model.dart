import 'package:flutter/material.dart';

enum ReminderType {
  medicine,
  doctor,
  water,
  exercise,
  meal,
  custom,
}

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final ReminderType type;
  final bool isCompleted;
  final Color badgeColor;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.isCompleted = false,
    required this.badgeColor,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    ReminderType? type,
    bool? isCompleted,
    Color? badgeColor,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      badgeColor: badgeColor ?? this.badgeColor,
    );
  }

  IconData get icon {
    switch (type) {
      case ReminderType.medicine:
        return Icons.medication_rounded;
      case ReminderType.doctor:
        return Icons.calendar_month_rounded;
      case ReminderType.water:
        return Icons.water_drop_rounded;
      case ReminderType.exercise:
        return Icons.directions_walk_rounded;
      case ReminderType.meal:
        return Icons.restaurant_rounded;
      case ReminderType.custom:
        return Icons.notifications_active_rounded;
    }
  }
}

