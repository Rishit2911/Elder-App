import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/sos_contact_model.dart';
import '../../data/repositories/app_mock_data.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool isAlertDispatched = false;
  bool isSirenActive = false;

  void _triggerEmergencyDispatch() {
    setState(() {
      isAlertDispatched = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'EMERGENCY ALERT BROADCAST: High-priority SMS & Push sent to Rajesh Sharma and Emergency Responders.\n[Integration Point: POST /api/v1/emergency/trigger-sos]',
        ),
        backgroundColor: AppColors.coralRed,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callContact(SOSContactModel contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppColors.coralRed),
            const SizedBox(width: 10),
            const Text('Emergency Call', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Direct offline emergency call to:\n', style: AppTextStyles.bodyMedium),
            Text(
              contact.name,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 4),
            Text(
              contact.phoneNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.coralRed,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Safety note: Native phone dialer will be launched directly without requiring internet or AI services.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coralRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${contact.phoneNumber}...'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency Assistance',
          style: TextStyle(
            color: AppColors.coralRed,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Prominent Circular SOS Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.coralRed.withAlpha(80), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coralRed.withAlpha(25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Perfectly circular hero SOS trigger
                  GestureDetector(
                    onTap: _triggerEmergencyDispatch,
                    child: Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coralRed,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coralRed.withAlpha(120),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Tap SOS to Alert Family & Responders',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Instant SMS, Push Notification, and GPS Coordinates sent to registered contacts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  if (isAlertDispatched) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.mintBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mintGreen),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Alert Broadcasted Successfully',
                            style: TextStyle(
                              color: AppColors.mintGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Location & Address
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
                    backgroundColor: AppColors.coralLight,
                    child: Icon(Icons.location_on_rounded, color: AppColors.coralRed),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Recorded Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '42 Lotus Villa, Palm Avenue, Sec 5',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          '28.5355° N, 77.3910° E (Accuracy: 5m)',
                          style: TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_location_rounded, color: AppColors.primaryBlue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location shared with Rajesh Sharma via SMS.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DIRECT 1-TAP EMERGENCY CALLS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Direct Emergency Calling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 10),

            ...AppMockData.sosContacts.map((contact) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: contact.isPrimary
                        ? AppColors.coralRed.withAlpha(120)
                        : AppColors.cardBorder,
                    width: contact.isPrimary ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: contact.isPrimary
                        ? AppColors.coralRed
                        : AppColors.primaryLight,
                    child: Icon(
                      contact.icon,
                      color: contact.isPrimary ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                  subtitle: Text(
                    contact.role,
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: contact.isPrimary
                          ? AppColors.coralRed
                          : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(90, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _callContact(contact),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Siren / Sound alarm for home
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSirenActive ? AppColors.coralLight : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSirenActive ? AppColors.coralRed : AppColors.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSirenActive
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: AppColors.coralRed,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audible Room Siren',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          isSirenActive
                              ? 'Alarm is sounding loudly!'
                              : 'Plays loud sound to alert people in home',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isSirenActive,
                    activeThumbColor: AppColors.coralRed,
                    onChanged: (val) {
                      setState(() {
                        isSirenActive = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
