import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../controller/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key, this.email, this.otp});

  final String? email;
  final String? otp;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final String resolvedEmail = email?.trim() ?? '';
    final String resolvedOtp = otp?.trim() ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<ResetPasswordController>(
          create: (_) =>
              ResetPasswordController(email: resolvedEmail, otp: resolvedOtp),
        ),
        BlocProvider<_ResetPasswordUiCubit>(
          create: (_) => _ResetPasswordUiCubit(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.grey),
            onPressed: AppGet.back,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.hexFFE9ECEF,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.hexFFE9ECEF,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.splashBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          actions: const [SizedBox(width: 48)],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              40,
              24,
              MediaQuery.of(context).viewInsets.bottom + 40,
            ),
            child: Form(
              key: _formKey,
              child: BlocBuilder<ResetPasswordController, FormStateModel>(
                builder: (context, formState) {
                  final controller = context.read<ResetPasswordController>();
                  return BlocBuilder<
                    _ResetPasswordUiCubit,
                    _ResetPasswordUiState
                  >(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.hexFF0D1521,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            resolvedEmail.isNotEmpty
                                ? 'Create a new password for $resolvedEmail.'
                                : 'Create a new password for your account.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hexFF495057,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            validator: (value) =>
                                InputValidators.password(value ?? ''),
                            obscureText: state.obscureNewPassword,
                            onChanged: controller.updateNewPassword,
                            decoration: InputDecoration(
                              hintText: '........',
                              suffixIcon: IconButton(
                                onPressed: () => context
                                    .read<_ResetPasswordUiCubit>()
                                    .toggleNewPassword(),
                                icon: Icon(
                                  state.obscureNewPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hexFF495057,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            validator: (value) {
                              final String confirmValue = value ?? '';
                              if (confirmValue.trim().isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (confirmValue != controller.newPassword) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: state.obscureConfirmPassword,
                            onChanged: controller.updateConfirmPassword,
                            decoration: InputDecoration(
                              hintText: '........',
                              suffixIcon: IconButton(
                                onPressed: () => context
                                    .read<_ResetPasswordUiCubit>()
                                    .toggleConfirmPassword(),
                                icon: Icon(
                                  state.obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ),
                          ),
                          if (formState.errorMessage != null &&
                              formState.errorMessage!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
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
                          ],
                          const SizedBox(height: 40),
                          FilledButton(
                            onPressed: formState.isSubmitting
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      controller.resetPassword();
                                    }
                                  },
                            child: Text(
                              formState.isSubmitting
                                  ? 'Resetting...'
                                  : 'Reset Password',
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

class _ResetPasswordUiState {
  const _ResetPasswordUiState({
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
  });

  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  _ResetPasswordUiState copyWith({
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
  }) {
    return _ResetPasswordUiState(
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }
}

class _ResetPasswordUiCubit extends Cubit<_ResetPasswordUiState> {
  _ResetPasswordUiCubit() : super(const _ResetPasswordUiState());

  void toggleNewPassword() {
    emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));
  }

  void toggleConfirmPassword() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }
}
