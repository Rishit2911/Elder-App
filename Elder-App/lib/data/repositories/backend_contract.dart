import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/family_member_model.dart';
import '../models/caregiver_model.dart';
import '../models/health_record_model.dart';
import '../models/reminder_model.dart';
import '../models/sos_contact_model.dart';

/// ============================================================================
/// BACKEND INTEGRATION CONTRACT & REPOSITORY INTERFACES
///
/// This file defines the contract between the Flutter UI layer and the upcoming
/// backend services. Each method clearly indicates the future HTTP/GraphQL
/// endpoint and payload expectation.
/// ============================================================================

abstract class AuthRepository {
  /// INTEGRATION POINT: POST /api/v1/auth/login
  /// Body: { "emailOrPhone": "...", "password": "...", "role": "..." }
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  });

  /// INTEGRATION POINT: POST /api/v1/auth/register
  /// Body: { "fullName": "...", "email": "...", "phoneNumber": "...", "password": "...", "role": "..." }
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  });

  /// INTEGRATION POINT: POST /api/v1/auth/forgot-password
  Future<bool> sendPasswordReset({required String emailOrPhone});

  /// INTEGRATION POINT: POST /api/v1/auth/logout
  Future<void> logout();
}

abstract class MedicineRepository {
  /// INTEGRATION POINT: GET /api/v1/seniors/{seniorId}/medicines
  Future<List<MedicineModel>> getThreeBottles({required String seniorId});

  /// INTEGRATION POINT: POST /api/v1/seniors/{seniorId}/medicines/{medicineId}/taken
  Future<bool> markMedicineAsTaken({
    required String seniorId,
    required String medicineId,
    required DateTime takenAt,
  });

  /// INTEGRATION POINT: POST /api/v1/seniors/{seniorId}/medicines/{medicineId}/refill
  Future<bool> requestRefill({
    required String seniorId,
    required String medicineId,
  });
}

abstract class FamilyRepository {
  /// INTEGRATION POINT: GET /api/v1/family/members
  Future<List<FamilyMemberModel>> getFamilyMembers();

  /// INTEGRATION POINT: POST /api/v1/family/members
  Future<FamilyMemberModel> addFamilyMember(FamilyMemberModel member);

  /// INTEGRATION POINT: PUT /api/v1/family/members/{id}
  Future<FamilyMemberModel> updateFamilyMember(FamilyMemberModel member);

  /// INTEGRATION POINT: DELETE /api/v1/family/members/{id}
  Future<bool> removeFamilyMember(String id);

  /// INTEGRATION POINT: GET /api/v1/family/seniors
  Future<List<SeniorProfileModel>> getManagedSeniorProfiles();

  /// INTEGRATION POINT: POST /api/v1/family/visits
  Future<bool> scheduleFamilyVisit({
    required String seniorId,
    required DateTime date,
    required String visitorName,
    required String notes,
  });
}

abstract class CaregiverRepository {
  /// INTEGRATION POINT: GET /api/v1/caregiver/assigned-visits
  Future<List<CareVisitModel>> getAssignedVisits({required String caregiverId});

  /// INTEGRATION POINT: PATCH /api/v1/caregiver/visits/{visitId}/status
  Future<bool> updateVisitStatus({
    required String visitId,
    required VisitStatus status,
  });

  /// INTEGRATION POINT: POST /api/v1/caregiver/visits/{visitId}/tasks/{taskId}/toggle
  Future<bool> toggleTaskCompletion({
    required String visitId,
    required String taskId,
    required bool isCompleted,
  });

  /// INTEGRATION POINT: GET /api/v1/caregiver/profile
  Future<CaregiverProfileModel> getCaregiverProfile({required String caregiverId});

  /// INTEGRATION POINT: POST /api/v1/caregiver/requests
  Future<bool> bookCaregiver({
    required String seniorId,
    required String careType,
    required DateTime startDate,
    required String durationHours,
    required String instructions,
  });
}

abstract class HealthRepository {
  /// INTEGRATION POINT: GET /api/v1/seniors/{seniorId}/health-overview
  Future<HealthRecordModel> getSeniorHealthRecord({required String seniorId});

  /// INTEGRATION POINT: GET /api/v1/seniors/{seniorId}/reminders
  Future<List<ReminderModel>> getReminders({required String seniorId});

  /// INTEGRATION POINT: POST /api/v1/seniors/{seniorId}/reminders/{reminderId}/toggle
  Future<bool> toggleReminder({
    required String reminderId,
    required bool isCompleted,
  });
}

abstract class EmergencyRepository {
  /// INTEGRATION POINT: GET /api/v1/emergency/contacts
  Future<List<SOSContactModel>> getEmergencyContacts();

  /// INTEGRATION POINT: POST /api/v1/emergency/trigger-sos
  /// Body: { "seniorId": "...", "location": { "lat": "...", "lng": "..." }, "timestamp": "..." }
  Future<bool> broadcastEmergencyAlert({
    required String seniorId,
    required String locationString,
  });

  /// INTEGRATION POINT: GET /api/v1/emergency/nearby-hospitals
  Future<List<HospitalModel>> getNearbyHospitals();

  /// INTEGRATION POINT: GET /api/v1/doctors
  Future<List<DoctorModel>> getDoctors();
}

