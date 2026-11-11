import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/circular_sos_button.dart';
import '../../data/models/caregiver_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/app_mock_data.dart';
import '../auth/login_screen.dart';
import '../family/family_dashboard_screen.dart';
import '../senior/senior_dashboard_screen.dart';
import 'visit_detail_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  late CaregiverProfileModel _profile;
  late List<CareVisitModel> _visits;
  bool _isOnDuty = true;

  @override
  void initState() {
    super.initState();
    _profile = AppMockData.caregiverProfile;
    _visits = List.from(AppMockData.caregiverVisits);
  }

  void _toggleTask(int visitIndex, int taskIndex) {
    setState(() {
      final visit = _visits[visitIndex];
      final currentTask = visit.tasks[taskIndex];
      final updatedTasks = List<CaregiverTask>.from(visit.tasks);
      updatedTasks[taskIndex] = currentTask.copyWith(
        isCompleted: !currentTask.isCompleted,
      );

      _visits[visitIndex] = visit.copyWith(tasks: updatedTasks);
    });
  }

  void _showRoleSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Role Persona'),
        content: const Text('Choose a role to test its specific views and features:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SeniorDashboardScreen()),
              );
            },
            child: const Text('Senior Citizen View'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FamilyDashboardScreen()),
              );
            },
            child: const Text('Family Guardian View'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Caregiver Portal', style: AppTextStyles.titleLarge),
            Text('Seva Care Agency Provider', style: TextStyle(fontSize: 12, color: AppColors.caregiverRole, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.navy),
            tooltip: 'Switch Role',
            onPressed: () => _showRoleSwitchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.navy),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.caregiver)),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caregiver Profile & Availability Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.warmAmberBg,
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              size: 32,
                              color: AppColors.warmAmber,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _profile.certification,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _profile.agencyName,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isOnDuty ? AppColors.mintGreen : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isOnDuty ? 'Status: On Duty & Available' : 'Status: Off Duty',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _isOnDuty ? AppColors.mintGreen : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isOnDuty,
                            activeThumbColor: AppColors.mintGreen,
                            onChanged: (val) {
                              setState(() {
                                _isOnDuty = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Assigned Care Visits Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Assigned Care Visits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_visits.length} Visits',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Visits List
                ...List.generate(_visits.length, (vIndex) {
                  final visit = _visits[vIndex];
                  final completedTasks = visit.tasks.where((t) => t.isCompleted).length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
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
                              backgroundColor: AppColors.primaryLight,
                              child: const Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visit.seniorName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  Text(
                                    visit.scheduledTime,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.cyanBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Upcoming',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                visit.address,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Care instructions box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warmAmberBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.warmAmber.withAlpha(50)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.assignment_rounded, size: 16, color: AppColors.warmAmber),
                                  SizedBox(width: 6),
                                  Text(
                                    'Physician Care Instructions:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.navy),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                visit.careInstructions,
                                style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.navyMuted),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Task Completion Checklist (Requirement 5C)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Care Protocol Checklist:',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.navy),
                            ),
                            Text(
                              '$completedTasks of ${visit.tasks.length} Done',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.mintGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(visit.tasks.length, (tIndex) {
                          final task = visit.tasks[tIndex];
                          return InkWell(
                            onTap: () => _toggleTask(vIndex, tIndex),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 20,
                                    color: task.isCompleted ? AppColors.mintGreen : AppColors.textLight,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: task.isCompleted ? AppColors.textLight : AppColors.navy,
                                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.category,
                                      style: const TextStyle(fontSize: 10, color: AppColors.navyMuted, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Contacting Senior & Family...')),
                                  );
                                },
                                icon: const Icon(Icons.call_rounded, size: 16),
                                label: const Text('Contact Family'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VisitDetailScreen(visit: visit),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                                label: const Text('Visit Report'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Floating SOS button
          Positioned(
            right: 18,
            bottom: 30,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }
}
