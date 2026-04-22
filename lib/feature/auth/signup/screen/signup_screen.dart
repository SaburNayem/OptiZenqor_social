import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../app_route/route_names.dart';

part '../widget/signup_step_sections.dart';
part '../widget/signup_form_widgets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  final GlobalKey<FormState> _accountDetailsFormKey =
      const GlobalObjectKey<FormState>('signup_account_details_form');

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
                icon: const Icon(Icons.arrow_back, color: AppColors.hexFF868E96),
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
                child: _SignupStepContent(
                  state: state,
                  accountDetailsFormKey: _accountDetailsFormKey,
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () => _handleContinueTap(context, state, cubit),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.splashBackground,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  state.currentStep == 3 ? 'Create Account' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleContinueTap(
    BuildContext context,
    _SignupState state,
    _SignupCubit cubit,
  ) {
    if (state.currentStep == 1) {
      final bool isValid = _accountDetailsFormKey.currentState?.validate() ?? false;
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

    AppGet.toNamed(
      RouteNames.emailVerification,
      arguments: cubit.emailController.text.trim(),
    );
  }
}

class _SignupState {
  const _SignupState({
    this.currentStep = 1,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.selectedRole,
  });

  final int currentStep;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedRole;

  _SignupState copyWith({
    int? currentStep,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? selectedRole,
  }) {
    return _SignupState(
      currentStep: currentStep ?? this.currentStep,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

class _SignupCubit extends Cubit<_SignupState> {
  _SignupCubit() : super(const _SignupState());

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void nextStep() {
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void togglePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleConfirmPassword() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }

  void selectRole(String role) {
    emit(state.copyWith(selectedRole: role));
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
