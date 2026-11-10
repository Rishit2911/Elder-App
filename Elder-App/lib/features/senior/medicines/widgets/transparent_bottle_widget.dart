import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A realistic transparent glass/acrylic medicine bottle widget.
/// Strictly renders an individual transparent container showing only ONE medicine type,
/// visible pills inside, glass reflections, screw cap, and remaining quantity.
class TransparentBottleWidget extends StatelessWidget {
  final MedicineModel medicine;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onRefillRequest;
  final double width;
  final double height;

  const TransparentBottleWidget({
    super.key,
    required this.medicine,
    this.isSelected = false,
    this.onTap,
    this.onMarkTaken,
    this.onRefillRequest,
    this.width = 110,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isSelected ? Colors.white : Colors.white.withAlpha(200),
          border: Border.all(
            color: isSelected
                ? medicine.pillColor
                : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? medicine.pillColor.withAlpha(60)
                  : Colors.black.withAlpha(15),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Tag: Taken / Pending / Refill
            _buildStatusTag(),
            const SizedBox(height: 6),

            // Realistic Transparent Glass Bottle Graphic
            SizedBox(
              width: width - 12,
              height: height * 0.58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glass bottle custom painter
                  CustomPaint(
                    size: Size(width - 12, height * 0.58),
                    painter: _GlassBottlePainter(
                      pillColor: medicine.pillColor,
                      remainingCount: medicine.remainingQuantity,
                      totalCapacity: medicine.totalCapacity,
                      liquidTint: medicine.liquidTint,
                    ),
                  ),

                  // Center glass label badge with tablet count
                  Positioned(
                    bottom: 22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: medicine.pillColor.withAlpha(150),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medication_rounded,
                            size: 13,
                            color: medicine.pillColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${medicine.remainingQuantity}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Taken checkmark overlay badge
                  if (medicine.isTakenToday)
                    Positioned(
                      top: 18,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.mintGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Medicine Name - Clean and readable
            Text(
              medicine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: 13.5,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 3),

            // Dosage & Schedule Timing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  medicine.timingIcon,
                  size: 13,
                  color: medicine.pillColor,
                ),
                const SizedBox(width: 4),
                Text(
                  medicine.scheduleTime,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),

            // Remaining Quantity Text
            Text(
              '${medicine.remainingQuantity} tablets left',
              style: TextStyle(
                fontSize: 11,
                fontWeight: medicine.needsRefill ? FontWeight.w700 : FontWeight.w500,
                color: medicine.needsRefill ? AppColors.coralRed : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    if (medicine.isTakenToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.mintBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Taken Today',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.mintGreen,
          ),
        ),
      );
    }

    if (medicine.needsRefill) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.coralLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Refill Soon',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.coralRed,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cyanBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        medicine.timingLabel,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.cyanAccent,
        ),
      ),
    );
  }
}

/// Custom painter for rendering a 3D transparent glass medicine bottle with reflections and tablets
class _GlassBottlePainter extends CustomPainter {
  final Color pillColor;
  final int remainingCount;
  final int totalCapacity;
  final Color liquidTint;

  _GlassBottlePainter({
    required this.pillColor,
    required this.remainingCount,
    required this.totalCapacity,
    required this.liquidTint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Dimensions
    final double capWidth = width * 0.46;
    final double capHeight = height * 0.15;
    final double neckHeight = height * 0.08;
    final double bodyWidth = width * 0.86;
    final double bodyHeight = height * 0.70;
    final double bodyCornerRadius = 14.0;

    final double centerX = width / 2;
    final double capTop = 2.0;
    final double neckTop = capTop + capHeight - 2;
    final double bodyTop = neckTop + neckHeight - 2;

    // 1. Draw Cap with ridges
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, capTop + capHeight / 2),
        width: capWidth,
        height: capHeight,
      ),
      const Radius.circular(5),
    );

    // Cap gradient (clean white-gray pharmaceutical ribbed cap)
    final capPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.grey.shade300,
          Colors.white,
          Colors.grey.shade200,
          Colors.grey.shade400,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(capRect.outerRect);
    canvas.drawRRect(capRect, capPaint);

    // Cap border
    final capBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0;
    canvas.drawRRect(capRect, capBorderPaint);

    // Cap vertical grip ridges
    final ridgePaint = Paint()
      ..color = Colors.grey.shade400.withAlpha(120)
      ..strokeWidth = 1.0;
    for (double i = -capWidth * 0.32; i <= capWidth * 0.32; i += 4.5) {
      canvas.drawLine(
        Offset(centerX + i, capTop + 3),
        Offset(centerX + i, capTop + capHeight - 3),
        ridgePaint,
      );
    }

    // 2. Draw Glass Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, bodyTop + bodyHeight / 2),
        width: bodyWidth,
        height: bodyHeight,
      ),
      Radius.circular(bodyCornerRadius),
    );

    // Subtle glass body fill with light tint
    final glassFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withAlpha(180),
          liquidTint.withAlpha(80),
          liquidTint.withAlpha(130),
          Colors.white.withAlpha(160),
        ],
        stops: const [0.0, 0.3, 0.75, 1.0],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, glassFillPaint);

    // 3. Draw pills inside the bottle
    // Tablets are drawn near the bottom/center proportional to remaining count
    final pillPaint = Paint()
      ..color = pillColor
      ..style = PaintingStyle.fill;

    final pillHighlightPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.fill;

    final pillShadowPaint = Paint()
      ..color = Colors.black.withAlpha(40)
      ..style = PaintingStyle.fill;

    final random = math.Random(pillColor.toARGB32());
    final int pillsToRender = math.min(10, math.max(3, (remainingCount / 2).ceil()));

    final double pillAreaBottom = bodyTop + bodyHeight - 10;
    final double pillAreaTop = bodyTop + bodyHeight * 0.40;

    for (int i = 0; i < pillsToRender; i++) {
      final double px = centerX + (random.nextDouble() * 2 - 1) * (bodyWidth * 0.28);
      final double py = pillAreaBottom - (random.nextDouble() * (pillAreaBottom - pillAreaTop));
      final double pRadius = 7.0 + (random.nextDouble() * 2.5);

      // Pill drop shadow
      canvas.drawCircle(Offset(px, py + 1.5), pRadius, pillShadowPaint);
      // Pill body
      canvas.drawCircle(Offset(px, py), pRadius, pillPaint);
      // Pill glossy reflection arc
      canvas.drawCircle(Offset(px - 2, py - 2), pRadius * 0.35, pillHighlightPaint);
    }

    // 4. Glass reflection specular highlight (Left edge vertical gleam)
    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(220),
          Colors.white.withAlpha(120),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(
        Rect.fromLTWH(
          centerX - bodyWidth * 0.42,
          bodyTop + 4,
          bodyWidth * 0.22,
          bodyHeight - 8,
        ),
      );

    final reflectionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - bodyWidth * 0.40,
        bodyTop + 6,
        bodyWidth * 0.16,
        bodyHeight - 14,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(reflectionRect, reflectionPaint);

    // 5. Outer Glass Stroke & Border
    final glassBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(240),
          Colors.blueGrey.shade200.withAlpha(180),
          pillColor.withAlpha(100),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, glassBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassBottlePainter oldDelegate) {
    return oldDelegate.remainingCount != remainingCount ||
        oldDelegate.pillColor != pillColor ||
        oldDelegate.liquidTint != liquidTint;
  }
}
