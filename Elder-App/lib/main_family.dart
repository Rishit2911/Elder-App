import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/family/family_dashboard_screen.dart';
import 'features/emergency/emergency_sos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FamilyOnlyApp());
}

class FamilyOnlyApp extends StatelessWidget {
  const FamilyOnlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Seva - Family Member Portal',
      theme: AppTheme.lightTheme,
      home: const FamilyDashboardScreen(),
      routes: {
        '/family-dashboard': (context) => const FamilyDashboardScreen(),
        '/emergency-sos': (context) => const EmergencySosScreen(),
      },
    );
  }
}

