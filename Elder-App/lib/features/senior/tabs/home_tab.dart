import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/repositories/app_mock_data.dart';
import '../medicines/medicines_screen.dart';
import '../medicines/widgets/transparent_bottle_widget.dart';
import '../doctor/doctor_consultation_screen.dart';
import '../caregiver_booking/book_caregiver_screen.dart';
import '../hospitals/nearby_hospitals_screen.dart';
import '../assistant/ai_assistant_screen.dart';
import '../profile/senior_settings_screen.dart';
import '../../emergency/emergency_sos_screen.dart';

class HomeTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late List<MedicineModel> medicines;

  @override
  void initState() {
    super.initState();
    medicines = AppMockData.initialThreeBottles;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1 & 2. Personalized Greeting & Daily Information
          _buildHeader(context),

          const SizedBox(height: 18),

          // 9. Prominent Emergency SOS Banner
          _buildEmergencySOSSection(context),

          const SizedBox(height: 18),

          // 3. My Family Section (Compact Card with Call/Message shortcuts)
          _buildFamilySection(context),

          const SizedBox(height: 18),

          // 4. My Medicines Section (SHOWING THE THREE SEPARATE TRANSPARENT BOTTLES)
          _buildMedicinesSection(context),

          const SizedBox(height: 18),

          // 5. Health Tracker Section (Clean consistent metrics grid)
          _buildHealthTrackerSection(context),

          const SizedBox(height: 18),

          // 6 & 7. Equal 2-Column Row: Talk to a Doctor & Book a Caregiver
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  context: context,
                  title: 'Talk to a Doctor',
                  subtitle: 'Video call or clinic visit',
                  icon: Icons.medical_services_rounded,
                  iconColor: const Color(0xFF2563EB),
                  backgroundColor: AppColors.softLavenderBg,
                  borderColor: const Color(0xFFD6E4FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorConsultationScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceCard(
                  context: context,
                  title: 'Book a Caregiver',
                  subtitle: 'Certified nursing support',
                  icon: Icons.volunteer_activism_rounded,
                  iconColor: const Color(0xFFE65100),
                  backgroundColor: AppColors.warmAmberBg,
                  borderColor: const Color(0xFFFFE0B2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookCaregiverScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 8. Nearby Hospitals Card (Equal horizontal alignment)
          _buildFullWidthServiceCard(
            context: context,
            title: 'Nearby Hospitals',
            subtitle: 'Find emergency trauma centers within 5 miles',
            icon: Icons.local_hospital_rounded,
            iconColor: AppColors.primaryBlue,
            backgroundColor: const Color(0xFFE6F0FF),
            borderColor: const Color(0xFFCCE0FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen()),
              );
            },
          ),

          const SizedBox(height: 18),

          // 10. IRA AI Assistant Section
          _buildAIAssistantSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeniorSettingsScreen()),
            );
          },
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF90CAF9),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withAlpha(20),
                  blurRadius: 8,
                ),
              ],
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
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'नमस्ते दादाजी',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.mintGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Feeling healthy & active today',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeniorSettingsScreen()),
            );
          },
          icon: const Icon(
            Icons.settings_suggest_rounded,
            color: AppColors.navy,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySOSSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.coralRed,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.coralRed.withAlpha(90),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencySosScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.coralRed,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMERGENCY HELP',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '1-Tap alert to family, ambulance & doctors',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWarm,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF3E5C7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            widget.onNavigateTab?.call(3); // Switch to My Family tab
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/family_illustration.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.family_restroom_rounded,
                      size: 50,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Family (4 Members)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rajesh & Priya active • Tap to view all',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.medication_liquid_rounded, color: AppColors.primaryBlue, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'My Medicines',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicinesScreen()),
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Manage (3 Bottles)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // REQUIREMENT 8: "Design a dedicated medicine-management interface containing exactly three separate transparent medicine bottles."
          // Display the 3 transparent medicine containers right on the dashboard!
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(medicines.length, (index) {
              final med = medicines[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < medicines.length - 1 ? 8.0 : 0.0,
                  ),
                  child: TransparentBottleWidget(
                    medicine: med,
                    isSelected: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicinesScreen()),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrackerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.monitor_heart_rounded, color: AppColors.coralRed, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Health Tracker',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  widget.onNavigateTab?.call(2); // Insights tab
                },
                child: const Text('View Insights', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildHealthTile(
                  title: 'Blood Pressure',
                  value: '120/80',
                  unit: 'mmHg',
                  status: 'Normal',
                  statusColor: AppColors.mintGreen,
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFFF5D7D),
                  bgColor: const Color(0xFFFFF0F3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHealthTile(
                  title: 'Blood Sugar',
                  value: '110',
                  unit: 'mg/dL',
                  status: 'Fasting',
                  statusColor: AppColors.primaryBlue,
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildHealthTile(
                  title: 'Heart Rate',
                  value: '72',
                  unit: 'bpm',
                  status: 'Resting',
                  statusColor: AppColors.mintGreen,
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHealthTile(
                  title: 'Oxygen SpO2',
                  value: '98',
                  unit: '%',
                  status: 'Optimal',
                  statusColor: AppColors.cyanAccent,
                  icon: Icons.air_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  bgColor: const Color(0xFFECFEFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTile({
    required String title,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: iconColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryBlue, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAssistantSection(BuildContext context) {
    return Material(
      color: AppColors.mintBg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFB8EBC9)),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.mintGreen,
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meet IRA AI Assistant',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tap to ask about medicines, vitals or talk',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.mic_rounded,
                color: Color(0xFF1E6C47),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
