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
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late UserRole _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _setDefaultCredentialsForDemo(_selectedRole);
  }

  void _setDefaultCredentialsForDemo(UserRole role) {
    switch (role) {
      case UserRole.senior:
        _identifierController.text = 'dadaji@elderlyseva.org';
        _passwordController.text = '••••••••';
        break;
      case UserRole.family:
        _identifierController.text = 'rajesh.sharma@example.com';
        _passwordController.text = '••••••••';
        break;
      case UserRole.caregiver:
        _identifierController.text = 'anjali.rao@sevacare.org';
        _passwordController.text = '••••••••';
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
      _setDefaultCredentialsForDemo(role);
    });
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulated short delay for UI realism before routing
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Route to selected role interface
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

                // Email / Phone Field
                CustomTextField(
                  label: 'Email or Mobile Number',
                  hint: 'Enter your registered email or phone',
                  prefixIcon: Icons.alternate_email_rounded,
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your secure password',
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
                  label: 'Sign In as ${_selectedRole == UserRole.senior ? 'Senior Citizen' : _selectedRole == UserRole.family ? 'Family Member' : 'Caregiver'}',
                  isLoading: _isLoading,
                  height: 56,
                  borderRadius: 18,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 14),

                // Backend integration note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.api_rounded, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Integration Point: POST /api/v1/auth/login. Role triggers corresponding persona workspace.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Navigate to Registration
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

