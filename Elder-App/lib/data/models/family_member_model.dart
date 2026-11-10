enum RelationshipType {
  son,
  daughter,
  spouse,
  grandchild,
  sibling,
  other,
}

class FamilyMemberModel {
  final String id;
  final String name;
  final RelationshipType relationship;
  final String customRelationship;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final bool isPrimaryEmergencyContact;
  final String connectionStatus; // e.g. "Active now", "Visited today", "Checked in 1 hr ago"
  final DateTime? lastContacted;

  const FamilyMemberModel({
    required this.id,
    required this.name,
    required this.relationship,
    this.customRelationship = '',
    required this.phoneNumber,
    this.email = '',
    this.avatarUrl,
    this.isPrimaryEmergencyContact = false,
    this.connectionStatus = 'Active now',
    this.lastContacted,
  });

  String get relationshipDisplay {
    switch (relationship) {
      case RelationshipType.son:
        return 'Son';
      case RelationshipType.daughter:
        return 'Daughter';
      case RelationshipType.spouse:
        return 'Spouse';
      case RelationshipType.grandchild:
        return 'Grandchild';
      case RelationshipType.sibling:
        return 'Sibling';
      case RelationshipType.other:
        return customRelationship.isNotEmpty ? customRelationship : 'Family Member';
    }
  }

  FamilyMemberModel copyWith({
    String? id,
    String? name,
    RelationshipType? relationship,
    String? customRelationship,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    bool? isPrimaryEmergencyContact,
    String? connectionStatus,
    DateTime? lastContacted,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      customRelationship: customRelationship ?? this.customRelationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPrimaryEmergencyContact: isPrimaryEmergencyContact ?? this.isPrimaryEmergencyContact,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastContacted: lastContacted ?? this.lastContacted,
    );
  }
}

/// Model representing a Senior Citizen profile managed by family members or caregivers
class SeniorProfileModel {
  final String id;
  final String name;
  final String honorific; // e.g. "Dadaji" or "Dadi"
  final int age;
  final String bloodGroup;
  final String photoAsset;
  final String currentMood; // e.g. "Energetic & Peaceful"
  final String dailyWellbeingStatus; // e.g. "Morning Walk & Breakfast Completed"
  final String bloodPressure; // e.g. "120/80 mmHg"
  final String bloodSugar; // e.g. "110 mg/dL"
  final String heartRate; // e.g. "72 bpm"
  final String oxygenLevel; // e.g. "98%"
  final int medicinesTakenToday;
  final int totalMedicinesToday;
  final String nextAppointment;
  final String assignedCaregiverName;
  final String assignedCaregiverPhone;
  final List<String> recentActivities;
  final bool hasSharedHealthConsent;

  const SeniorProfileModel({
    required this.id,
    required this.name,
    this.honorific = '',
    required this.age,
    required this.bloodGroup,
    required this.photoAsset,
    required this.currentMood,
    required this.dailyWellbeingStatus,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.heartRate,
    required this.oxygenLevel,
    required this.medicinesTakenToday,
    required this.totalMedicinesToday,
    required this.nextAppointment,
    required this.assignedCaregiverName,
    required this.assignedCaregiverPhone,
    this.recentActivities = const [],
    this.hasSharedHealthConsent = true,
  });

  SeniorProfileModel copyWith({
    String? id,
    String? name,
    String? honorific,
    int? age,
    String? bloodGroup,
    String? photoAsset,
    String? currentMood,
    String? dailyWellbeingStatus,
    String? bloodPressure,
    String? bloodSugar,
    String? heartRate,
    String? oxygenLevel,
    int? medicinesTakenToday,
    int? totalMedicinesToday,
    String? nextAppointment,
    String? assignedCaregiverName,
    String? assignedCaregiverPhone,
    List<String>? recentActivities,
    bool? hasSharedHealthConsent,
  }) {
    return SeniorProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      honorific: honorific ?? this.honorific,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoAsset: photoAsset ?? this.photoAsset,
      currentMood: currentMood ?? this.currentMood,
      dailyWellbeingStatus: dailyWellbeingStatus ?? this.dailyWellbeingStatus,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      heartRate: heartRate ?? this.heartRate,
      oxygenLevel: oxygenLevel ?? this.oxygenLevel,
      medicinesTakenToday: medicinesTakenToday ?? this.medicinesTakenToday,
      totalMedicinesToday: totalMedicinesToday ?? this.totalMedicinesToday,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      assignedCaregiverName: assignedCaregiverName ?? this.assignedCaregiverName,
      assignedCaregiverPhone: assignedCaregiverPhone ?? this.assignedCaregiverPhone,
      recentActivities: recentActivities ?? this.recentActivities,
      hasSharedHealthConsent: hasSharedHealthConsent ?? this.hasSharedHealthConsent,
    );
  }
}

