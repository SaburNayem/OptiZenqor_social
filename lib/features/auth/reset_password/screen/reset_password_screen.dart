import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../route/route_names.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_ResetPasswordCubit>(
      create: (_) => _ResetPasswordCubit(),
      child: BlocBuilder<_ResetPasswordCubit, _ResetPasswordState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () => AppGet.back(),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9ECEF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9ECEF),
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
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1521),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a new password for your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF495057),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: state.obscureNewPassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => context
                            .read<_ResetPasswordCubit>()
                            .toggleNewPassword(),
                        icon: Icon(
                          state.obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
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
                      color: Color(0xFF495057),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: state.obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => context
                            .read<_ResetPasswordCubit>()
                            .toggleConfirmPassword(),
                        icon: Icon(
                          state.obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => AppGet.offAllNamed(RouteNames.login),
                    child: const Text('Reset Password'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResetPasswordState {
  const _ResetPasswordState({
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
  });

  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  _ResetPasswordState copyWith({
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
  }) {
    return _ResetPasswordState(
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }
}

class _ResetPasswordCubit extends Cubit<_ResetPasswordState> {
  _ResetPasswordCubit() : super(const _ResetPasswordState());

  void toggleNewPassword() {
    emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));
  }

  void toggleConfirmPassword() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }
}
