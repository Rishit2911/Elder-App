import 'package:flutter/material.dart';

enum DoseTiming {
  morning,
  afternoon,
  evening,
  night,
}

class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String dosage;
  final int remainingQuantity;
  final int totalCapacity;
  final DoseTiming primaryTiming;
  final String scheduleTime;
  final String instructions; // e.g. "Take after breakfast with water"
  final Color pillColor;
  final Color liquidTint;
  final bool isTakenToday;
  final DateTime? lastTakenAt;
  final bool needsRefill;
  final List<String> history;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.remainingQuantity,
    this.totalCapacity = 30,
    required this.primaryTiming,
    required this.scheduleTime,
    required this.instructions,
    required this.pillColor,
    required this.liquidTint,
    this.isTakenToday = false,
    this.lastTakenAt,
    this.needsRefill = false,
    this.history = const [],
  });

  MedicineModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? dosage,
    int? remainingQuantity,
    int? totalCapacity,
    DoseTiming? primaryTiming,
    String? scheduleTime,
    String? instructions,
    Color? pillColor,
    Color? liquidTint,
    bool? isTakenToday,
    DateTime? lastTakenAt,
    bool? needsRefill,
    List<String>? history,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dosage: dosage ?? this.dosage,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      primaryTiming: primaryTiming ?? this.primaryTiming,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      instructions: instructions ?? this.instructions,
      pillColor: pillColor ?? this.pillColor,
      liquidTint: liquidTint ?? this.liquidTint,
      isTakenToday: isTakenToday ?? this.isTakenToday,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
      needsRefill: needsRefill ?? this.needsRefill,
      history: history ?? this.history,
    );
  }

  String get timingLabel {
    switch (primaryTiming) {
      case DoseTiming.morning:
        return 'Morning';
      case DoseTiming.afternoon:
        return 'Afternoon';
      case DoseTiming.evening:
        return 'Evening';
      case DoseTiming.night:
        return 'Night';
    }
  }

  IconData get timingIcon {
    switch (primaryTiming) {
      case DoseTiming.morning:
        return Icons.wb_sunny_rounded;
      case DoseTiming.afternoon:
        return Icons.wb_twilight_rounded;
      case DoseTiming.evening:
        return Icons.nights_stay_rounded;
      case DoseTiming.night:
        return Icons.bedtime_rounded;
    }
  }
}

