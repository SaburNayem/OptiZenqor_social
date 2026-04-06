import 'package:flutter/material.dart';

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
            ? const Color(0xFF26C6DA).withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.1),
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
                  Icon(leading, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
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
