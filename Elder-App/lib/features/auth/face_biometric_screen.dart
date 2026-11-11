import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';
import '../senior/senior_dashboard_screen.dart';
import 'camera_helper.dart';
import 'face_sample_data.dart';
import 'login_screen.dart';

enum FaceScreenMode {
  enroll, // Used right after senior registration
  verify, // Used for senior biometric login
}

class FaceBiometricScreen extends StatefulWidget {
  final FaceScreenMode mode;
  final String identifier; // Senior phone number or email
  final String? tempAccessToken; // Required during enrollment
  final String? fullName;

  const FaceBiometricScreen({
    super.key,
    required this.mode,
    required this.identifier,
    this.tempAccessToken,
    this.fullName,
  });

  @override
  State<FaceBiometricScreen> createState() => _FaceBiometricScreenState();
}

class _FaceBiometricScreenState extends State<FaceBiometricScreen>
    with SingleTickerProviderStateMixin {
  final AuthApiService _apiService = AuthApiService();

  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;

  final WebCameraHelper _cameraHelper = WebCameraHelper();
  bool _cameraReady = false;

  bool _isLoading = false;
  bool _consentGranted = true;
  String? _errorMessage;
  String _statusText = 'Initializing camera...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    final ready = await _cameraHelper.initializeCamera();
    if (mounted) {
      setState(() {
        _cameraReady = ready;
        if (ready) {
          _statusText = 'Live camera active. Align your face inside the oval.';
        } else {
          _statusText = 'Align your face within the oval below';
        }
      });
    }
  }

  @override
  void dispose() {
    _cameraHelper.dispose();
    _scanAnimController.dispose();
    super.dispose();
  }

  List<int> _captureFaceImageBytes() {
    if (_cameraReady) {
      final snapshot = _cameraHelper.captureSnapshot();
      if (snapshot != null && snapshot.isNotEmpty) {
        return snapshot;
      }
    }
    throw Exception('Live camera is initializing. Please position your face inside the oval and try again.');
  }

  Future<void> _handleReEnrollWithPassword(String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusText = 'Updating your face biometric profile with live camera...';
    });

    try {
      final imageBytes = _captureFaceImageBytes();
      final user = await _apiService.reEnrollSeniorFace(
        identifier: widget.identifier,
        password: password,
        imageBytes: imageBytes,
        filename: 'reenroll_${widget.identifier}.jpg',
      );

      setState(() {
        _isSuccess = true;
        _statusText = 'Face Biometrics Updated! Welcome ${user.fullName}';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SeniorDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _statusText = 'Update failed. Please verify your password and retry.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReEnrollDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Re-enroll Face Biometric',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter password for ${widget.identifier} to replace your stored face biometric with your current camera view:',
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter account password',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0F1A2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mintGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final pwd = passwordController.text.trim();
              if (pwd.isEmpty) return;
              Navigator.pop(ctx);
              _handleReEnrollWithPassword(pwd);
            },
            child: const Text('Save & Sign In', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCaptureAndProceed() async {
    if (widget.mode == FaceScreenMode.enroll && !_consentGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please grant biometric consent to proceed with face login setup.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusText = 'Analyzing facial symmetry and verifying liveness...';
    });

    try {
      final imageBytes = _captureFaceImageBytes();

      if (widget.mode == FaceScreenMode.enroll) {
        // ENROLLMENT WORKFLOW
        final token = widget.tempAccessToken;
        if (token == null) {
          throw Exception('Session authorization token missing. Please register again.');
        }

        // 1. Record explicit informed consent
        await _apiService.recordConsent(consentType: 'biometric_face_auth', isGranted: true);

        // 2. Transmit face image for ArcFace embedding & AES-256-GCM encryption
        await _apiService.enrollSeniorFace(
          token: token,
          imageBytes: imageBytes,
          filename: 'senior_${widget.identifier}.jpg',
        );

        setState(() {
          _isSuccess = true;
          _statusText = 'Face Biometrics Enrolled & Encrypted Successfully!';
        });

        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;

        // Navigate directly to Senior Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SeniorDashboardScreen()),
          (route) => false,
        );
      } else {
        // VERIFICATION / LOGIN WORKFLOW
        final user = await _apiService.verifySeniorFace(
          identifier: widget.identifier,
          imageBytes: imageBytes,
          filename: 'login_${widget.identifier}.jpg',
        );

        setState(() {
          _isSuccess = true;
          _statusText = 'Identity Verified! Welcome ${user.fullName}';
        });

        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;

        // Navigate to Senior Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SeniorDashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _statusText = 'Verification paused. Please check lighting and retry.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPasswordFallback() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(initialRole: UserRole.senior),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnrollMode = widget.mode == FaceScreenMode.enroll;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A2C), // High-contrast dark camera backdrop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEnrollMode ? 'Face Enrollment' : 'Senior Face Login',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Greeting / Instruction Header
              Text(
                isEnrollMode
                    ? 'Welcome ${widget.fullName ?? 'Dadaji'}!'
                    : 'Namaste! Please look at the camera',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isSuccess ? AppColors.mintGreen : Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Camera Viewfinder Simulation with Oval Face Guide
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder Frame
                      Container(
                        width: 260,
                        height: 330,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(130),
                          border: Border.all(
                            color: _isSuccess
                                ? AppColors.mintGreen
                                : (_errorMessage != null
                                    ? Colors.redAccent
                                    : AppColors.primaryBlue),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess
                                      ? AppColors.mintGreen
                                      : AppColors.primaryBlue)
                                  .withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(130),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              // Live Webcam Stream or Fallback Silhouette
                              if (_cameraReady)
                                _cameraHelper.buildPreview()
                              else
                                Center(
                                  child: Icon(
                                    Icons.face_rounded,
                                    size: 180,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),

                              // Scanning Laser Bar (animated)
                              if (_isLoading)
                                AnimatedBuilder(
                                  animation: _scanAnimation,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(0, _scanAnimation.value),
                                      child: Container(
                                        height: 4,
                                        width: 220,
                                        decoration: BoxDecoration(
                                          color: AppColors.mintGreen,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.mintGreen.withOpacity(0.8),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Success Checkmark Overlay
                      if (_isSuccess)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.mintGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Error Banner (if any)
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Explicit Biometric Consent Checkbox (Enforced for Enrollment)
              if (isEnrollMode) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _consentGranted,
                        activeColor: AppColors.mintGreen,
                        onChanged: (val) {
                          setState(() {
                            _consentGranted = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I grant consent to store an AES-256 encrypted biometric template solely for secure senior sign-in. Raw photos are discarded immediately.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Primary Action: Capture & Authenticate Button
              CustomButton(
                label: _isLoading
                    ? 'Processing Biometrics...'
                    : (isEnrollMode ? 'Capture & Complete Enrollment' : 'Verify Face & Sign In'),
                icon: Icons.camera_alt_rounded,
                height: 56,
                borderRadius: 16,
                backgroundColor: AppColors.primaryBlue,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleCaptureAndProceed,
              ),

              if (!isEnrollMode) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.mintGreen, size: 18),
                  label: const Text(
                    'Face not matching? Update / Re-enroll Face',
                    style: TextStyle(
                      color: AppColors.mintGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _isLoading ? null : _showReEnrollDialog,
                ),
              ],

              const SizedBox(height: 12),

              // Recovery / Assisted Login Fallback for Seniors
              TextButton.icon(
                icon: const Icon(Icons.password_rounded, color: Colors.white70, size: 18),
                label: const Text(
                  'Assisted Login / Sign In with Password',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: _navigateToPasswordFallback,
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
