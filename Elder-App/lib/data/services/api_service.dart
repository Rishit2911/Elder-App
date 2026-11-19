import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_api_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthApiService _auth = AuthApiService();

  String get baseUrl => _auth.baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_auth.accessToken != null) 'Authorization': 'Bearer ${_auth.accessToken}',
      };

  // ---------------------------------------------------------------------------
  // 1. HEALTHCARE & MEDICINES
  // ---------------------------------------------------------------------------

  /// GET /api/v1/healthcare/seniors/{seniorId}/dashboard-summary
  Future<Map<String, dynamic>> getDashboardSummary(String seniorId) async {
    try {
      final uri = Uri.parse('$baseUrl/healthcare/seniors/$seniorId/dashboard-summary');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getDashboardSummary error: $e');
      rethrow;
    }
  }

  /// GET /api/v1/healthcare/seniors/{seniorId}/medicines
  Future<Map<String, dynamic>> getSeniorMedicines(String seniorId) async {
    try {
      final uri = Uri.parse('$baseUrl/healthcare/seniors/$seniorId/medicines');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getSeniorMedicines error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/healthcare/medicines/logs
  Future<Map<String, dynamic>> logMedicineAdherence({
    required String scheduleId,
    required String status, // taken, missed, snoozed
    String? seniorId,
    String? reason,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/healthcare/medicines/logs');
      final body = jsonEncode({
        'schedule_id': scheduleId,
        'senior_id': seniorId ?? '056dd8f0-8fb6-47e7-871c-b1fafc6e2a89',
        'scheduled_timestamp': DateTime.now().toUtc().toIso8601String(),
        'status': status,
        if (reason != null) 'notes': reason,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] logMedicineAdherence error: $e');
      rethrow;
    }
  }

  /// GET /api/v1/healthcare/seniors/{seniorId}/records
  Future<Map<String, dynamic>> getHealthRecords(String seniorId, {String recordType = 'vitals'}) async {
    try {
      final uri = Uri.parse('$baseUrl/healthcare/seniors/$seniorId/records?record_type=$recordType');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getHealthRecords error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. EMERGENCY SOS
  // ---------------------------------------------------------------------------

  /// POST /api/v1/emergency/sos
  Future<Map<String, dynamic>> triggerSOS({
    double latitude = 26.9124,
    double longitude = 75.7873,
    String triggerSource = 'in_app_button',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/emergency/sos');
      final body = jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'trigger_source': triggerSource,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] triggerSOS error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/emergency/sos/{eventId}/resolve
  Future<Map<String, dynamic>> resolveSOS({
    required String eventId,
    required String resolutionStatus, // resolved, false_alarm
    String? resolutionNotes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/emergency/sos/$eventId/resolve');
      final body = jsonEncode({
        'resolution_status': resolutionStatus,
        if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] resolveSOS error: $e');
      rethrow;
    }
  }

  /// GET /api/v1/emergency/contacts
  Future<Map<String, dynamic>> getEmergencyContacts() async {
    try {
      final uri = Uri.parse('$baseUrl/emergency/contacts');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getEmergencyContacts error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. CAREGIVERS & BOOKINGS
  // ---------------------------------------------------------------------------

  /// GET /api/v1/caregivers/search
  Future<Map<String, dynamic>> searchCaregivers({String city = 'Jaipur'}) async {
    try {
      final uri = Uri.parse('$baseUrl/caregivers/search?city=${Uri.encodeComponent(city)}');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] searchCaregivers error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/caregivers/bookings
  Future<Map<String, dynamic>> createCaregiverBooking({
    required String seniorId,
    required String caregiverId,
    required String serviceType,
    required String startDate,
    required String endDate,
    String? instructions,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/caregivers/bookings');
      final body = jsonEncode({
        'senior_id': seniorId,
        'caregiver_id': caregiverId,
        'service_type': serviceType,
        'start_date': startDate,
        'end_date': endDate,
        if (instructions != null) 'instructions': instructions,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] createCaregiverBooking error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. AI ASSISTANT & CHAT
  // ---------------------------------------------------------------------------

  /// POST /api/v1/assistant/chat
  Future<Map<String, dynamic>> chatWithAssistant({
    required String message,
    String language = 'hi',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/assistant/chat');
      final body = jsonEncode({
        'message': message,
        'language': language,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] chatWithAssistant error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. CONSULTATIONS & HOSPITALS
  // ---------------------------------------------------------------------------

  /// GET /api/v1/consultations/nearby-hospitals
  Future<Map<String, dynamic>> getNearbyHospitals({
    double latitude = 26.9124,
    double longitude = 75.7873,
    double radiusKm = 10.0,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/consultations/nearby-hospitals?latitude=$latitude&longitude=$longitude&radius_km=$radiusKm');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getNearbyHospitals error: $e');
      rethrow;
    }
  }

  /// GET /api/v1/consultations/doctors
  Future<Map<String, dynamic>> getDoctors({String? specialization}) async {
    try {
      final specParam = specialization != null ? '?specialization=${Uri.encodeComponent(specialization)}' : '';
      final uri = Uri.parse('$baseUrl/consultations/doctors$specParam');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getDoctors error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 6. FAMILY LINKING & INVITATIONS
  // ---------------------------------------------------------------------------

  /// GET /api/v1/family/links
  Future<Map<String, dynamic>> getFamilyLinks() async {
    try {
      final uri = Uri.parse('$baseUrl/family/links');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] getFamilyLinks error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/family/invite
  Future<Map<String, dynamic>> inviteFamilyMember({
    required String targetPhone,
    required String relationship,
    String? inviteeEmail,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family/invite');
      final body = jsonEncode({
        'targetPhone': targetPhone,
        'relationship': relationship,
        if (inviteeEmail != null) 'inviteeEmail': inviteeEmail,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] inviteFamilyMember error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/family/link/approve
  Future<Map<String, dynamic>> approveFamilyLink({
    required String invitationId,
    bool approved = true,
    bool canManageMedications = true,
    bool canViewRecords = true,
    bool canBookServices = true,
    int emergencyPriority = 1,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/family/link/approve');
      final body = jsonEncode({
        'invitationId': invitationId,
        'approved': approved,
        'canManageMedications': canManageMedications,
        'canViewRecords': canViewRecords,
        'canBookServices': canBookServices,
        'emergencyPriority': emergencyPriority,
      });
      final res = await http.post(uri, headers: _headers, body: body).timeout(const Duration(seconds: 4));
      return _parseResponse(res);
    } catch (e) {
      debugPrint('[ApiService] approveFamilyLink error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // RESPONSE HANDLER
  // ---------------------------------------------------------------------------
  Map<String, dynamic> _parseResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw Exception('Server returned an invalid JSON response (${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    String errorMsg = 'HTTP ${response.statusCode}';
    if (decoded is Map<String, dynamic>) {
      if (decoded['detail'] != null) {
        errorMsg = decoded['detail'].toString();
      } else if (decoded['message'] != null) {
        errorMsg = decoded['message'].toString();
      }
    }
    throw Exception(errorMsg);
  }
}
