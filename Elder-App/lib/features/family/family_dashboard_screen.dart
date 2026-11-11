import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/circular_sos_button.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/family_member_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/app_mock_data.dart';
import '../auth/login_screen.dart';
import '../caregiver/caregiver_dashboard_screen.dart';
import '../senior/senior_dashboard_screen.dart';
import 'senior_health_detail_screen.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  late List<SeniorProfileModel> _seniorProfiles;
  int _activeSeniorIndex = 0;
  bool _hasConsent = true;

  @override
  void initState() {
    super.initState();
    _seniorProfiles = List.from(AppMockData.seniorProfiles);
  }

  void _showScheduleVisitModal() {
    final noteController = TextEditingController(text: 'Bringing Dadaji\'s favorite Gujarati snacks');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.primaryBlue),
                const SizedBox(width: 10),
                Text(
                  'Plan Family Visit for ${_seniorProfiles[_activeSeniorIndex].name}',
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Select Date & Time: This Sunday, 04:00 PM - 06:30 PM', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Visit Notes / Items to Bring',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 18),
            CustomButton(
              label: 'Save & Notify Family',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visit planned and shared across family devices! [POST /api/v1/family/visits]'),
                    backgroundColor: AppColors.mintGreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final senior = _seniorProfiles[_activeSeniorIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family Guardian Portal', style: AppTextStyles.titleLarge),
            Text('Rajesh Sharma (Son) • Monitoring 2 Seniors', style: TextStyle(fontSize: 12, color: AppColors.familyRole, fontWeight: FontWeight.w700)),
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
                MaterialPageRoute(builder: (_) => const LoginScreen(initialRole: UserRole.family)),
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
                // MULTI-SENIOR PROFILES SELECTOR
                const Text(
                  'Select Senior Citizen Profile:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 10),

                // Multi-senior profile toggle cards
                Row(
                  children: List.generate(_seniorProfiles.length, (idx) {
                    final item = _seniorProfiles[idx];
                    final isSelected = _activeSeniorIndex == idx;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: idx < _seniorProfiles.length - 1 ? 10 : 0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _activeSeniorIndex = idx;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withAlpha(180),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.familyRole : AppColors.cardBorder,
                                width: isSelected ? 2.2 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? AppColors.familyRole.withAlpha(40) : Colors.black.withAlpha(6),
                                  blurRadius: isSelected ? 10 : 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: AssetImage(item.photoAsset),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.honorific.isNotEmpty ? '${item.name} (${item.honorific})' : item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          fontSize: 13.5,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Age ${item.age} • ${item.bloodGroup}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // EMERGENCY STATUS BANNER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.mintGreen.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.mintGreen,
                        child: Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Status: All Clear',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF134E2C),
                              ),
                            ),
                            Text(
                              'No SOS alerts active. Smart sensors & heart monitor reporting normal.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF206A40)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // TODAY'S WELL-BEING & VITALS OVERVIEW
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${senior.name}\'s Vitals Overview',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeniorHealthDetailScreen(senior: senior),
                                ),
                              );
                            },
                            child: const Text('Full History', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.mintGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                senior.dailyWellbeingStatus,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricBadge(
                              title: 'Blood Pressure',
                              value: senior.bloodPressure,
                              icon: Icons.favorite_rounded,
                              color: const Color(0xFFFF5D7D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricBadge(
                              title: 'Blood Glucose',
                              value: senior.bloodSugar,
                              icon: Icons.water_drop_rounded,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricBadge(
                              title: 'Heart Pulse',
                              value: senior.heartRate,
                              icon: Icons.speed_rounded,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMetricBadge(
                              title: 'Oxygen SpO2',
                              value: senior.oxygenLevel,
                              icon: Icons.air_rounded,
                              color: const Color(0xFF06B6D4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // MEDICINE ADHERENCE UPDATES (Requirement 5B)
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
                          const Row(
                            children: [
                              Icon(Icons.medication_rounded, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                'Medicine Adherence',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.mintBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${senior.medicinesTakenToday} of ${senior.totalMedicinesToday} Taken',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mintGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: senior.medicinesTakenToday / senior.totalMedicinesToday,
                          minHeight: 10,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDoseStatusRow('Vitamin D3 (1000 IU)', 'Taken at 08:05 AM', true),
                      const Divider(height: 16),
                      _buildDoseStatusRow('Calcium Citrate (500 mg)', 'Scheduled for 01:30 PM (Pending)', false),
                      const Divider(height: 16),
                      _buildDoseStatusRow('Blood Pressure Med (5 mg)', 'Scheduled for 08:00 PM (Pending)', false),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ASSIGNED CAREGIVER STATUS & BOOKING
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
                      const Text(
                        'Assigned Caregiver & Visit Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.warmAmberBg,
                            child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.warmAmber),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senior.assignedCaregiverName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                                ),
                                const Text(
                                  'Seva Care Agency • Scheduled Visit Today at 02:00 PM',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone_rounded, color: AppColors.primaryBlue),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling Caregiver ${senior.assignedCaregiverPhone}...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // VISIT PLANNING & CALENDAR
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWarm,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0E4C5)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.warmAmber,
                        child: Icon(Icons.calendar_month_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Family Visit Planning',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Coordinate family check-ins and personal visits',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warmAmber,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _showScheduleVisitModal,
                        child: const Text('Plan Visit'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SHARED HEALTH RECORDS & CONSENT (Requirement 5B: "Shared health records, subject to permission")
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
                          const Row(
                            children: [
                              Icon(Icons.lock_person_rounded, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                'Shared Health Records & Consent',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                              ),
                            ],
                          ),
                          Switch(
                            value: _hasConsent,
                            activeThumbColor: AppColors.primaryBlue,
                            onChanged: (val) {
                              setState(() {
                                _hasConsent = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasConsent
                            ? 'Senior Consent Active: Authorized family members can view lab results, cardiology reports, and doctor prescriptions.'
                            : 'Consent Paused: Health record access restricted by senior.',
                        style: AppTextStyles.bodySmall,
                      ),
                      if (_hasConsent) ...[
                        const Divider(height: 20),
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.coralRed),
                            title: const Text('Cardiology Echo Report (Dr. Sharma)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            subtitle: const Text('Uploaded 3 days ago • Normal LVEF', style: TextStyle(fontSize: 11.5)),
                            trailing: const Icon(Icons.download_rounded, color: AppColors.primaryBlue),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloading Cardiology Echo Report (PDF)...')),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Circular Floating SOS
          Positioned(
            right: 18,
            bottom: 30,
            child: const CircularSOSButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
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
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseStatusRow(String medName, String status, bool isTaken) {
    return Row(
      children: [
        Icon(
          isTaken ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: isTaken ? AppColors.mintGreen : AppColors.warmAmber,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
              Text(status, style: TextStyle(fontSize: 11.5, color: isTaken ? AppColors.mintGreen : AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
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
                MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
              );
            },
            child: const Text('Caregiver View'),
          ),
        ],
      ),
    );
  }
}
