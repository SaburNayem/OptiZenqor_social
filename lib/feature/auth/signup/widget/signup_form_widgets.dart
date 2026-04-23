part of '../screen/signup_screen.dart';

class _SignupProfileStep extends StatelessWidget {
  const _SignupProfileStep({
    required this.state,
    required this.profileDetailsFormKey,
  });

  final _SignupState state;
  final GlobalKey<FormState> profileDetailsFormKey;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<_SignupCubit>();
    final String? profilePhotoPath = state.profilePhotoPath;
    final bool hasProfilePhoto =
        profilePhotoPath != null && profilePhotoPath.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Set Up Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.hexFF101828,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tell us a bit about yourself',
          style: TextStyle(fontSize: 16, color: AppColors.hexFF667085),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showProfilePhotoSourceSheet(context),
                child: Container(
                  height: 110,
                  width: 110,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.hexFFF9FAFB,
                    shape: BoxShape.circle,
                  ),
                  child: hasProfilePhoto
                      ? Image.file(File(profilePhotoPath), fit: BoxFit.cover)
                      : const Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: AppColors.hexFF98A2B3,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showProfilePhotoSourceSheet(context),
                child: Text(
                  hasProfilePhoto ? 'Change Photo' : 'Upload Photo',
                  style: TextStyle(
                    color: AppColors.splashBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (hasProfilePhoto)
                TextButton(
                  onPressed: cubit.clearProfilePhoto,
                  child: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: AppColors.hexFF667085,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: profileDetailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SignupFieldLabel('Username'),
              _SignupTextField(
                controller: cubit.usernameController,
                hint: 'johndoe',
                onChanged: (_) => cubit.clearError(),
                validator: (value) {
                  final String username = value?.trim() ?? '';
                  if (username.isEmpty) {
                    return 'Username is required';
                  }
                  if (username.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
                    return 'Use only letters, numbers, dots, or underscores';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const _SignupFieldLabel('Bio'),
              TextFormField(
                controller: cubit.bioController,
                maxLines: 4,
                maxLength: 150,
                onChanged: (_) => cubit.clearError(),
                decoration: InputDecoration(
                  hintText: 'Write a short bio about yourself...',
                  hintStyle: const TextStyle(
                    color: AppColors.hexFF98A2B3,
                    fontSize: 14,
                  ),
                  fillColor: AppColors.hexFFF9FAFB,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: const TextStyle(color: AppColors.hexFF98A2B3),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: _SignupFieldLabel('Interests (Select up to 5)'),
            ),
            Text(
              '${state.selectedInterests.length}/$_maxSignupInterests',
              style: const TextStyle(
                color: AppColors.hexFF667085,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSignupInterests
              .map((String interest) {
                return _SignupInterestChip(
                  label: interest,
                  selected: state.selectedInterests.contains(interest),
                  onTap: () => cubit.toggleInterest(interest),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _showProfilePhotoSourceSheet(BuildContext context) async {
    final cubit = context.read<_SignupCubit>();
    final String? action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(bottomSheetContext).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(bottomSheetContext).pop('camera'),
              ),
              if (state.profilePhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove Photo'),
                  onTap: () => Navigator.of(bottomSheetContext).pop('remove'),
                ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case 'gallery':
        await cubit.pickProfilePhotoFromGallery();
        return;
      case 'camera':
        await cubit.captureProfilePhoto();
        return;
      case 'remove':
        cubit.clearProfilePhoto();
        return;
    }
  }
}

class _SignupInterestChip extends StatelessWidget {
  const _SignupInterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.splashBackground.withValues(alpha: 0.12)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.splashBackground
                : AppColors.hexFFEAECF0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.splashBackground
                : AppColors.hexFF344054,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SignupFieldLabel extends StatelessWidget {
  const _SignupFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.hexFF344054,
        ),
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hexFFD0D5DD, fontSize: 14),
        fillColor: AppColors.hexFFF9FAFB,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _SignupLoginPrompt extends StatelessWidget {
  const _SignupLoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: AppColors.hexFF667085),
        ),
        GestureDetector(
          onTap: () => AppGet.offNamed(RouteNames.login),
          child: const Text(
            'Log In',
            style: TextStyle(
              color: AppColors.splashBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignupAlternativeDivider extends StatelessWidget {
  const _SignupAlternativeDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.grey400,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grey200)),
      ],
    );
  }
}
