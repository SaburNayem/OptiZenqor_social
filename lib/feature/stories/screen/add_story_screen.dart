import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/service/media_picker_service.dart';
import '../../../core/functions/app_feedback.dart';

enum StoryComposerMode { gallery, text, music, collage }

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final MediaPickerService _mediaPickerService = MediaPickerService();
  bool _isMultiSelectEnabled = false;
  
  // Dummy data for gallery
  final List<String> _galleryItems = List.generate(
    12,
    (index) => 'https://picsum.photos/seed/${index + 50}/400/600',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildComposerOptions(),
          const SizedBox(height: 24),
          _buildGalleryHeader(),
          const SizedBox(height: 12),
          Expanded(child: _buildGalleryGrid()),
        ],
      ),
      floatingActionButton: _buildCameraButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black, size: 28),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Create story',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 28),
          onPressed: () {
            AppFeedback.showSnackbar(
              title: 'Settings',
              message: 'Story settings coming soon',
            );
          },
        ),
      ],
    );
  }

  Widget _buildComposerOptions() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildOptionCard(
            child: const Text(
              'Aa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            label: 'Text',
            onTap: () {},
          ),
          _buildOptionCard(
            icon: Icons.music_note_outlined,
            label: 'Music',
            onTap: () {},
          ),
          _buildOptionCard(
            icon: Icons.auto_awesome_mosaic_outlined,
            label: 'Collage',
            onTap: () {},
          ),
          _buildOptionCard(
            icon: Icons.videocam_outlined,
            label: 'Selfie',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    IconData? icon,
    Widget? child,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null) child else Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 28),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isMultiSelectEnabled = !_isMultiSelectEnabled;
              });
            },
            icon: const Icon(Icons.collections_outlined, size: 20),
            label: Text(
              _isMultiSelectEnabled ? 'Multiple on' : 'Select multiple',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.8,
      ),
      itemCount: _galleryItems.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _galleryItems[index],
              fit: BoxFit.cover,
            ),
            if (index == 0)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '00:06',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (index == 1) // Mocking a selected item
              Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCameraButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 0),
      child: FloatingActionButton(
        onPressed: () async {
          final path = await _mediaPickerService.captureImage();
          if (path != null) {
            AppFeedback.showSnackbar(
              title: 'Success',
              message: 'Captured image: $path',
            );
          }
        },
        backgroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.camera_alt,
          color: Color(0xFF2E6FF1), // Blue color from the image
          size: 28,
        ),
      ),
    );
  }
}
