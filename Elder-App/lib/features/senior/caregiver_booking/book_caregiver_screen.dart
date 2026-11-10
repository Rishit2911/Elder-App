import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circular_sos_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/repositories/app_mock_data.dart';

class BookCaregiverScreen extends StatefulWidget {
  const BookCaregiverScreen({super.key});

  @override
  State<BookCaregiverScreen> createState() => _BookCaregiverScreenState();
}

class _BookCaregiverScreenState extends State<BookCaregiverScreen> {
  String _selectedCareType = 'Daily Living & Mobility';
  String _selectedDuration = '4 Hours / Day';
  final TextEditingController _specialNotesController = TextEditingController();

  final List<String> careTypes = [
    'Daily Living & Mobility',
    'Post-Surgery Nursing Care',
    'Dementia & Memory Support',
    'Night-time Attendant',
    'Companionship & Meal Prep',
  ];

  final List<String> durations = [
    '2 Hours / Day',
    '4 Hours / Day',
    '8 Hours / Day',
    '24x7 Live-in Care',
  ];

  @override
  void dispose() {
    _specialNotesController.dispose();
    super.dispose();
  }

  void _submitCareRequest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            const Text('Request Submitted', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your care request has been routed to Seva Care Agency coordinator.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text('Care Type: $_selectedCareType', style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('Duration: $_selectedDuration', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
              'Agency manager will call your family contact within 30 minutes to confirm caregiver matching.\n\n[Backend: POST /api/v1/caregiver/requests]',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = AppMockData.caregiverProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book a Caregiver', style: AppTextStyles.titleLarge),
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
                // Agency Info Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.warmAmberBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.warmAmber.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.warmAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seva Care Agency Network',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '100% Background-verified, certified, and insured senior healthcare assistants.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Featured Caregiver Profile
                const Text(
                  'Assigned Senior Care Specialist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 10),

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
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caregiver.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                                Text(
                                  caregiver.certification,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  caregiver.experience,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mintBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mintGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: caregiver.specialities.map((spec) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              spec,
                              style: const TextStyle(fontSize: 11, color: AppColors.navyMuted),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Select Care Type
                const Text(
                  'Select Care Plan Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),

                ...careTypes.map((type) {
                  final isSelected = _selectedCareType == type;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCareType = type;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Duration Selector
                const Text(
                  'Required Shift Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: durations.map((dur) {
                    final isSelected = _selectedDuration == dur;
                    return ChoiceChip(
                      label: Text(dur),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDuration = dur;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Submit Request Button
                CustomButton(
                  label: 'Request Caregiver Matching',
                  icon: Icons.send_rounded,
                  height: 56,
                  borderRadius: 18,
                  onPressed: _submitCareRequest,
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
}

