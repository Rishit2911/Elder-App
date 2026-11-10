import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/family_member_model.dart';
import '../../../data/repositories/app_mock_data.dart';

class FamilyTab extends StatefulWidget {
  const FamilyTab({super.key});

  @override
  State<FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<FamilyTab> {
  late List<FamilyMemberModel> members;
  late List<SeniorProfileModel> seniors;
  int selectedSeniorIndex = 0;

  @override
  void initState() {
    super.initState();
    members = List.from(AppMockData.familyMembers);
    seniors = List.from(AppMockData.seniorProfiles);
  }

  void _showAddEditMemberDialog({FamilyMemberModel? existingMember, int? index}) {
    final nameController = TextEditingController(text: existingMember?.name ?? '');
    final phoneController = TextEditingController(text: existingMember?.phoneNumber ?? '');
    final emailController = TextEditingController(text: existingMember?.email ?? '');
    RelationshipType selectedRel = existingMember?.relationship ?? RelationshipType.son;
    bool isPrimaryEmergency = existingMember?.isPrimaryEmergencyContact ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            existingMember == null ? 'Add Family Member' : 'Edit Family Member',
            style: AppTextStyles.titleMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Rajesh Sharma'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Contact Number', hintText: '+1 (555) ...'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', hintText: 'email@example.com'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Text('Relationship:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<RelationshipType>(
                  initialValue: selectedRel,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: RelationshipType.values.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedRel = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isPrimaryEmergency,
                  activeColor: AppColors.coralRed,
                  title: const Text('Designate as Primary Emergency Contact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  onChanged: (val) {
                    setDialogState(() {
                      isPrimaryEmergency = val ?? false;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  '[Backend: POST /api/v1/family/members]',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                setState(() {
                  final newMember = FamilyMemberModel(
                    id: existingMember?.id ?? 'fam-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    relationship: selectedRel,
                    phoneNumber: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    isPrimaryEmergencyContact: isPrimaryEmergency,
                    connectionStatus: 'Active now',
                  );

                  if (existingMember != null && index != null) {
                    members[index] = newMember;
                  } else {
                    members.add(newMember);
                  }
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existingMember == null ? 'Family member added!' : 'Family member updated!'),
                    backgroundColor: AppColors.mintGreen,
                  ),
                );
              },
              child: Text(existingMember == null ? 'Add Member' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(int index) {
    final member = members[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Family Member?'),
        content: Text('Are you sure you want to remove ${member.name} from your trusted circle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
            onPressed: () {
              setState(() {
                members.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Family member removed.')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showVisitPlannerDialog() {
    final visitorController = TextEditingController(text: 'Rajesh Sharma');
    final notesController = TextEditingController(text: 'Bringing Dadaji\'s favorite sweets and new reading glasses');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Plan Family Visit', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: visitorController,
              decoration: const InputDecoration(labelText: 'Visiting Family Member'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Visit Notes / Purpose'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            const Text(
              'Scheduled Date: This Sunday, 04:00 PM\n[Backend: POST /api/v1/family/visits]',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visit planned and synced with Family Calendar!'),
                  backgroundColor: AppColors.mintGreen,
                ),
              );
            },
            child: const Text('Confirm Visit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSenior = seniors[selectedSeniorIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Family',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connected loved ones & shared care',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => _showAddEditMemberDialog(),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Member', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // SENIOR PROFILES SELECTOR (Requirement 9: "manage and view multiple senior profiles")
          const Text(
            'Family Senior Profiles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: List.generate(seniors.length, (idx) {
              final sen = seniors[idx];
              final isSel = selectedSeniorIndex == idx;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx < seniors.length - 1 ? 10 : 0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedSeniorIndex = idx;
                      });
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSel ? AppColors.primaryBlue : AppColors.cardBorder,
                          width: isSel ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(sen.photoAsset),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sen.honorific.isNotEmpty ? '${sen.name} (${sen.honorific})' : sen.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.navy,
                                  ),
                                ),
                                Text(
                                  'Age ${sen.age} • ${sen.bloodGroup}',
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

          // SELECTED SENIOR HEALTH SUMMARY & STATUS
          Container(
            padding: const EdgeInsets.all(16),
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
                    Text(
                      '${activeSenior.honorific.isNotEmpty ? activeSenior.honorific : activeSenior.name}\'s Today Check-in',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mintBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeSenior.currentMood,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mintGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  activeSenior.dailyWellbeingStatus,
                  style: AppTextStyles.bodySmall,
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat('BP', activeSenior.bloodPressure),
                    _buildQuickStat('Sugar', activeSenior.bloodSugar),
                    _buildQuickStat('Pulse', activeSenior.heartRate),
                    _buildQuickStat('Meds Taken', '${activeSenior.medicinesTakenToday}/${activeSenior.totalMedicinesToday}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // VISIT PLANNER BANNER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWarm,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0E4C5)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.warmAmber,
                  child: Icon(Icons.event_available_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Visit Planned',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rajesh & Aarav visiting this Sunday at 04:00 PM',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showVisitPlannerDialog,
                  child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // FAMILY MEMBERS LIST CARDS
          const Text(
            'Trusted Family Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(members.length, (index) {
            final member = members[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: member.isPrimaryEmergencyContact
                      ? AppColors.coralRed.withAlpha(100)
                      : AppColors.cardBorder,
                  width: member.isPrimaryEmergencyContact ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 6,
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
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          member.name.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                                if (member.isPrimaryEmergencyContact) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.coralLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Primary SOS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.coralRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${member.relationshipDisplay} • ${member.connectionStatus}',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              member.phoneNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showAddEditMemberDialog(existingMember: member, index: index);
                          } else if (val == 'delete') {
                            _confirmDeleteMember(index);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit Member')),
                          const PopupMenuItem(value: 'delete', child: Text('Remove Member')),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${member.name} (${member.phoneNumber})...')),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening chat with ${member.name}...')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('Message', style: TextStyle(fontWeight: FontWeight.w700)),
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
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
