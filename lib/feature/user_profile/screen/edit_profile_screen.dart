import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/mock/mock_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final user = MockData.users.first;

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _locationController;

  File? _profileImageFile;
  File? _coverImageFile;
  Offset _profileImageOffset = Offset.zero;
  Offset _coverImageOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(
      text: 'Digital nomad and visual storyteller.',
    );
    _websiteController = TextEditingController(text: 'https://optizenqor.app');
    _locationController = TextEditingController(text: 'Dhaka, Bangladesh');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _buildCoverEditor(),
          Transform.translate(
            offset: const Offset(0, -34),
            child: Center(child: _buildAvatarEditor()),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildField(
                  controller: _nameController,
                  label: 'Name',
                ),
                _buildField(
                  controller: _usernameController,
                  label: 'Username',
                  prefixText: '@',
                ),
                _buildField(
                  controller: _bioController,
                  label: 'Bio',
                  maxLines: 4,
                ),
                _buildField(
                  controller: _websiteController,
                  label: 'Website',
                ),
                _buildField(
                  controller: _locationController,
                  label: 'Location',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverEditor() {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _coverImageOffset += details.delta;
            });
          },
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _coverImageFile != null
                ? ClipRect(
                    child: Transform.translate(
                      offset: _coverImageOffset,
                      child: Transform.scale(
                        scale: 1.18,
                        child: Image.file(
                          _coverImageFile!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(color: const Color(0xFF26C6DA)),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _pickImage(isCover: true),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Edit cover photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 12,
          bottom: 16,
          child: Text(
            'Drag to adjust',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarEditor() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _profileImageOffset += details.delta;
              });
            },
            child: ClipOval(
              child: SizedBox(
                width: 108,
                height: 108,
                child: Transform.translate(
                  offset: _profileImageOffset,
                  child: Transform.scale(
                    scale: 1.18,
                    child: Image(
                      image: _profileImageFile != null
                          ? FileImage(_profileImageFile!)
                          : NetworkImage(user.avatar) as ImageProvider,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: InkWell(
            onTap: () => _pickImage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF26C6DA),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        const Positioned(
          left: -4,
          bottom: -28,
          child: SizedBox(
            width: 120,
            child: Text(
              'Drag photo to adjust',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage({bool isCover = false}) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) {
      return;
    }

    final XFile? file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) {
      return;
    }

    setState(() {
      if (isCover) {
        _coverImageFile = File(file.path);
        _coverImageOffset = Offset.zero;
      } else {
        _profileImageFile = File(file.path);
        _profileImageOffset = Offset.zero;
      }
    });
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Profile changes saved locally')),
      );
  }
}
