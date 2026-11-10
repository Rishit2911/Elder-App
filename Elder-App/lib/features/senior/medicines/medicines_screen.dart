import 'package:flutter/material.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/repositories/app_mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circular_sos_button.dart';
import '../../../core/widgets/custom_button.dart';
import 'widgets/transparent_bottle_widget.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  late List<MedicineModel> medicines;
  int selectedBottleIndex = 0;

  @override
  void initState() {
    super.initState();
    medicines = List.from(AppMockData.initialThreeBottles);
  }

  void _markAsTaken(int index) {
    setState(() {
      final current = medicines[index];
      final newQuantity = current.remainingQuantity > 0
          ? current.remainingQuantity - 1
          : 0;
      medicines[index] = current.copyWith(
        isTakenToday: true,
        remainingQuantity: newQuantity,
        lastTakenAt: DateTime.now(),
        needsRefill: newQuantity <= 8,
        history: [
          'Taken today at ${_formatCurrentTime()}',
          ...current.history,
        ],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marked ${medicines[index].name} as taken! Adherence recorded.',
        ),
        backgroundColor: AppColors.mintGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _requestRefill(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.local_pharmacy_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            const Text('Refill Request', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Text(
          'A refill request for "${medicines[index].name}" (${medicines[index].dosage}) will be sent to your primary family contact and partnered pharmacy.\n\n[Backend Integration Point: POST /api/v1/medicines/refill]',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(110, 42),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refill request notified to family & pharmacy!'),
                  backgroundColor: AppColors.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Refill'),
          ),
        ],
      ),
    );
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMed = medicines[selectedBottleIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Medicines', style: AppTextStyles.titleLarge),
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
                // Top introduction card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryBlue,
                        radius: 22,
                        child: Icon(Icons.medication_liquid_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prescribed Daily Regimen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '3 individual transparent containers. Tap a bottle to review and log dosage.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.navyMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 8 REQUIREMENT:
                // "Design a dedicated medicine-management interface containing exactly three separate transparent medicine bottles."
                const Text(
                  'Active Medicine Bottles (3)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),

                // ROW OF EXACTLY THREE TRANSPARENT MEDICINE CONTAINERS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(medicines.length, (index) {
                    final med = medicines[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < medicines.length - 1 ? 10.0 : 0.0,
                        ),
                        child: TransparentBottleWidget(
                          medicine: med,
                          isSelected: selectedBottleIndex == index,
                          onTap: () {
                            setState(() {
                              selectedBottleIndex = index;
                            });
                          },
                          onMarkTaken: () => _markAsTaken(index),
                          onRefillRequest: () => _requestRefill(index),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // SELECTED MEDICINE DETAILS PANEL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selectedMed.pillColor.withAlpha(80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selectedMed.pillColor.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              selectedMed.timingIcon,
                              color: selectedMed.pillColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedMed.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  selectedMed.genericName,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: selectedMed.isTakenToday
                                  ? AppColors.mintBg
                                  : AppColors.cyanBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              selectedMed.isTakenToday ? 'Taken' : 'Scheduled',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selectedMed.isTakenToday
                                  ? AppColors.mintGreen
                                  : AppColors.cyanAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 28),

                      // Schedule info grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStat(
                              icon: Icons.access_time_filled_rounded,
                              label: 'Timing',
                              value: selectedMed.scheduleTime,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailStat(
                              icon: Icons.scale_rounded,
                              label: 'Dosage',
                              value: selectedMed.dosage,
                              color: selectedMed.pillColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStat(
                              icon: Icons.inventory_2_rounded,
                              label: 'Remaining',
                              value: '${selectedMed.remainingQuantity} Tablets',
                              color: selectedMed.needsRefill
                                  ? AppColors.coralRed
                                  : AppColors.mintGreen,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailStat(
                              icon: Icons.calendar_today_rounded,
                              label: 'Refill Due',
                              value: selectedMed.needsRefill ? 'Now' : 'In 12 days',
                              color: selectedMed.needsRefill
                                  ? AppColors.coralRed
                                  : AppColors.navyMuted,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Instructions Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 18, color: AppColors.navyMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedMed.instructions,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomButton(
                              label: selectedMed.isTakenToday
                                  ? 'Marked as Taken'
                                  : 'Mark as Taken',
                              icon: selectedMed.isTakenToday
                                  ? Icons.check_circle_rounded
                                  : Icons.check_rounded,
                              backgroundColor: selectedMed.isTakenToday
                                  ? AppColors.mintGreen
                                  : AppColors.primaryBlue,
                              onPressed: selectedMed.isTakenToday
                                  ? null
                                  : () => _markAsTaken(selectedBottleIndex),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: CustomButton(
                              label: 'Refill',
                              icon: Icons.local_pharmacy_rounded,
                              isOutlined: true,
                              backgroundColor: AppColors.primaryBlue,
                              onPressed: () => _requestRefill(selectedBottleIndex),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // History log
                      const Text(
                        'Dose History & Adherence',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedMed.history.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: selectedMed.pillColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Circular Floating SOS Button
          Positioned(
            right: 20,
            bottom: 30,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

