import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/data/service/media_picker_service.dart';
import '../../../../core/data/service/upload_service.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../app_route/route_names.dart';
import '../../../support_help/model/support_help_data_model.dart';
import '../../../support_help/repository/support_help_repository.dart';
import '../../widget/auth_google_button.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SupportHelpRepository _supportHelpRepository = SupportHelpRepository();
  final MediaPickerService _mediaPickerService = MediaPickerService();
  final UploadService _uploadService = UploadService();

  LoginHelpConfigModel _loginHelpConfig = LoginHelpConfigModel.defaults;
  bool _isSendingLoginHelp = false;

  @override
  void initState() {
    super.initState();
    _loadLoginHelpConfig();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginController>(create: (_) => LoginController()),
        BlocProvider<_LoginUiCubit>(create: (_) => _LoginUiCubit()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: BlocBuilder<LoginController, FormStateModel>(
                builder: (context, formState) {
                  final controller = context.read<LoginController>();
                  return BlocBuilder<_LoginUiCubit, _LoginUiState>(
                    builder: (context, uiState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('👋', style: TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Log in to your account to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey500,
                            ),
                          ),
                          if (_loginHelpConfig.enabled && _loginHelpConfig.showOnLogin) ...[
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showLoginHelpSheet(
                                  prefilledEmail: controller.email.trim(),
                                ),
                                icon: const Icon(Icons.help_outline),
                                label: Text(_loginHelpConfig.headerText),
                              ),
                            ),
                          ],
                          const SizedBox(height: 48),
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hexFF495057,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            validator: (v) => InputValidators.email(v ?? ''),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: controller.updateEmail,
                            decoration: const InputDecoration(
                              hintText: 'hello@example.com',
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hexFF495057,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            validator: (v) =>
                                InputValidators.loginPassword(v ?? ''),
                            obscureText: uiState.obscurePassword,
                            onChanged: controller.updatePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                onPressed: () => context
                                    .read<_LoginUiCubit>()
                                    .togglePassword(),
                                icon: Icon(
                                  uiState.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  AppGet.toNamed(RouteNames.forgotPassword),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.splashBackground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (formState.errorMessage != null &&
                              formState.errorMessage!.trim().isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Text(
                                formState.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_showsRemoteRecoveryActions(
                              formState.errorMessage,
                            )) ...[
                              const SizedBox(height: 12),
                              _RemoteAccountRecoveryCard(
                                email: controller.email.trim(),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ] else
                            const SizedBox(height: 24),
                          FilledButton(
                            onPressed: formState.isSubmitting
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      controller.login();
                                    }
                                  },
                            child: Text(
                              formState.isSubmitting
                                  ? 'Logging In...'
                                  : 'Log In',
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.grey200),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: AppColors.grey400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.grey200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          AuthGoogleButton(
                            label: 'Continue with Google',
                            onPressed: () {
                              AppGet.snackbar(
                                'Google Login',
                                'Google login is not connected yet.',
                                snackPosition: SnackPosition.bottom,
                              );
                            },
                          ),
                          const SizedBox(height: 48),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: AppColors.grey600),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      AppGet.toNamed(RouteNames.signup),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.splashBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadLoginHelpConfig() async {
    try {
      final data = await _supportHelpRepository.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _loginHelpConfig = data.loginHelpConfig;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loginHelpConfig = LoginHelpConfigModel.defaults;
      });
    }
  }

  Future<void> _showLoginHelpSheet({String prefilledEmail = ''}) async {
    final TextEditingController emailController = TextEditingController(
      text: prefilledEmail,
    );
    final TextEditingController nameController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String? selectedImagePath;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final EdgeInsets insets = MediaQuery.of(context).viewInsets;
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, insets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(width: 42, child: Divider(thickness: 4)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loginHelpConfig.headerText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loginHelpConfig.bodyText,
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email for reply',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Tell us what happened',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_loginHelpConfig.allowImages) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isSendingLoginHelp
                            ? null
                            : () async {
                                final String? imagePath =
                                    await _mediaPickerService.pickImage(
                                  imageQuality: 85,
                                  maxWidth: 1600,
                                  maxHeight: 1600,
                                );
                                if (imagePath == null || imagePath.isEmpty) {
                                  return;
                                }
                                setSheetState(() {
                                  selectedImagePath = imagePath;
                                });
                              },
                        icon: const Icon(Icons.image_outlined),
                        label: Text(
                          selectedImagePath == null
                              ? 'Attach image'
                              : 'Change image',
                        ),
                      ),
                      if (selectedImagePath != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(selectedImagePath!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSendingLoginHelp
                            ? null
                            : () async {
                                final String message =
                                    messageController.text.trim();
                                final String email = emailController.text.trim();
                                if (message.isEmpty || email.isEmpty) {
                                  AppGet.snackbar(
                                    'Missing details',
                                    'Add your email and message before sending.',
                                  );
                                  return;
                                }
                                setSheetState(() {
                                  _isSendingLoginHelp = true;
                                });
                                setState(() {
                                  _isSendingLoginHelp = true;
                                });
                                try {
                                  final List<String> attachments =
                                      selectedImagePath == null
                                          ? const <String>[]
                                          : <String>[
                                              await _uploadLoginHelpImage(
                                                selectedImagePath!,
                                              ),
                                            ];
                                  await _supportHelpRepository.createTicket(
                                    subject: 'Login help request',
                                    category: 'Account',
                                    message: message,
                                    priority: 'high',
                                    attachments: attachments,
                                    contactEmail: email,
                                    contactName: nameController.text.trim(),
                                    source: 'login_help',
                                  );
                                  if (!mounted || !context.mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                  AppGet.snackbar(
                                    'Support',
                                    'Your message was sent to admin support.',
                                  );
                                } catch (error) {
                                  AppGet.snackbar(
                                    'Support',
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSendingLoginHelp = false;
                                    });
                                  }

                                }
                              },
                        icon: _isSendingLoginHelp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          _isSendingLoginHelp ? 'Sending...' : 'Send to admin',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    emailController.dispose();
    nameController.dispose();
    messageController.dispose();
  }

  Future<String> _uploadLoginHelpImage(String imagePath) async {
    UploadProgress? lastProgress;
    await for (final UploadProgress progress in _uploadService.uploadFile(
      taskId: 'login-help-${DateTime.now().microsecondsSinceEpoch}',
      localPath: imagePath,
      fields: const <String, String>{
        'folder': 'support',
        'resourceType': 'image',
      },
    )) {
      lastProgress = progress;
      if (progress.status == UploadStatus.completed &&
          progress.remotePath != null &&
          progress.remotePath!.trim().isNotEmpty) {
        return progress.remotePath!.trim();
      }
    }
    throw Exception(lastProgress?.error ?? 'Unable to upload support image.');
  }
}

bool _showsRemoteRecoveryActions(String? errorMessage) {
  final String normalized = errorMessage?.trim().toLowerCase() ?? '';
  return normalized.contains('account not found') ||
      normalized.contains('invalid credentials');
}

class _RemoteAccountRecoveryCard extends StatelessWidget {
  const _RemoteAccountRecoveryCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.splashBackground.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.splashBackground.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Vercel account data looks different from your previous backend data.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.hexFF495057,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Reset the password for this deployed backend or create the account again there.',
            style: TextStyle(fontSize: 13, color: AppColors.hexFF495057),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => AppGet.toNamed(
                  RouteNames.forgotPassword,
                  arguments: <String, String>{
                    if (email.isNotEmpty) 'email': email,
                  },
                ),
                child: const Text('Reset On Vercel'),
              ),
              TextButton(
                onPressed: () => AppGet.toNamed(RouteNames.signup),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginUiState {
  const _LoginUiState({this.obscurePassword = true});

  final bool obscurePassword;

  _LoginUiState copyWith({bool? obscurePassword}) {
    return _LoginUiState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class _LoginUiCubit extends Cubit<_LoginUiState> {
  _LoginUiCubit() : super(const _LoginUiState());

  void togglePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
}
