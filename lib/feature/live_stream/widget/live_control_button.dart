import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LiveControlButton extends StatelessWidget {
  const LiveControlButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.highlight = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.hexFF26C6DA : AppColors.white;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: highlight ? 1.06 : 1),
      duration: const Duration(milliseconds: 220),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: AppColors.white.withValues(alpha: active ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(icon, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
