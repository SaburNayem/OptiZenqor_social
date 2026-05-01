import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LiveAudienceChip extends StatelessWidget {
  const LiveAudienceChip({
    required this.label,
    required this.onTap,
    this.leading,
    this.selected = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? leading;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      child: Material(
        color: selected
            ? AppColors.hexFF26C6DA.withValues(alpha: 0.24)
            : AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, color: AppColors.white, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
