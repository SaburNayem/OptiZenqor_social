import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class MainShellBottomNavBar extends StatelessWidget {
  const MainShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 70,
      color: AppColors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavBarItem(
            icon: Icons.play_circle_outline,
            activeIcon: Icons.play_circle_filled_rounded,
            label: 'Reels',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          const SizedBox(width: 48),
          _NavBarItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Chat',
            isSelected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            isSelected: selectedIndex == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? AppColors.hexFF26C6DA : AppColors.grey400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
