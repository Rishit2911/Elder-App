import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/circular_sos_button.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/caregiver_model.dart';

class VisitDetailScreen extends StatefulWidget {
  final CareVisitModel visit;

  const VisitDetailScreen({super.key, required this.visit});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.visit.notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.visit.seniorName} Visit', style: AppTextStyles.titleLarge),
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
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.visit.seniorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.cyanBg, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Authorized Client', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.cyanAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Address: ${widget.visit.address}', style: AppTextStyles.bodySmall),
                      Text('Schedule: ${widget.visit.scheduledDate} • ${widget.visit.scheduledTime}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text('Physician Care Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmAmberBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warmAmber.withAlpha(50)),
                  ),
                  child: Text(
                    widget.visit.careInstructions,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.navy),
                  ),
                ),

                const SizedBox(height: 20),

                const Text('Caregiver Visit Notes & Observations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Record vitals readings, senior mood, food/hydration intake, or special observations...',
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  label: 'Submit & Sign Off Care Report',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: AppColors.mintGreen,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Care report submitted & verified! [PATCH /api/v1/caregiver/visits]'),
                        backgroundColor: AppColors.mintGreen,
                      ),
                    );
                    Navigator.pop(context);
                  },
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

