import 'package:flutter/material.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/view_state.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../route/route_names.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                      validator: InputValidators.password,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
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
                    if (_controller.state == ViewState.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _controller.error ?? 'Authentication failed.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    AppButton(
                      label: _controller.state == ViewState.loading ? 'Signing In...' : 'Login',
                      onPressed: _controller.state == ViewState.loading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _controller.login(context);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(RouteNames.signup),
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
