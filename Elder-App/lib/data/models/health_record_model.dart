import 'package:flutter/material.dart';

class HealthMetric {
  final String label;
  final String value;
  final String unit;
  final String status; // Normal, Optimal, Attention
  final Color statusColor;
  final IconData icon;
  final List<double> weeklyTrend;

  const HealthMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.weeklyTrend,
  });
}

class HealthRecordModel {
  final String seniorId;
  final String lastUpdated;
  final HealthMetric bloodPressure;
  final HealthMetric bloodSugar;
  final HealthMetric heartRate;
  final HealthMetric oxygenLevel;
  final HealthMetric weight;
  final String aiSummary;

  const HealthRecordModel({
    required this.seniorId,
    required this.lastUpdated,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.heartRate,
    required this.oxygenLevel,
    required this.weight,
    required this.aiSummary,
  });
}

