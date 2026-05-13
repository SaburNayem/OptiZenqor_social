import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class MainShellBottomNavBar extends StatelessWidget {
  const MainShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.showChatUnreadDot = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showChatUnreadDot;

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
            showDot: showChatUnreadDot,
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
    this.showDot = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? AppColors.hexFF26C6DA : AppColors.grey400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(isSelected ? activeIcon : icon, color: color, size: 26),
                if (showDot)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.hexFF26C6DA,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
