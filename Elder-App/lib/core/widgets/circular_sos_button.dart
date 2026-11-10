import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Perfectly circular emergency SOS button.
/// Strictly displays exactly one text label: "SOS" with bold high-contrast white text,
/// without repeating the word or adding redundant icons inside the button.
class CircularSOSButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const CircularSOSButton({
    super.key,
    this.onPressed,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.coralRed,
        boxShadow: [
          BoxShadow(
            color: AppColors.coralRed.withAlpha(115),
            blurRadius: 14,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(204),
          width: 2.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ??
              () {
                Navigator.of(context).pushNamed('/emergency-sos');
              },
          child: const Center(
            child: Text(
              'SOS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

