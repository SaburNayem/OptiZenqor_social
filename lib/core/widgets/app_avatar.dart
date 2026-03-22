import 'package:flutter/material.dart';

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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(imageUrl),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: radius * 0.25,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.check,
                size: radius * 0.25,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
