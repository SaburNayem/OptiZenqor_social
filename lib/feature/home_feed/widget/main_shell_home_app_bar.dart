import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_get.dart';
import '../../../app_route/route_names.dart';

class MainShellHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MainShellHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: 16,
      title: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => AppGet.toNamed(RouteNames.searchDiscovery),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.hexFFF4F6F8,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.grey600),
              const SizedBox(width: 10),
              Text(
                'Search',
                style: TextStyle(color: AppColors.grey600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => AppGet.toNamed(RouteNames.notifications),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.black87,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
