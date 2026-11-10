import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/welcome/welcome_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/registration_screen.dart';
import 'features/senior/senior_dashboard_screen.dart';
import 'features/senior/medicines/medicines_screen.dart';
import 'features/senior/doctor/doctor_consultation_screen.dart';
import 'features/senior/caregiver_booking/book_caregiver_screen.dart';
import 'features/senior/hospitals/nearby_hospitals_screen.dart';
import 'features/senior/assistant/ai_assistant_screen.dart';
import 'features/senior/profile/senior_settings_screen.dart';
import 'features/family/family_dashboard_screen.dart';
import 'features/caregiver/caregiver_dashboard_screen.dart';
import 'features/emergency/emergency_sos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElderlySevaApp());
}

class ElderlySevaApp extends StatelessWidget {
  const ElderlySevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Seva',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/senior-dashboard': (context) => const SeniorDashboardScreen(),
        '/family-dashboard': (context) => const FamilyDashboardScreen(),
        '/caregiver-dashboard': (context) => const CaregiverDashboardScreen(),
        '/emergency-sos': (context) => const EmergencySosScreen(),
        '/medicines': (context) => const MedicinesScreen(),
        '/doctor': (context) => const DoctorConsultationScreen(),
        '/caregiver-booking': (context) => const BookCaregiverScreen(),
        '/hospitals': (context) => const NearbyHospitalsScreen(),
        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/settings': (context) => const SeniorSettingsScreen(),
      },
    );
  }
}
