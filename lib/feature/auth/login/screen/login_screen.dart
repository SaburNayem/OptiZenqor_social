import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../app_route/route_names.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  final GlobalKey<FormState> _formKey = const GlobalObjectKey<FormState>(
    'login_form',
  );

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
                                  color: AppColors.black.withValues(alpha: 0.85),
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
                          OutlinedButton(
                            onPressed: () {
                              AppGet.snackbar(
                                'Google Login',
                                'Static Google login success',
                                snackPosition: SnackPosition.bottom,
                              );
                              AppGet.offNamed(RouteNames.shell);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: BorderSide(color: AppColors.grey200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                  height: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: AppColors.hexFF495057,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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



