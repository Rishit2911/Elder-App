import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/native_biometric_service.dart';
import '../auth/login_screen.dart';
import '../auth/registration_screen.dart';
import '../caregiver/caregiver_dashboard_screen.dart';
import '../family/family_dashboard_screen.dart';
import '../senior/senior_dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserModel? _savedUser;
  bool _hasSavedSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  Future<void> _checkAutoLogin() async {
    final api = AuthApiService();
    final hasSession = await api.restoreSession();
    if (!hasSession || !mounted) return;

    final user = api.currentUser;
    if (user == null) return;

    setState(() {
      _savedUser = user;
      _hasSavedSession = true;
    });

    _promptBiometricsAndNavigate(user);
  }

  Future<void> _promptBiometricsAndNavigate(UserModel user) async {
    // Trigger Native Phone Biometrics (Face ID / Fingerprint / Device PIN Fallback)
    final authenticated = await NativeBiometricService().authenticate(
      reason: 'Welcome back ${user.fullName}! Authenticate to unlock Elderly Seva.',
    );

    if (!authenticated || !mounted) return;

    Widget destination;
    switch (user.role) {
      case UserRole.senior:
        destination = const SeniorDashboardScreen();
        break;
      case UserRole.family:
        destination = const FamilyDashboardScreen();
        break;
      case UserRole.caregiver:
        destination = const CaregiverDashboardScreen();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8), // Soft warm welcoming background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // Top Brand Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.primaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ELDERLY SEVA',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Caring for Loved Ones, Together',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Existing Welcome Illustration from Project Assets
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Image.asset(
                    'assets/images/elderly_seva_welcome.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 80,
                              color: AppColors.coralRed.withAlpha(150),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Elderly Seva Care',
                              style: AppTextStyles.titleLarge,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Welcome Text & Action Flow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x120D2F60),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to Elderly Seva',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A unified elderly care platform supporting senior citizens, their families, and dedicated caregivers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),

                  if (_hasSavedSession && _savedUser != null) ...[
                    // One-Tap Native Biometric Quick Unlock for Returning Senior/User
                    CustomButton(
                      label: 'Unlock as ${_savedUser!.fullName}',
                      icon: Icons.fingerprint_rounded,
                      height: 56,
                      borderRadius: 18,
                      backgroundColor: AppColors.mintGreen,
                      foregroundColor: AppColors.navy,
                      onPressed: () => _promptBiometricsAndNavigate(_savedUser!),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Sign in to Another Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: Color(0xFF28548A), width: 1.2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Prominent Get Started Button -> Connects to Login & Registration
                    CustomButton(
                      label: 'Get Started',
                      height: 56,
                      borderRadius: 18,
                      backgroundColor: const Color(0xFF28548A),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Secondary Registration Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New to Elderly Seva? ',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

