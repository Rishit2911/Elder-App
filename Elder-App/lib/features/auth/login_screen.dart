import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/role_badge.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_api_service.dart';
import '../caregiver/caregiver_dashboard_screen.dart';
import '../family/family_dashboard_screen.dart';
import '../senior/senior_dashboard_screen.dart';
import 'face_biometric_screen.dart';
import 'forgot_password_dialog.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.senior,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthApiService _apiService = AuthApiService();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late UserRole _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showSeniorPasswordFallback = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _setDefaultCredentialsForDemo(_selectedRole);
  }

  void _setDefaultCredentialsForDemo(UserRole role) {
    switch (role) {
      case UserRole.senior:
        _identifierController.text = '+919876543210';
        _passwordController.text = 'ValidPassword123!';
        break;
      case UserRole.family:
        _identifierController.text = '+919812345678';
        _passwordController.text = 'StrongPassword123!';
        break;
      case UserRole.caregiver:
        _identifierController.text = '+919845678901';
        _passwordController.text = 'CaregiverPass123!';
        break;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _showSeniorPasswordFallback = false;
      _setDefaultCredentialsForDemo(role);
    });
  }

  /// Launch Face Recognition Login for Senior Citizen
  void _launchSeniorFaceLogin() {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your registered mobile number first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceBiometricScreen(
          mode: FaceScreenMode.verify,
          identifier: identifier,
        ),
      ),
    );
  }

  /// Standard Password-based Authentication (Family, Caregiver, Senior Fallback)
  Future<void> _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    try {
      final user = await _apiService.loginPassword(
        identifier: identifier,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Show welcome toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${user.fullName}!'),
          backgroundColor: AppColors.mintGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Role-Enforced Route Dispatch
      Widget targetScreen;
      switch (user.role) {
        case UserRole.senior:
          targetScreen = const SeniorDashboardScreen();
          break;
        case UserRole.family:
          targetScreen = const FamilyDashboardScreen();
          break;
        case UserRole.caregiver:
          targetScreen = const CaregiverDashboardScreen();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSenior = _selectedRole == UserRole.senior;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sign In', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select your role to access your personalized elderly care interface.',
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 22),

                // Role Selector Pills
                const Text(
                  'Select Role to Enter:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    RoleBadge(
                      role: UserRole.senior,
                      isSelected: _selectedRole == UserRole.senior,
                      onTap: () => _handleRoleChanged(UserRole.senior),
                    ),
                    RoleBadge(
                      role: UserRole.family,
                      isSelected: _selectedRole == UserRole.family,
                      onTap: () => _handleRoleChanged(UserRole.family),
                    ),
                    RoleBadge(
                      role: UserRole.caregiver,
                      isSelected: _selectedRole == UserRole.caregiver,
                      onTap: () => _handleRoleChanged(UserRole.caregiver),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =============================================================
                // ROLE SPECIFIC VIEW 1: SENIOR CITIZEN FACE AUTHENTICATION
                // =============================================================
                if (isSenior) ...[
                  // Senior Phone / Identifier Input
                  CustomTextField(
                    label: 'Senior Mobile Number or ID',
                    hint: 'e.g. +91 98765 43210',
                    prefixIcon: Icons.phone_android_rounded,
                    controller: _identifierController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Big Prominent Face Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 50,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Passwordless Face Sign-In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Look at the camera for instant biometric login verified with ArcFace encryption.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          label: 'Open Camera & Scan Face',
                          icon: Icons.camera_alt_rounded,
                          height: 54,
                          borderRadius: 16,
                          backgroundColor: AppColors.primaryBlue,
                          onPressed: _launchSeniorFaceLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Assisted Fallback Toggle
                  Center(
                    child: TextButton.icon(
                      icon: Icon(
                        _showSeniorPasswordFallback
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.lock_outline_rounded,
                        size: 18,
                        color: AppColors.navyMuted,
                      ),
                      label: Text(
                        _showSeniorPasswordFallback
                            ? 'Hide Password Login'
                            : 'Assisted Login: Sign in with Password',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSeniorPasswordFallback = !_showSeniorPasswordFallback;
                        });
                      },
                    ),
                  ),

                  // Collapsible Password Fallback Form for Senior
                  if (_showSeniorPasswordFallback) ...[
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Senior Account Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      label: 'Sign In with Password',
                      isLoading: _isLoading,
                      height: 52,
                      borderRadius: 16,
                      backgroundColor: AppColors.navy,
                      onPressed: _handlePasswordLogin,
                    ),
                  ],
                ]

                // =============================================================
                // ROLE SPECIFIC VIEW 2 & 3: FAMILY & CAREGIVER PASSWORD LOGIN
                // =============================================================
                else ...[
                  // Email / Phone Field
                  CustomTextField(
                    label: _selectedRole == UserRole.family
                        ? 'Family Mobile Number or Email'
                        : 'Caregiver Mobile Number or Email',
                    hint: 'e.g. +91 98123 45678 or name@example.com',
                    prefixIcon: _selectedRole == UserRole.family
                        ? Icons.family_restroom_rounded
                        : Icons.badge_outlined,
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your registered mobile or email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Forgot Password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const ForgotPasswordDialog(),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sign In Button
                  CustomButton(
                    label: _selectedRole == UserRole.family
                        ? 'Sign In to Family Dashboard'
                        : 'Sign In to Caretaker Portal',
                    isLoading: _isLoading,
                    height: 56,
                    borderRadius: 18,
                    onPressed: _handlePasswordLogin,
                  ),
                ],

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationScreen(initialRole: _selectedRole),
                          ),
                        );
                      },
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Instant Preview Hub for Evaluation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Instant Dashboard Previews',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.elderly_rounded, size: 16, color: AppColors.primaryBlue),
                            label: const Text('Senior', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SeniorDashboardScreen()),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.family_restroom_rounded, size: 16, color: AppColors.familyRole),
                            label: const Text('Family', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.familyRole,
                              side: const BorderSide(color: AppColors.familyRole),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FamilyDashboardScreen()),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.medical_services_rounded, size: 16, color: AppColors.mintGreen),
                            label: const Text('Caregiver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mintGreen,
                              side: const BorderSide(color: AppColors.mintGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
