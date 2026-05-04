import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/form_state_model.dart';
import '../../../../core/validators/input_validators.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key, this.email});

  final String? email;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordController>(
      create: (_) => ForgotPasswordController(initialEmail: email),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.grey),
            onPressed: AppGet.back,
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.splashBackground,
                  borderRadius: BorderRadius.circular(2),
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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.hexFFE9ECEF,
                  shape: BoxShape.circle,
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
              child: BlocBuilder<ForgotPasswordController, FormStateModel>(
                builder: (context, formState) {
                  final controller = context.read<ForgotPasswordController>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.hexFF0D1521,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter your email and we will send you a 6-digit reset code.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                        initialValue: email?.trim(),
                        validator: (value) =>
                            InputValidators.email(value ?? ''),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onChanged: controller.updateEmail,
                        onFieldSubmitted: (_) {
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.sendResetCode();
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'hello@example.com',
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
                                  controller.sendResetCode();
                                }
                              },
                        child: Text(
                          formState.isSubmitting
                              ? 'Sending...'
                              : 'Send Reset Code',
                        ),
                      ),
                    ],
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
