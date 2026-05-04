import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../app_route/route_names.dart';
import '../../widget/auth_google_button.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
}

bool _showsRemoteRecoveryActions(String? errorMessage) {
  final String normalized = errorMessage?.trim().toLowerCase() ?? '';
  return normalized.contains('demo password is 123456');
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
