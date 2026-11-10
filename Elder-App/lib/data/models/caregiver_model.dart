enum VisitStatus {
  upcoming,
  inProgress,
  completed,
  cancelled,
}

class CaregiverTask {
  final String id;
  final String title;
  final String category; // e.g. "Vitals", "Medication", "Mobility", "Diet"
  final bool isCompleted;

  const CaregiverTask({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });

  CaregiverTask copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
  }) {
    return CaregiverTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CareVisitModel {
  final String id;
  final String seniorId;
  final String seniorName;
  final String address;
  final String scheduledDate;
  final String scheduledTime;
  final VisitStatus status;
  final String careInstructions;
  final List<CaregiverTask> tasks;
  final String notes;

  const CareVisitModel({
    required this.id,
    required this.seniorId,
    required this.seniorName,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.careInstructions,
    required this.tasks,
    this.notes = '',
  });

  CareVisitModel copyWith({
    String? id,
    String? seniorId,
    String? seniorName,
    String? address,
    String? scheduledDate,
    String? scheduledTime,
    VisitStatus? status,
    String? careInstructions,
    List<CaregiverTask>? tasks,
    String? notes,
  }) {
    return CareVisitModel(
      id: id ?? this.id,
      seniorId: seniorId ?? this.seniorId,
      seniorName: seniorName ?? this.seniorName,
      address: address ?? this.address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      careInstructions: careInstructions ?? this.careInstructions,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
    );
  }
}

class CaregiverProfileModel {
  final String id;
  final String name;
  final String agencyName;
  final String certification;
  final String experience;
  final String rating;
  final String phoneNumber;
  final bool isOnDuty;
  final List<String> specialities;

  const CaregiverProfileModel({
    required this.id,
    required this.name,
    required this.agencyName,
    required this.certification,
    required this.experience,
    required this.rating,
    required this.phoneNumber,
    this.isOnDuty = true,
    this.specialities = const [],
  });
}

