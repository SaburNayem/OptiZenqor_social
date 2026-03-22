import 'package:flutter/material.dart';

import '../controller/media_viewer_controller.dart';

class MediaViewerScreen extends StatelessWidget {
  const MediaViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MediaViewerController();

    return Scaffold(
      appBar: AppBar(title: const Text('Media Viewer')),
      body: PageView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(item.url, fit: BoxFit.contain),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    'Type: ${item.type}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
