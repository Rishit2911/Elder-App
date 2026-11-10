import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/family_member_model.dart';
import '../models/caregiver_model.dart';
import '../models/reminder_model.dart';
import '../models/sos_contact_model.dart';

class AppMockData {
  /// EXACTLY THREE SEPARATE MEDICINE BOTTLES as strictly required by Brief Section 8
  static List<MedicineModel> get initialThreeBottles => [
        const MedicineModel(
          id: 'med-1',
          name: 'Vitamin D3',
          genericName: 'Cholecalciferol',
          dosage: '1000 IU Tablet',
          remainingQuantity: 12,
          totalCapacity: 30,
          primaryTiming: DoseTiming.morning,
          scheduleTime: '08:00 AM',
          instructions: 'Take 1 tablet in the morning with warm water or breakfast.',
          pillColor: Color(0xFFF5A623), // Golden amber
          liquidTint: Color(0xFFFFF7E6),
          isTakenToday: true,
          needsRefill: false,
          history: [
            'Taken today at 08:05 AM',
            'Taken yesterday at 08:10 AM',
            'Taken 2 days ago at 08:00 AM',
          ],
        ),
        const MedicineModel(
          id: 'med-2',
          name: 'Calcium Citrate',
          genericName: 'Calcium + Magnesium',
          dosage: '500 mg Tablet',
          remainingQuantity: 8,
          totalCapacity: 30,
          primaryTiming: DoseTiming.afternoon,
          scheduleTime: '01:30 PM',
          instructions: 'Take 1 tablet after lunch. Refill recommended soon.',
          pillColor: Color(0xFF00B4D8), // Turquoise / Cyan
          liquidTint: Color(0xFFE8F9FD),
          isTakenToday: false,
          needsRefill: true, // 8 tablets remaining -> alert for refill
          history: [
            'Pending for today (01:30 PM)',
            'Taken yesterday at 01:45 PM',
            'Taken 2 days ago at 01:30 PM',
          ],
        ),
        const MedicineModel(
          id: 'med-3',
          name: 'Blood Pressure Med',
          genericName: 'Amlodipine Besylate',
          dosage: '5 mg Tablet',
          remainingQuantity: 20,
          totalCapacity: 30,
          primaryTiming: DoseTiming.evening,
          scheduleTime: '08:00 PM',
          instructions: 'Take 1 tablet in the evening before dinner for BP stability.',
          pillColor: Color(0xFFE64A19), // Warm coral red
          liquidTint: Color(0xFFFFECE6),
          isTakenToday: false,
          needsRefill: false,
          history: [
            'Pending for today (08:00 PM)',
            'Taken yesterday at 08:15 PM',
            'Taken 2 days ago at 08:00 PM',
          ],
        ),
      ];

  /// MULTIPLE SENIOR PROFILES as required by Section 5B & Section 9
  static List<SeniorProfileModel> get seniorProfiles => [
        const SeniorProfileModel(
          id: 'senior-1',
          name: 'Ramesh Sharma',
          honorific: 'Dadaji',
          age: 74,
          bloodGroup: 'B Positive',
          photoAsset: 'assets/images/dadaji_profile.png',
          currentMood: 'Peaceful & Active',
          dailyWellbeingStatus: 'Morning walk and BP check completed successfully.',
          bloodPressure: '120/80 mmHg',
          bloodSugar: '110 mg/dL (Fasting)',
          heartRate: '72 bpm',
          oxygenLevel: '98% SpO2',
          medicinesTakenToday: 1,
          totalMedicinesToday: 3,
          nextAppointment: 'Dr. Alok Sharma (Cardiologist) – Tomorrow, 11:00 AM',
          assignedCaregiverName: 'Nurse Anjali Rao',
          assignedCaregiverPhone: '+1 (555) 456-7890',
          recentActivities: [
            '07:30 AM: Morning garden walk (1,450 steps)',
            '08:05 AM: Vitamin D3 taken with breakfast',
            '09:15 AM: Video call with grandson Aarav',
            '10:30 AM: Blood Pressure logged: 120/80 mmHg (Normal)',
          ],
          hasSharedHealthConsent: true,
        ),
        const SeniorProfileModel(
          id: 'senior-2',
          name: 'Savitri Sharma',
          honorific: 'Dadi',
          age: 71,
          bloodGroup: 'O Positive',
          photoAsset: 'assets/images/family_illustration.png',
          currentMood: 'Relaxed & Cheerful',
          dailyWellbeingStatus: 'Took morning herbal tea and completed breathing exercises.',
          bloodPressure: '125/82 mmHg',
          bloodSugar: '102 mg/dL',
          heartRate: '75 bpm',
          oxygenLevel: '99% SpO2',
          medicinesTakenToday: 2,
          totalMedicinesToday: 2,
          nextAppointment: 'Routine Eye Checkup – Friday, 03:30 PM',
          assignedCaregiverName: 'Nurse Anjali Rao',
          assignedCaregiverPhone: '+1 (555) 456-7890',
          recentActivities: [
            '07:00 AM: Pranayama & gentle yoga',
            '08:00 AM: Morning medication taken',
            '11:00 AM: Temple visit with Rajesh',
          ],
          hasSharedHealthConsent: true,
        ),
      ];

  /// MULTIPLE FAMILY MEMBERS as required by Section 9
  static List<FamilyMemberModel> get familyMembers => [
        const FamilyMemberModel(
          id: 'fam-1',
          name: 'Rajesh Sharma',
          relationship: RelationshipType.son,
          phoneNumber: '+1 (555) 234-8901',
          email: 'rajesh.sharma@example.com',
          isPrimaryEmergencyContact: true,
          connectionStatus: 'Active • 5 min ago',
        ),
        const FamilyMemberModel(
          id: 'fam-2',
          name: 'Priya Sharma Patel',
          relationship: RelationshipType.daughter,
          phoneNumber: '+1 (555) 876-5432',
          email: 'priya.patel@example.com',
          isPrimaryEmergencyContact: false,
          connectionStatus: 'Visited yesterday',
        ),
        const FamilyMemberModel(
          id: 'fam-3',
          name: 'Aarav Sharma',
          relationship: RelationshipType.grandchild,
          phoneNumber: '+1 (555) 432-1098',
          email: 'aarav.sharma@example.com',
          isPrimaryEmergencyContact: false,
          connectionStatus: 'Called 2 hrs ago',
        ),
        const FamilyMemberModel(
          id: 'fam-4',
          name: 'Meena Sharma',
          relationship: RelationshipType.daughter,
          customRelationship: 'Daughter-in-law',
          phoneNumber: '+1 (555) 789-0123',
          email: 'meena.s@example.com',
          isPrimaryEmergencyContact: false,
          connectionStatus: 'Active now',
        ),
      ];

  /// REMINDERS for Senior interface
  static List<ReminderModel> get dailyReminders => [
        const ReminderModel(
          id: 'rem-1',
          title: 'Morning Vitamin D3',
          description: '1 tablet with breakfast and warm water',
          time: '08:00 AM',
          type: ReminderType.medicine,
          isCompleted: true,
          badgeColor: Color(0xFFE8F4FF),
        ),
        const ReminderModel(
          id: 'rem-2',
          title: 'Afternoon Calcium Citrate',
          description: '1 tablet after lunch',
          time: '01:30 PM',
          type: ReminderType.medicine,
          isCompleted: false,
          badgeColor: Color(0xFFFFF4E5),
        ),
        const ReminderModel(
          id: 'rem-3',
          title: 'Drink 2 Glasses of Water',
          description: 'Mid-day hydration reminder',
          time: '03:30 PM',
          type: ReminderType.water,
          isCompleted: false,
          badgeColor: Color(0xFFE0F7FA),
        ),
        const ReminderModel(
          id: 'rem-4',
          title: 'Blood Pressure Medication',
          description: '1 tablet before dinner',
          time: '08:00 PM',
          type: ReminderType.medicine,
          isCompleted: false,
          badgeColor: Color(0xFFFFEBEE),
        ),
        const ReminderModel(
          id: 'rem-5',
          title: 'Dr. Alok Sharma Appointment',
          description: 'Quarterly Cardiology Consultation',
          time: 'Tomorrow, 11:00 AM',
          type: ReminderType.doctor,
          isCompleted: false,
          badgeColor: Color(0xFFEDE7F6),
        ),
      ];

  /// CAREGIVER PROFILE & VISITS for Caregiver Interface
  static CaregiverProfileModel get caregiverProfile => const CaregiverProfileModel(
        id: 'caregiver-1',
        name: 'Nurse Anjali Rao',
        agencyName: 'Seva Care Agency (Certified Provider)',
        certification: 'Registered Geriatric Nurse & BLS Certified',
        experience: '8+ Years Healthcare Experience',
        rating: '4.95 / 5.0 (142 reviews)',
        phoneNumber: '+1 (555) 456-7890',
        isOnDuty: true,
        specialities: [
          'Elderly Mobility Assistance',
          'Vitals & Medication Monitoring',
          'Dietary Support & Hydration',
          'Post-Operative Recovery',
        ],
      );

  static List<CareVisitModel> get caregiverVisits => [
        const CareVisitModel(
          id: 'visit-1',
          seniorId: 'senior-1',
          seniorName: 'Ramesh Sharma (Dadaji)',
          address: '42 Lotus Villa, Palm Avenue, Sector 5',
          scheduledDate: 'Today',
          scheduledTime: '02:00 PM – 05:00 PM',
          status: VisitStatus.upcoming,
          careInstructions:
              'Check post-lunch BP and blood sugar. Assist with 20-minute lawn walk. Ensure 01:30 PM Calcium tablet has been taken.',
          tasks: [
            CaregiverTask(id: 't-1', title: 'Check BP and Blood Glucose', category: 'Vitals'),
            CaregiverTask(id: 't-2', title: 'Verify Calcium Citrate taken', category: 'Medication'),
            CaregiverTask(id: 't-3', title: 'Assisted 20-min garden stroll', category: 'Mobility'),
            CaregiverTask(id: 't-4', title: 'Prepare afternoon tender coconut water', category: 'Diet'),
          ],
          notes: 'Dadaji is in great spirits today. Keep conversation lively!',
        ),
        const CareVisitModel(
          id: 'visit-2',
          seniorId: 'senior-2',
          seniorName: 'Savitri Sharma (Dadi)',
          address: '42 Lotus Villa, Palm Avenue, Sector 5',
          scheduledDate: 'Today',
          scheduledTime: '05:30 PM – 07:00 PM',
          status: VisitStatus.upcoming,
          careInstructions:
              'Gentle knee joint massage and evening medication prep. Check eye drops schedule.',
          tasks: [
            CaregiverTask(id: 't-5', title: 'Knee therapy warm compress', category: 'Mobility'),
            CaregiverTask(id: 't-6', title: 'Evening eye drops administration', category: 'Medication'),
            CaregiverTask(id: 't-7', title: 'Check evening pulse rate', category: 'Vitals'),
          ],
        ),
      ];

  /// EMERGENCY SOS CONTACTS
  static List<SOSContactModel> get sosContacts => const [
        SOSContactModel(
          id: 'sos-1',
          name: '102 Ambulance Emergency',
          role: 'Govt. Emergency Medical Services',
          phoneNumber: '102',
          type: EmergencyType.ambulance,
          isPrimary: true,
          icon: Icons.emergency_rounded,
        ),
        SOSContactModel(
          id: 'sos-2',
          name: 'Rajesh Sharma (Son)',
          role: 'Primary Family Emergency Contact',
          phoneNumber: '+15552348901',
          type: EmergencyType.family,
          isPrimary: true,
          icon: Icons.person_pin_rounded,
        ),
        SOSContactModel(
          id: 'sos-3',
          name: 'Dr. Alok Sharma, MD',
          role: 'Personal Family Cardiologist',
          phoneNumber: '+15553334444',
          type: EmergencyType.doctor,
          isPrimary: false,
          icon: Icons.medical_services_rounded,
        ),
        SOSContactModel(
          id: 'sos-4',
          name: '112 National Helpline',
          role: 'Unified Emergency Services',
          phoneNumber: '112',
          type: EmergencyType.police,
          isPrimary: false,
          icon: Icons.shield_rounded,
        ),
      ];

  /// NEARBY HOSPITALS
  static List<HospitalModel> get nearbyHospitals => const [
        HospitalModel(
          id: 'hosp-1',
          name: 'Apollo Super Specialty Hospital',
          address: 'Main Ring Road, 1.2 miles away',
          distance: '1.2 miles (6 mins)',
          emergencyPhone: '+1 (555) 911-0011',
          hasIcu: true,
          is24x7: true,
          rating: 4.9,
        ),
        HospitalModel(
          id: 'hosp-2',
          name: 'Fortis Senior Healthcare Center',
          address: 'Healthcare Boulevard, Sector 12',
          distance: '2.5 miles (10 mins)',
          emergencyPhone: '+1 (555) 911-0022',
          hasIcu: true,
          is24x7: true,
          rating: 4.8,
        ),
        HospitalModel(
          id: 'hosp-3',
          name: 'City Care Trauma & Geriatric Center',
          address: 'Civil Lines, Crossway Road',
          distance: '3.8 miles (15 mins)',
          emergencyPhone: '+1 (555) 911-0033',
          hasIcu: true,
          is24x7: true,
          rating: 4.7,
        ),
      ];

  /// DOCTORS DIRECTORY
  static List<DoctorModel> get doctors => const [
        DoctorModel(
          id: 'doc-1',
          name: 'Dr. Alok Sharma, MD',
          specialty: 'Senior Cardiologist & Geriatric Medicine',
          hospital: 'Apollo Super Specialty Hospital',
          experience: '22+ Years Experience',
          consultationFee: '\$45',
          availableTime: 'Available Today • 11:00 AM – 03:00 PM',
          rating: 4.9,
          phone: '+1 (555) 333-4444',
        ),
        DoctorModel(
          id: 'doc-2',
          name: 'Dr. Sunita Deshmukh, MS',
          specialty: 'Orthopedics & Joint Care Specialist',
          hospital: 'Fortis Healthcare Center',
          experience: '18+ Years Experience',
          consultationFee: '\$40',
          availableTime: 'Available Tomorrow • 10:00 AM – 01:00 PM',
          rating: 4.85,
          phone: '+1 (555) 333-5555',
        ),
        DoctorModel(
          id: 'doc-3',
          name: 'Dr. David Miller, MD',
          specialty: 'General Physician & Diabetic Care',
          hospital: 'City Care Hospital',
          experience: '15+ Years Experience',
          consultationFee: '\$35',
          availableTime: 'Available Today • 04:00 PM – 07:00 PM',
          rating: 4.8,
          phone: '+1 (555) 333-6666',
        ),
      ];
}
