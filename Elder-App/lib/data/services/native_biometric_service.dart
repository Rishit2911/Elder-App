import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Production Native Biometrics & Device PIN Fallback Service
/// Powered by Apple Face ID / Touch ID and Android BiometricPrompt
class NativeBiometricService {
  static final NativeBiometricService _instance = NativeBiometricService._internal();
  factory NativeBiometricService() => _instance;
  NativeBiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if phone hardware supports biometrics (Face ID / Fingerprint / Passcode)
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (e) {
      debugPrint('Biometric capability check error: $e');
      return false;
    }
  }

  /// Get list of hardware biometrics enrolled on this specific phone
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Available biometrics query error: $e');
      return [];
    }
  }

  /// Authenticate using native hardware (Face ID, Fingerprint, or Phone PIN/Pattern)
  Future<bool> authenticate({String? reason}) async {
    if (kIsWeb) return true;
    try {
      final isSupported = await canCheckBiometrics();
      if (!isSupported) {
        // No lock screen or biometrics set up on the device
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to open Elderly Seva',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Fallback to Phone Lock PIN/Pattern if fingerprint is missing or fails!
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Platform biometric exception: $e');
      return false;
    } catch (e) {
      debugPrint('Biometric generic error: $e');
      return false;
    }
  }
}

