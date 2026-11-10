import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../doctor/doctor_consultation_screen.dart';
import '../caregiver_booking/book_caregiver_screen.dart';
import '../hospitals/nearby_hospitals_screen.dart';
import '../assistant/ai_assistant_screen.dart';
import '../profile/senior_settings_screen.dart';
import '../../caregiver/caregiver_dashboard_screen.dart';
import '../../family/family_dashboard_screen.dart';
import '../../auth/login_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More Services',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete care ecosystem & preferences',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 18),

          // Switch Persona Card for Client Review
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
                const Text(
                  'Switch User Role (Evaluation)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preview the application from Family Member or Caregiver perspectives.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
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
                    const SizedBox(width: 10),
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

          const SizedBox(height: 18),

          _buildServiceTile(
            title: 'Book a Caregiver',
            subtitle: 'Request agency-managed healthcare assistants',
            icon: Icons.volunteer_activism_rounded,
            iconColor: AppColors.warmAmber,
            bgColor: AppColors.warmAmberBg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookCaregiverScreen()),
              );
            },
          ),

          _buildServiceTile(
            title: 'Nearby Hospitals & Emergency',
            subtitle: 'Browse 24x7 emergency medical centers',
            icon: Icons.local_hospital_rounded,
            iconColor: AppColors.primaryBlue,
            bgColor: const Color(0xFFE6F0FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen()),
              );
            },
          ),

          _buildServiceTile(
            title: 'Talk to a Doctor',
            subtitle: 'Schedule video consultation with a specialist',
            icon: Icons.medical_services_rounded,
            iconColor: const Color(0xFF673AB7),
            bgColor: AppColors.softLavenderBg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorConsultationScreen()),
              );
            },
          ),

          _buildServiceTile(
            title: 'Ask IRA AI Assistant',
            subtitle: 'Voice-enabled healthcare & reminder assistant',
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.mintGreen,
            bgColor: AppColors.mintBg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
              );
            },
          ),

          _buildServiceTile(
            title: 'Elderly Seva Care Membership',
            subtitle: 'Explore 24x7 emergency & doctor coverage plans',
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Elderly Seva Gold Care Plan Active • 24x7 Emergency Concierge Included')),
              );
            },
          ),

          _buildServiceTile(
            title: 'Profile & Settings',
            subtitle: 'Accessibility, fall detection, language and font size',
            icon: Icons.settings_rounded,
            iconColor: AppColors.navy,
            bgColor: AppColors.primaryLight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeniorSettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 14),

          // Log out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coralRed,
                side: const BorderSide(color: AppColors.coralRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.senior)),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}

