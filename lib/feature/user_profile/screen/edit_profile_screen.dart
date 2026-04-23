import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/service/upload_service.dart';
import '../../../core/navigation/app_get.dart';
import '../model/profile_update_model.dart';
import '../repository/user_profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final UserProfileRepository _repository = UserProfileRepository();
  final UploadService _uploadService = UploadService();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _locationController;

  UserModel? _user;
  File? _profileImageFile;
  File? _coverImageFile;
  Offset _profileImageOffset = Offset.zero;
  Offset _coverImageOffset = Offset.zero;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _websiteController = TextEditingController();
    _locationController = TextEditingController();
    _loadProfile();
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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final UserModel? profile = await _repository.getCurrentProfile();
    if (!mounted) {
      return;
    }

    _user = profile;
    _nameController.text = profile?.name ?? '';
    _usernameController.text = profile?.username ?? '';
    _bioController.text = profile?.bio ?? '';
    _websiteController.text = profile?.website ?? '';
    _locationController.text = profile?.location ?? '';

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading || _isSaving ? null : _saveProfile,
            child: Text(_isSaving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
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
          onPanUpdate: (DragUpdateDetails details) {
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
                : _user?.coverImageUrl.trim().isNotEmpty == true
                ? ClipRect(
                    child: Transform.translate(
                      offset: _coverImageOffset,
                      child: Transform.scale(
                        scale: 1.04,
                        child: Image.network(
                          _user!.coverImageUrl.trim(),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(color: AppColors.hexFF26C6DA),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: AppColors.black.withValues(alpha: 0.45),
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
                      color: AppColors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Edit cover photo',
                      style: TextStyle(
                        color: AppColors.white,
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
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarEditor() {
    final ImageProvider imageProvider = _profileImageFile != null
        ? FileImage(_profileImageFile!)
        : (_user?.avatar.trim().isNotEmpty == true
              ? NetworkImage(_user!.avatar.trim())
              : const NetworkImage('https://placehold.co/120x120'))
            as ImageProvider;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
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
                      image: imageProvider,
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
                color: AppColors.hexFF26C6DA,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.white,
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
                color: AppColors.grey,
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
      builder: (BuildContext context) {
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

  Future<void> _saveProfile() async {
    final String name = _nameController.text.trim();
    final String username = _usernameController.text.trim();
    if (name.isEmpty || username.isEmpty) {
      AppGet.snackbar('Edit Profile', 'Name and username are required.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? avatarUrl = _user?.avatar;
      String? coverImageUrl = _user?.coverImageUrl;
      final List<String> warnings = <String>[];

      if (_profileImageFile != null) {
        try {
          avatarUrl = await _uploadImage(
            _profileImageFile!.path,
            folder: 'optizenqor/profile/avatar',
          );
        } catch (_) {
          warnings.add('Avatar upload was skipped.');
        }
      }

      if (_coverImageFile != null) {
        try {
          coverImageUrl = await _uploadImage(
            _coverImageFile!.path,
            folder: 'optizenqor/profile/cover',
          );
        } catch (_) {
          warnings.add('Cover upload was skipped.');
        }
      }

      final ProfileSaveResult result = await _repository.updateCurrentProfile(
        ProfileUpdateModel(
          name: name,
          username: username,
          bio: _bioController.text.trim(),
          website: _normalizeOptionalText(_websiteController.text),
          location: _normalizeOptionalText(_locationController.text),
          avatarUrl: avatarUrl,
          coverImageUrl: coverImageUrl,
        ),
      );

      if (!mounted) {
        return;
      }

      final String warningText = warnings.isEmpty ? '' : ' ${warnings.join(' ')}';
      AppGet.snackbar('Edit Profile', '${result.message}$warningText');
      AppGet.back(result: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppGet.snackbar(
        'Edit Profile',
        'Unable to save profile right now. $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String> _uploadImage(String localPath, {required String folder}) async {
    final String taskId =
        'profile-${DateTime.now().microsecondsSinceEpoch}-${folder.hashCode}';
    UploadProgress? lastProgress;

    await for (final UploadProgress progress in _uploadService.uploadFile(
      taskId: taskId,
      localPath: localPath,
      fields: <String, String>{
        'resourceType': 'image',
        'folder': folder,
        'publicId': taskId,
      },
    )) {
      lastProgress = progress;
    }

    if (lastProgress == null ||
        lastProgress.status != UploadStatus.completed ||
        lastProgress.remotePath == null ||
        lastProgress.remotePath!.trim().isEmpty) {
      throw Exception(lastProgress?.error ?? 'Image upload failed.');
    }

    return lastProgress.remotePath!.trim();
  }

  String? _normalizeOptionalText(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
