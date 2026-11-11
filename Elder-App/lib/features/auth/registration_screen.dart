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
import 'face_biometric_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final UserRole initialRole;

  const RegistrationScreen({
    super.key,
    this.initialRole = UserRole.senior,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthApiService _apiService = AuthApiService();

  // Core fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Role-specific fields
  final TextEditingController _preferredNameController = TextEditingController(text: 'दादाजी');
  final TextEditingController _ageController = TextEditingController(text: '72');
  final TextEditingController _relationshipController = TextEditingController(text: 'Son');
  final TextEditingController _cityController = TextEditingController(text: 'Delhi NCR');
  final TextEditingController _hourlyRateController = TextEditingController(text: '300');

  late UserRole _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _preferredNameController.dispose();
    _ageController.dispose();
    _relationshipController.dispose();
    _cityController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_selectedRole == UserRole.senior) {
        // 1. Register Senior in Database
        await _apiService.registerSenior(
          fullName: name,
          phoneNumber: phone,
          password: password,
          preferredName: _preferredNameController.text.trim(),
          email: email.isNotEmpty ? email : null,
          age: int.tryParse(_ageController.text.trim()) ?? 70,
          gender: 'other',
        );

        // 2. Perform background login to acquire token for face biometric enrollment
        await _apiService.loginPassword(
          identifier: phone,
          password: password,
          role: UserRole.senior,
        );

        final token = _apiService.accessToken;

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // 3. Navigate directly to Face Biometric Enrollment screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senior profile created! Proceed to face enrollment.'),
            backgroundColor: AppColors.mintGreen,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FaceBiometricScreen(
              mode: FaceScreenMode.enroll,
              identifier: phone,
              tempAccessToken: token,
              fullName: name,
            ),
          ),
        );
      } else if (_selectedRole == UserRole.family) {
        // Register Family Member
        await _apiService.registerFamily(
          fullName: name,
          phoneNumber: phone,
          password: password,
          email: email.isNotEmpty ? email : null,
          relationshipType: _relationshipController.text.trim(),
        );

        // Automatic login to establish session
        await _apiService.loginPassword(
          identifier: phone,
          password: password,
          role: UserRole.family,
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome $name! Family account ready.'),
            backgroundColor: AppColors.mintGreen,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FamilyDashboardScreen()),
          (route) => false,
        );
      } else if (_selectedRole == UserRole.caregiver) {
        // Register Caretaker / Caregiver
        await _apiService.registerCaregiver(
          fullName: name,
          phoneNumber: phone,
          password: password,
          email: email.isNotEmpty ? email : null,
          serviceCity: _cityController.text.trim(),
          hourlyRate: double.tryParse(_hourlyRateController.text.trim()) ?? 250.0,
        );

        // Automatic login to establish session
        await _apiService.loginPassword(
          identifier: phone,
          password: password,
          role: UserRole.caregiver,
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome $name! Caretaker portal ready.'),
            backgroundColor: AppColors.mintGreen,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
          (route) => false,
        );
      }
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account', style: AppTextStyles.titleLarge),
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
                const Text(
                  'Join Elderly Seva',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign up to support and care for your loved ones with peace of mind.',
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 20),

                // Select Account Role
                const Text(
                  'I am registering as:',
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
                      onTap: () {
                        setState(() {
                          _selectedRole = UserRole.senior;
                        });
                      },
                    ),
                    RoleBadge(
                      role: UserRole.family,
                      isSelected: _selectedRole == UserRole.family,
                      onTap: () {
                        setState(() {
                          _selectedRole = UserRole.family;
                        });
                      },
                    ),
                    RoleBadge(
                      role: UserRole.caregiver,
                      isSelected: _selectedRole == UserRole.caregiver,
                      onTap: () {
                        setState(() {
                          _selectedRole = UserRole.caregiver;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Notice Banner for Senior
                if (_selectedRole == UserRole.senior)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.face_retouching_natural_rounded, color: AppColors.primaryBlue, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Step 1: Enter basic details. Step 2: Enroll your face for quick passwordless login.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.navy, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: _selectedRole == UserRole.senior ? 'e.g. Kailash Chand Sharma' : 'e.g. Ramesh Sharma',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone Number
                CustomTextField(
                  label: 'Mobile Number (Primary Login ID)',
                  hint: 'e.g. +91 98765 43210',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.trim().length < 8) {
                      return 'Please enter a valid mobile number with country code';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email Address (Optional for senior, required for family/caregiver)
                CustomTextField(
                  label: _selectedRole == UserRole.senior ? 'Email Address (Optional)' : 'Email Address',
                  hint: 'e.g. name@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_selectedRole != UserRole.senior) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an email address';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Role-Specific Inputs
                if (_selectedRole == UserRole.senior) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Preferred Name',
                          hint: 'e.g. दादाजी',
                          prefixIcon: Icons.sentiment_satisfied_alt_rounded,
                          controller: _preferredNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Age',
                          hint: 'e.g. 74',
                          prefixIcon: Icons.cake_outlined,
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedRole == UserRole.family) ...[
                  CustomTextField(
                    label: 'Relationship to Senior',
                    hint: 'e.g. Son, Daughter, Grandchild, Relative',
                    prefixIcon: Icons.family_restroom_rounded,
                    controller: _relationshipController,
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedRole == UserRole.caregiver) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Service City',
                          hint: 'e.g. Delhi NCR',
                          prefixIcon: Icons.location_city_rounded,
                          controller: _cityController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Hourly Rate (₹)',
                          hint: 'e.g. 300',
                          prefixIcon: Icons.currency_rupee_rounded,
                          controller: _hourlyRateController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password (min 6 characters)',
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_reset_rounded,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Terms and conditions checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _agreedToTerms = val ?? true;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to Elderly Seva Terms of Care & HIPAA/Privacy Guidelines',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Register Button
                CustomButton(
                  label: _selectedRole == UserRole.senior
                      ? 'Continue to Face Enrollment'
                      : 'Create Account',
                  isLoading: _isLoading,
                  height: 56,
                  borderRadius: 18,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: 24),

                // Switch to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(initialRole: _selectedRole),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
