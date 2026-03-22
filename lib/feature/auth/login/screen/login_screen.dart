import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../route/route_names.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController _controller = LoginController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Login to continue your feed and communities.'),
                    const SizedBox(height: 28),
                    AppTextField(
                      hint: 'Email',
                      controller: _emailController,
                      validator: InputValidators.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hint: 'Password',
                      controller: _passwordController,
                      validator: InputValidators.loginPassword,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Static login: use any valid email and any non-empty password.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      initialValue: _controller.selectedRole,
                      decoration: const InputDecoration(labelText: 'Login as role'),
                      items: UserRole.values
                          .where((role) => role != UserRole.guest)
                          .map(
                            (role) => DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(role.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _controller.updateRole(value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_controller.formState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _controller.formState.errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    AppButton(
                      label: _controller.formState.isSubmitting ? 'Signing In...' : 'Login',
                      onPressed: _controller.formState.isSubmitting
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _controller.login();
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.toNamed(RouteNames.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.toNamed(RouteNames.signup),
                        child: const Text('Create a new account'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
