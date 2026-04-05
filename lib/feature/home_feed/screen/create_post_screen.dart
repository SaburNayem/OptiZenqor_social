import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';

class CreatePostResult {
  const CreatePostResult({
    required this.caption,
    this.mediaUrl,
    this.isVideo = false,
    this.audience = 'Everyone',
    this.location,
    this.taggedPeople = const <String>[],
    this.coAuthors = const <String>[],
    this.altText,
    this.editHistory = const <String>[],
  });

  final String caption;
  final String? mediaUrl;
  final bool isVideo;
  final String audience;
  final String? location;
  final List<String> taggedPeople;
  final List<String> coAuthors;
  final String? altText;
  final List<String> editHistory;
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Share',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(currentUser.avatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _captionController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Dotted Image Placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                        style: BorderStyle
                            .solid, // Note: standard Border doesn't support dotted easily
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add photo or video',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // List of Options
                  _buildOptionItem(
                    Icons.add_photo_alternate,
                    'Photo / Video',
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                  _buildOptionItem(
                    Icons.videocam_outlined,
                    'Go Live',
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFF5252),
                  ),
                  _buildOptionItem(
                    Icons.location_on_outlined,
                    'Check in',
                    const Color(0xFFE3F2FD),
                    const Color(0xFF42A5F5),
                  ),
                  _buildOptionItem(
                    Icons.sentiment_satisfied_alt_outlined,
                    'Feeling / Activity',
                    const Color(0xFFFFFDE7),
                    const Color(0xFFFFD600),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Icon Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFF26C6DA),
                  ),
                  onPressed: () {
                    AppGet.snackbar('Media', 'Static media picker opened');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.tag, color: Color(0xFF26C6DA)),
                  onPressed: () {
                    AppGet.snackbar('Tag People', 'Static tag people flow opened');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Color(0xFF26C6DA),
                  ),
                  onPressed: () {
                    AppGet.snackbar('Feeling', 'Static feeling selector opened');
                  },
                ),
                const Spacer(),
                const Text(
                  '0 / 280',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) return;
    AppGet.back(result: CreatePostResult(caption: caption));
  }
}
