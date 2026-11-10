import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/role_badge.dart';
import '../../data/models/user_model.dart';
import '../caregiver/caregiver_dashboard_screen.dart';
import '../family/family_dashboard_screen.dart';
import '../senior/senior_dashboard_screen.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Route to role-specific dashboard
      Widget targetScreen;
      switch (_selectedRole) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully for ${_nameController.text.trim()}!\n[Integration: POST /api/v1/auth/register]',
          ),
          backgroundColor: AppColors.mintGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
        (route) => false,
      );
    });
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

                const SizedBox(height: 22),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'e.g. Ramesh Sharma',
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

                // Email Address
                CustomTextField(
                  label: 'Email Address',
                  hint: 'e.g. name@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone Number
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g. +1 (555) 000-0000',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a strong password (min 8 characters)',
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
                  label: 'Create Account',
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

