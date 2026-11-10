import 'package:flutter/material.dart';

enum EmergencyType {
  ambulance,
  police,
  family,
  doctor,
  hospital,
}

class SOSContactModel {
  final String id;
  final String name;
  final String role;
  final String phoneNumber;
  final EmergencyType type;
  final bool isPrimary;
  final IconData icon;

  const SOSContactModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.type,
    this.isPrimary = false,
    required this.icon,
  });
}

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String emergencyPhone;
  final bool hasIcu;
  final bool is24x7;
  final double rating;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.emergencyPhone,
    this.hasIcu = true,
    this.is24x7 = true,
    this.rating = 4.8,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String experience;
  final String consultationFee;
  final String availableTime;
  final double rating;
  final String phone;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.experience,
    required this.consultationFee,
    required this.availableTime,
    required this.rating,
    required this.phone,
  });
}

