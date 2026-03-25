import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  bool _isTypeMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Placeholder
          _isTypeMode
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE57373), Color(0xFFF06292)],
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1200',
                    fit: BoxFit.cover,
                  ),
                ),

          // Top UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  if (!_isTypeMode)
                    Row(
                      children: [
                        _buildTopAction(Icons.flash_on),
                        const SizedBox(width: 16),
                        _buildTopAction(Icons.settings_outlined),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gallery / Filter
                    _isTypeMode
                        ? _buildRoundButton(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.redAccent, Colors.pinkAccent],
                                ),
                              ),
                            ),
                          )
                        : _buildRoundButton(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                      'https://picsum.photos/seed/gallery/100/100'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(width: 30),

                    // Main Capture / Type Button
                    _isTypeMode
                        ? Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 15),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'Aa',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(width: 30),

                    // Camera Switch / Drawing
                    _isTypeMode
                        ? _buildRoundButton(
                            child: const Icon(Icons.gesture,
                                color: Colors.black87, size: 28),
                          )
                        : _buildRoundButton(
                            child: const Icon(Icons.flip_camera_ios_outlined,
                                color: Colors.black87, size: 28),
                          ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isTypeMode = true),
                      child: Text(
                        'TYPE',
                        style: TextStyle(
                          color: _isTypeMode ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () => setState(() => _isTypeMode = false),
                      child: Text(
                        'PHOTO',
                        style: TextStyle(
                          color: !_isTypeMode ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildRoundButton({required Widget child}) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}
