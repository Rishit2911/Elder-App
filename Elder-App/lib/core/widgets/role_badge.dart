import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback? onTap;

  const RoleBadge({
    super.key,
    required this.role,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);
    final label = _getRoleLabel(role);
    final icon = _getRoleIcon(role);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(77),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.senior:
        return AppColors.seniorRole;
      case UserRole.family:
        return AppColors.familyRole;
      case UserRole.caregiver:
        return AppColors.caregiverRole;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.senior:
        return 'Senior Citizen';
      case UserRole.family:
        return 'Family Member';
      case UserRole.caregiver:
        return 'Caregiver';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.senior:
        return Icons.elderly_rounded;
      case UserRole.family:
        return Icons.family_restroom_rounded;
      case UserRole.caregiver:
        return Icons.volunteer_activism_rounded;
    }
  }
}

