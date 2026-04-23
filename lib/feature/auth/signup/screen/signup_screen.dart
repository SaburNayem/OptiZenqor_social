import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/service/media_picker_service.dart';
import '../../../../core/data/service/upload_service.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/validators/input_validators.dart';
import '../../model/auth_exception.dart';
import '../../repository/auth_repository.dart';
import '../model/signup_model.dart';
import '../../widget/auth_google_button.dart';

part '../widget/signup_step_sections.dart';
part '../widget/signup_form_widgets.dart';

const List<String> _availableSignupInterests = <String>[
  'Art',
  'Music',
  'Tech',
  'Travel',
  'Food',
  'Fashion',
  'Sports',
  'Gaming',
  'Photography',
  'Design',
  'Writing',
  'Film',
];

const int _maxSignupInterests = 5;
const int _signupAvatarImageQuality = 75;
const double _signupAvatarMaxDimension = 1280;

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  final GlobalKey<FormState> _accountDetailsFormKey =
      const GlobalObjectKey<FormState>('signup_account_details_form');
  final GlobalKey<FormState> _profileDetailsFormKey =
      const GlobalObjectKey<FormState>('signup_profile_details_form');

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_SignupCubit>(
      create: (_) => _SignupCubit(),
      child: BlocBuilder<_SignupCubit, _SignupState>(
        builder: (context, state) {
          final cubit = context.read<_SignupCubit>();
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.hexFF868E96,
                ),
                onPressed: () {
                  if (state.currentStep > 1) {
                    cubit.previousStep();
                  } else {
                    AppGet.back();
                  }
                },
              ),
              title: Row(
                children: [
                  Text(
                    'Step ${state.currentStep} of 3',
                    style: const TextStyle(
                      color: AppColors.hexFF868E96,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((state.currentStep / 3) * 100).toInt()} %',
                    style: const TextStyle(
                      color: AppColors.hexFF868E96,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: state.currentStep / 3,
                      backgroundColor: AppColors.hexFFF2F4F7,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.splashBackground,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SignupStepContent(
                      state: state,
                      accountDetailsFormKey: _accountDetailsFormKey,
                      profileDetailsFormKey: _profileDetailsFormKey,
                    ),
                    if (state.errorMessage != null &&
                        state.errorMessage!.trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () async =>
                                _handleContinueTap(context, state, cubit),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.splashBackground,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        state.isSubmitting
                            ? 'Creating Account...'
                            : state.currentStep == 3
                            ? 'Create Account'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (state.currentStep == 1) ...[
                      const SizedBox(height: 12),
                      const _SignupLoginPrompt(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleContinueTap(
    BuildContext context,
    _SignupState state,
    _SignupCubit cubit,
  ) async {
    if (state.currentStep == 1) {
      final bool isValid =
          _accountDetailsFormKey.currentState?.validate() ?? false;
      if (isValid) {
        cubit.nextStep();
      }
      return;
    }

    if (state.currentStep == 2) {
      if (state.selectedRole == null) {
        AppGet.snackbar(
          'Choose a Role',
          'Please select how you want to use Connecta.',
          snackPosition: SnackPosition.bottom,
        );
        return;
      }
      cubit.nextStep();
      return;
    }

    final bool isValid =
        _profileDetailsFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final String? verificationEmail = await cubit.submitSignup();
    if (!context.mounted || verificationEmail == null) {
      return;
    }

    AppGet.toNamed(
      RouteNames.emailVerification,
      arguments: <String, String>{'email': verificationEmail},
    );
  }
}

class _SignupState {
  const _SignupState({
    this.currentStep = 1,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.selectedRole,
    this.profilePhotoPath,
    this.selectedInterests = const <String>[],
    this.isSubmitting = false,
    this.errorMessage,
  });

  final int currentStep;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final UserRole? selectedRole;
  final String? profilePhotoPath;
  final List<String> selectedInterests;
  final bool isSubmitting;
  final String? errorMessage;

  _SignupState copyWith({
    int? currentStep,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    UserRole? selectedRole,
    String? profilePhotoPath,
    List<String>? selectedInterests,
    bool? isSubmitting,
    String? errorMessage,
    bool clearProfilePhoto = false,
    bool clearErrorMessage = false,
  }) {
    return _SignupState(
      currentStep: currentStep ?? this.currentStep,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      selectedRole: selectedRole ?? this.selectedRole,
      profilePhotoPath: clearProfilePhoto
          ? null
          : profilePhotoPath ?? this.profilePhotoPath,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return '_SignupState('
        'currentStep: $currentStep, '
        'obscurePassword: $obscurePassword, '
        'obscureConfirmPassword: $obscureConfirmPassword, '
        'selectedRole: $selectedRole, '
        'profilePhotoPath: $profilePhotoPath, '
        'selectedInterests: $selectedInterests, '
        'isSubmitting: $isSubmitting, '
        'errorMessage: $errorMessage'
        ')';
  }
}

class _SignupCubit extends Cubit<_SignupState> {
  _SignupCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const _SignupState());

  final AuthRepository _authRepository;
  final MediaPickerService _mediaPickerService = MediaPickerService();
  final UploadService _uploadService = UploadService();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  void nextStep() {
    if (state.currentStep < 3) {
      emit(
        state.copyWith(
          currentStep: state.currentStep + 1,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(
        state.copyWith(
          currentStep: state.currentStep - 1,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void togglePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleConfirmPassword() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }

  void selectRole(UserRole role) {
    emit(state.copyWith(selectedRole: role, clearErrorMessage: true));
  }

  Future<void> pickProfilePhotoFromGallery() async {
    await _pickProfilePhoto(
      () => _mediaPickerService.pickImage(
        imageQuality: _signupAvatarImageQuality,
        maxWidth: _signupAvatarMaxDimension,
        maxHeight: _signupAvatarMaxDimension,
      ),
      fallbackMessage: 'Unable to access your gallery right now.',
    );
  }

  Future<void> captureProfilePhoto() async {
    await _pickProfilePhoto(
      () => _mediaPickerService.captureImage(
        imageQuality: _signupAvatarImageQuality,
        maxWidth: _signupAvatarMaxDimension,
        maxHeight: _signupAvatarMaxDimension,
      ),
      fallbackMessage: 'Unable to access your camera right now.',
    );
  }

  void clearProfilePhoto() {
    if (state.profilePhotoPath == null) {
      return;
    }
    emit(state.copyWith(clearProfilePhoto: true, clearErrorMessage: true));
  }

  void toggleInterest(String interest) {
    final List<String> updatedInterests = List<String>.from(
      state.selectedInterests,
    );
    if (updatedInterests.contains(interest)) {
      updatedInterests.remove(interest);
      emit(
        state.copyWith(
          selectedInterests: updatedInterests,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    if (updatedInterests.length >= _maxSignupInterests) {
      emit(
        state.copyWith(
          errorMessage: 'You can select up to $_maxSignupInterests interests.',
        ),
      );
      return;
    }

    updatedInterests.add(interest);
    emit(
      state.copyWith(
        selectedInterests: updatedInterests,
        clearErrorMessage: true,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<String?> submitSignup() async {
    final UserRole? selectedRole = state.selectedRole;
    if (selectedRole == null) {
      emit(
        state.copyWith(
          errorMessage: 'Please select how you want to use Connecta.',
        ),
      );
      return null;
    }

    final String name = fullNameController.text.trim();
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String? emailError = InputValidators.email(email);
    if (emailError != null) {
      emit(state.copyWith(errorMessage: emailError));
      return null;
    }

    final String? passwordError = InputValidators.password(password);
    if (passwordError != null) {
      emit(state.copyWith(errorMessage: passwordError));
      return null;
    }

    if (confirmPassword != password) {
      emit(state.copyWith(errorMessage: 'Passwords do not match.'));
      return null;
    }

    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Full name is required.'));
      return null;
    }

    if (username.isEmpty) {
      emit(state.copyWith(errorMessage: 'Username is required.'));
      return null;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    try {
      String? avatarRemotePath;
      final String? localProfilePhoto = state.profilePhotoPath;
      if (localProfilePhoto != null && localProfilePhoto.trim().isNotEmpty) {
        avatarRemotePath = await _uploadProfilePhoto(localProfilePhoto);
      }

      final SignupModel signup = SignupModel(
        name: name,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: selectedRole,
        avatarUrl: avatarRemotePath,
        bio: _normalizeOptionalText(bioController.text),
        interests: state.selectedInterests,
      );

      await _authRepository.signup(signup: signup);
      emit(state.copyWith(isSubmitting: false, clearErrorMessage: true));
      return signup.email;
    } on AuthException catch (error, stackTrace) {
      debugPrint('[Signup] Failed: ${error.message}');
      debugPrint('$stackTrace');
      emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
    } catch (error, stackTrace) {
      debugPrint('[Signup] Failed: $error');
      debugPrint('$stackTrace');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to create your account right now.',
        ),
      );
    }

    return null;
  }

  Future<void> _pickProfilePhoto(
    Future<String?> Function() picker, {
    required String fallbackMessage,
  }) async {
    try {
      final String? photoPath = await picker();
      if (photoPath == null || photoPath.trim().isEmpty) {
        return;
      }

      emit(
        state.copyWith(
          profilePhotoPath: photoPath.trim(),
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('[Signup] Profile photo selection failed: $error');
      debugPrint('$stackTrace');
      emit(state.copyWith(errorMessage: fallbackMessage));
    }
  }

  // Upload the local avatar first so the signup payload can send a remote path.
  Future<String> _uploadProfilePhoto(String localPath) async {
    final String taskId =
        'signup-avatar-${DateTime.now().microsecondsSinceEpoch}';
    UploadProgress? lastProgress;
    await for (final UploadProgress progress in _uploadService.uploadFile(
      taskId: taskId,
      localPath: localPath,
      fields: <String, String>{
        'resourceType': 'image',
        'folder': 'optizenqor/profile',
        'publicId': taskId,
      },
    )) {
      lastProgress = progress;
    }

    if (lastProgress == null ||
        lastProgress.status != UploadStatus.completed ||
        lastProgress.remotePath == null ||
        lastProgress.remotePath!.trim().isEmpty) {
      throw AuthException(_buildProfilePhotoUploadError(lastProgress?.error));
    }

    return lastProgress.remotePath!.trim();
  }

  String _buildProfilePhotoUploadError(String? error) {
    final String resolvedError = error?.trim().isNotEmpty == true
        ? error!.trim()
        : 'Unable to upload your profile photo right now.';
    final String normalizedError = resolvedError.toLowerCase();
    if (normalizedError.contains('timed out')) {
      return '$resolvedError Try a smaller photo or continue signup without a profile photo.';
    }
    return resolvedError;
  }

  String? _normalizeOptionalText(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    bioController.dispose();
    return super.close();
  }
}
