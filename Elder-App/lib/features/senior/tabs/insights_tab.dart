import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Insights',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Understand your health vitals at a glance',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 18),

          // IRA AI Health Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.mintBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB8EBC9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.mintGreen,
                      child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'IRA Weekly Health Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '“Dadaji\'s cardiovascular stability has been remarkable this week. Blood pressure has remained consistently within the optimal 118-124 mmHg systolic range. Medication adherence is at 94%.”',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF134E2C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.mintGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health Summary exported to PDF and sent to Dr. Alok Sharma.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.mintGreen),
                  label: const Text(
                    'Share Summary with Doctor',
                    style: TextStyle(color: AppColors.mintGreen, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vitals Metrics Detailed Cards
          _buildMetricDetailCard(
            title: 'Blood Pressure Trend',
            currentValue: '120/80 mmHg',
            status: 'Optimal & Stable',
            statusColor: AppColors.mintGreen,
            icon: Icons.favorite_rounded,
            color: const Color(0xFFFF5D7D),
            weeklyValues: [122, 120, 118, 125, 121, 119, 120],
            unit: 'mmHg',
          ),

          const SizedBox(height: 14),

          _buildMetricDetailCard(
            title: 'Fasting Blood Glucose',
            currentValue: '110 mg/dL',
            status: 'Normal Fasting',
            statusColor: AppColors.primaryBlue,
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF3B82F6),
            weeklyValues: [115, 112, 108, 114, 110, 109, 110],
            unit: 'mg/dL',
          ),

          const SizedBox(height: 14),

          _buildMetricDetailCard(
            title: 'Resting Heart Rate',
            currentValue: '72 bpm',
            status: 'Good Rhythm',
            statusColor: AppColors.mintGreen,
            icon: Icons.speed_rounded,
            color: const Color(0xFF10B981),
            weeklyValues: [70, 74, 71, 73, 72, 70, 72],
            unit: 'bpm',
          ),

          const SizedBox(height: 14),

          _buildMetricDetailCard(
            title: 'Weight Tracking',
            currentValue: '68.5 kg',
            status: 'Healthy BMI: 22.4',
            statusColor: AppColors.navyMuted,
            icon: Icons.monitor_weight_rounded,
            color: const Color(0xFF8B5CF6),
            weeklyValues: [68.8, 68.7, 68.6, 68.6, 68.5, 68.5, 68.5],
            unit: 'kg',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDetailCard({
    required String title,
    required String currentValue,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color color,
    required List<double> weeklyValues,
    required String unit,
  }) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withAlpha(30),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currentValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Visual Weekly Trend Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyValues.length, (i) {
              final double heightPct = (weeklyValues[i] - 50) / 100;
              final double barHeight = (heightPct.clamp(0.2, 1.0)) * 50;

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: i == weeklyValues.length - 1
                          ? color
                          : color.withAlpha(70),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == weeklyValues.length - 1
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: i == weeklyValues.length - 1
                          ? AppColors.navy
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
