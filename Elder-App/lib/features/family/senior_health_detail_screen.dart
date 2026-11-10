import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/circular_sos_button.dart';
import '../../data/models/family_member_model.dart';

class SeniorHealthDetailScreen extends StatelessWidget {
  final SeniorProfileModel senior;

  const SeniorHealthDetailScreen({super.key, required this.senior});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${senior.name} Health Record', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Senior profile header card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: AssetImage(senior.photoAsset),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              senior.honorific.isNotEmpty ? '${senior.name} (${senior.honorific})' : senior.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Age: ${senior.age} Years • Blood: ${senior.bloodGroup}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.mintBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                senior.currentMood,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mintGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Upcoming appointment banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softLavenderBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.softLavender.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.softLavender,
                        child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Upcoming Medical Consultation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy)),
                            const SizedBox(height: 3),
                            Text(senior.nextAppointment, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Live Vitals Overview
                const Text('Current Health Readings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTile('Blood Pressure', senior.bloodPressure, Icons.favorite_rounded, const Color(0xFFFF5D7D))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTile('Blood Sugar', senior.bloodSugar, Icons.water_drop_rounded, const Color(0xFF3B82F6))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTile('Resting Heart Rate', senior.heartRate, Icons.speed_rounded, const Color(0xFF10B981))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTile('Oxygen Level', senior.oxygenLevel, Icons.air_rounded, const Color(0xFF06B6D4))),
                  ],
                ),

                const SizedBox(height: 20),

                // Caregiver details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.warmAmberBg,
                        child: Icon(Icons.volunteer_activism_rounded, color: AppColors.warmAmber),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(senior.assignedCaregiverName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.navy)),
                            const Text('Assigned Geriatric Nurse • Seva Care Agency', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded, color: AppColors.primaryBlue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${senior.assignedCaregiverName}...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Activity Timeline
                const Text('Recent Care Activity Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: senior.recentActivities.map((act) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                act,
                                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.navy, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Floating SOS button
          Positioned(
            right: 20,
            bottom: 30,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

