import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/app_mock_data.dart';
import '../medicines/medicines_screen.dart';
import '../medicines/widgets/transparent_bottle_widget.dart';

class RemindersTab extends StatefulWidget {
  const RemindersTab({super.key});

  @override
  State<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends State<RemindersTab> {
  late List<ReminderModel> reminders;
  late List<MedicineModel> medicineBottles;

  @override
  void initState() {
    super.initState();
    reminders = List.from(AppMockData.dailyReminders);
    medicineBottles = AppMockData.initialThreeBottles;
  }

  void _toggleReminder(int index) {
    setState(() {
      final item = reminders[index];
      reminders[index] = item.copyWith(isCompleted: !item.isCompleted);
    });

    final updated = reminders[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isCompleted
              ? 'Great job! "${updated.title}" marked as completed.'
              : '"${updated.title}" reset to pending.',
        ),
        backgroundColor: updated.isCompleted ? AppColors.mintGreen : AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '06:00 PM');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Daily Reminder', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                hintText: 'e.g. Evening walk in park',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Scheduled Time',
                hintText: 'e.g. 06:00 PM',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '[Backend: POST /api/v1/seniors/{id}/reminders]',
              style: TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  reminders.add(
                    ReminderModel(
                      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      description: 'Custom personal activity',
                      time: timeController.text.trim(),
                      type: ReminderType.custom,
                      badgeColor: AppColors.softLavenderBg,
                    ),
                  );
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = reminders.where((r) => r.isCompleted).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminders',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Never miss your medicines or routines',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.all(10),
                ),
                icon: const Icon(Icons.add_rounded, color: AppColors.primaryBlue, size: 26),
                onPressed: _showAddReminderDialog,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Progress overview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Progress ($completedCount of ${reminders.length} completed)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      '${((completedCount / (reminders.isEmpty ? 1 : reminders.length)) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mintGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: reminders.isEmpty ? 0 : completedCount / reminders.length,
                    minHeight: 10,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Medicine Bottles Section (Requirement 5: display exactly three separate medicine bottles)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
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
                        Icon(Icons.medication_liquid_rounded, color: AppColors.primaryBlue, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'My Medicine Bottles (3)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MedicinesScreen()),
                        );
                      },
                      child: const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(medicineBottles.length, (index) {
                    final med = medicineBottles[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < medicineBottles.length - 1 ? 8.0 : 0.0,
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
          ),

          const SizedBox(height: 20),

          ...List.generate(reminders.length, (index) {
            final reminder = reminders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: reminder.isCompleted
                      ? AppColors.mintGreen.withAlpha(100)
                      : AppColors.cardBorder,
                  width: reminder.isCompleted ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: reminder.isCompleted
                      ? AppColors.mintBg
                      : reminder.badgeColor,
                  child: Icon(
                    reminder.icon,
                    color: reminder.isCompleted
                        ? AppColors.mintGreen
                        : AppColors.primaryBlue,
                  ),
                ),
                title: Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: reminder.isCompleted
                        ? AppColors.textSecondary
                        : AppColors.navy,
                    decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(reminder.description, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 14, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          reminder.time,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Checkbox(
                  value: reminder.isCompleted,
                  activeColor: AppColors.mintGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onChanged: (val) => _toggleReminder(index),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

