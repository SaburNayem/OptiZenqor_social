import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.imageUrl,
    super.key,
    this.radius = 20,
    this.verified = false,
  });

  final String imageUrl;
  final double radius;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? imageProvider = _imageProviderFor(imageUrl);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          foregroundImage: imageProvider,
          onForegroundImageError: (_, _) {},
          child: Icon(
            Icons.person_rounded,
            size: radius,
            color: AppColors.grey600,
          ),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: radius * 0.25,
              backgroundColor: AppColors.blue,
              child: Icon(
                Icons.check,
                size: radius * 0.25,
                color: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }

  ImageProvider<Object>? _imageProviderFor(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return NetworkImage(trimmed);
  }
}

