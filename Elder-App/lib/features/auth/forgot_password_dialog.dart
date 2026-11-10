import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _contactController = TextEditingController();
  bool _isSent = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email or phone number.')),
      );
      return;
    }

    setState(() {
      _isSent = true;
    });

    // Backend Integration Point: POST /api/v1/auth/forgot-password
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Reset Password',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_isSent) ...[
              const Text(
                'Enter your registered email address or phone number to receive a secure password reset link or OTP.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email or Mobile Number',
                hint: 'e.g. dadaji@example.com or +1...',
                prefixIcon: Icons.contact_mail_rounded,
                controller: _contactController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              CustomButton(
                label: 'Send Reset Link',
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '[Backend: POST /api/v1/auth/forgot-password]',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.mintGreen,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Password Reset Sent!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mintGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A password recovery verification has been dispatched to "${_contactController.text}".',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                label: 'Return to Login',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

