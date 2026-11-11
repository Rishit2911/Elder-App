import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthApiService {
  // Singleton pattern
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  /// Base API URL for FastAPI backend
  /// If running in Android emulator, use 10.0.2.2, otherwise localhost for Web/Desktop
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    // For mobile platforms, default to local machine address or emulator
    return 'http://10.0.2.2:8000/api/v1';
  }

  String baseUrl = 'http://localhost:8000/api/v1';

  // Active authenticated session memory
  String? _accessToken;
  String? _refreshToken;
  UserModel? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// Save session state
  void setSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUser = user;
  }

  /// Clear session state on logout
  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  // ===========================================================================
  // 1. REGISTRATION ENDPOINTS
  // ===========================================================================

  /// Senior Citizen Registration
  Future<Map<String, dynamic>> registerSenior({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? preferredName,
    String? email,
    int? age,
    String? gender,
    String? bloodGroup,
    String? emergencyNotes,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register/senior');
    final payload = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      if (preferredName != null && preferredName.isNotEmpty) 'preferredName': preferredName,
      if (email != null && email.isNotEmpty) 'email': email,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (emergencyNotes != null) 'emergencyNotes': emergencyNotes,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  /// Family Member Registration
  Future<Map<String, dynamic>> registerFamily({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    String? relationshipType,
    String? alternatePhone,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register/family');
    final payload = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      'relationshipType': relationshipType ?? 'other',
      if (alternatePhone != null && alternatePhone.isNotEmpty) 'alternatePhone': alternatePhone,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  /// Caregiver / Caretaker Registration
  Future<Map<String, dynamic>> registerCaregiver({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? email,
    String? serviceCity,
    double? hourlyRate,
    int? experienceYears,
    String? bio,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register/caregiver');
    final payload = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      'serviceCity': serviceCity ?? 'Delhi NCR',
      'hourlyRate': hourlyRate ?? 250.0,
      'experienceYears': experienceYears ?? 2,
      if (bio != null && bio.isNotEmpty) 'bio': bio,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return _handleResponse(response);
  }

  // ===========================================================================
  // 2. PASSWORD LOGIN ENDPOINTS (Family, Caregiver, Senior Fallback)
  // ===========================================================================

  /// Universal & Role-specific Login
  Future<UserModel> loginPassword({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final payload = {
      'emailOrPhone': identifier.trim(),
      'password': password,
      'role': role.name,
      'deviceUuid': 'elder-app-flutter',
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final resData = _handleResponse(response);
    final data = resData['data'] as Map<String, dynamic>;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    setSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );

    return user;
  }

  // ===========================================================================
  // 3. BIOMETRIC FACE AUTHENTICATION ENDPOINTS (Senior Citizen)
  // ===========================================================================

  /// Senior Face Enrollment
  Future<Map<String, dynamic>> enrollSeniorFace({
    required String token,
    required List<int> imageBytes,
    String filename = 'face_enroll.jpg',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/face/enroll');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'face_image',
        imageBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Senior Face Verification (Login)
  Future<UserModel> verifySeniorFace({
    required String identifier,
    required List<int> imageBytes,
    String filename = 'face_verify.jpg',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/face/verify');
    final request = http.MultipartRequest('POST', uri);

    request.fields['identifier'] = identifier.trim();
    request.fields['device_uuid'] = 'elder-app-flutter';

    request.files.add(
      http.MultipartFile.fromBytes(
        'face_image',
        imageBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final resData = _handleResponse(response);
    final data = resData['data'] as Map<String, dynamic>;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    setSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );

    return user;
  }

  /// Senior Face Re-Enrollment (Update face template with password verification)
  Future<UserModel> reEnrollSeniorFace({
    required String identifier,
    required String password,
    required List<int> imageBytes,
    String filename = 'face_reenroll.jpg',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/face/re-enroll');
    final request = http.MultipartRequest('POST', uri);

    request.fields['identifier'] = identifier.trim();
    request.fields['password'] = password;
    request.fields['device_uuid'] = 'elder-app-flutter';

    request.files.add(
      http.MultipartFile.fromBytes(
        'face_image',
        imageBytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final resData = _handleResponse(response);
    final data = resData['data'] as Map<String, dynamic>;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    setSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );

    return user;
  }

  /// Record User Biometric Consent
  Future<void> recordConsent({
    required String consentType,
    bool isGranted = true,
  }) async {
    if (_accessToken == null) return;
    final uri = Uri.parse('$baseUrl/auth/consent');
    await http.post(
      uri,
      headers: _authHeaders,
      body: jsonEncode({
        'consentType': consentType,
        'consentVersion': '1.0',
        'isGranted': isGranted,
      }),
    );
  }

  /// Logout
  Future<void> logout() async {
    if (_accessToken != null && _refreshToken != null) {
      try {
        final uri = Uri.parse('$baseUrl/auth/logout');
        await http.post(
          uri,
          headers: _authHeaders,
          body: jsonEncode({'refreshToken': _refreshToken}),
        );
      } catch (_) {}
    }
    clearSession();
  }

  // ===========================================================================
  // INTERNAL RESPONSE PARSING
  // ===========================================================================

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw Exception('Server returned an invalid response (Status ${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    // Extract backend error message
    String errorMsg = 'An unexpected error occurred';
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
