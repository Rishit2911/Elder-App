import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circular_sos_button.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_api_service.dart';
import '../../auth/login_screen.dart';
import '../../caregiver/caregiver_dashboard_screen.dart';
import '../../family/family_dashboard_screen.dart';

class SeniorSettingsScreen extends StatefulWidget {
  const SeniorSettingsScreen({super.key});

  @override
  State<SeniorSettingsScreen> createState() => _SeniorSettingsScreenState();
}

class _SeniorSettingsScreenState extends State<SeniorSettingsScreen> {
  bool _largeTextEnabled = true;
  bool _voiceAnnouncements = true;
  bool _fallDetectionActive = true;
  String _selectedLanguage = 'English / हिंदी';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Senior User Profile Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryBlue, width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/dadaji_profile.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.elderly_rounded,
                              size: 44,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ramesh Sharma (Dadaji)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Age 74 • Blood Group B+',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Elderly Seva ID: ES-74921',
                              style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // SWITCH PERSONA QUICK ACCESS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Switch Application Role',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Switch between the three persona interfaces for client evaluation.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.familyRole,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FamilyDashboardScreen()),
                                );
                              },
                              icon: const Icon(Icons.family_restroom_rounded, size: 16),
                              label: const Text('Family View', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.caregiverRole,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
                                );
                              },
                              icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
                              label: const Text('Caregiver View', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Accessibility Settings
                const Text(
                  'Senior Accessibility & Preferences',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _largeTextEnabled,
                        activeThumbColor: AppColors.primaryBlue,
                        title: const Text('Senior Large Text Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Enlarges text elements across all views for comfortable reading'),
                        onChanged: (val) {
                          setState(() {
                            _largeTextEnabled = val;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: _voiceAnnouncements,
                        activeThumbColor: AppColors.primaryBlue,
                        title: const Text('Voice Reminders & Readout', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Reads aloud medication timings and appointments via IRA'),
                        onChanged: (val) {
                          setState(() {
                            _voiceAnnouncements = val;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: _fallDetectionActive,
                        activeThumbColor: AppColors.coralRed,
                        title: const Text('Automatic Fall Detection', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Alerts emergency contacts if a sudden fall is detected'),
                        onChanged: (val) {
                          setState(() {
                            _fallDetectionActive = val;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(_selectedLanguage),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language toggle: English / हिंदी')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Log out button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coralRed,
                      side: const BorderSide(color: AppColors.coralRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await AuthApiService().clearSession();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.senior)),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          // Floating circular SOS
          Positioned(
            right: 20,
            bottom: 30,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }
}
