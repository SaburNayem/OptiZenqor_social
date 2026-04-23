part of '../screen/signup_screen.dart';

class _SignupStepContent extends StatelessWidget {
  const _SignupStepContent({
    required this.state,
    required this.accountDetailsFormKey,
    required this.profileDetailsFormKey,
  });

  final _SignupState state;
  final GlobalKey<FormState> accountDetailsFormKey;
  final GlobalKey<FormState> profileDetailsFormKey;

  @override
  Widget build(BuildContext context) {
    switch (state.currentStep) {
      case 1:
        return _SignupAccountStep(
          state: state,
          accountDetailsFormKey: accountDetailsFormKey,
        );
      case 2:
        return _SignupRoleStep(state: state);
      case 3:
        return _SignupProfileStep(
          state: state,
          profileDetailsFormKey: profileDetailsFormKey,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SignupAccountStep extends StatelessWidget {
  const _SignupAccountStep({
    required this.state,
    required this.accountDetailsFormKey,
  });

  final _SignupState state;
  final GlobalKey<FormState> accountDetailsFormKey;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<_SignupCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.hexFF101828,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Let\'s get you started on Connecta',
          style: TextStyle(fontSize: 16, color: AppColors.hexFF667085),
        ),
        const SizedBox(height: 32),
        Form(
          key: accountDetailsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SignupFieldLabel('Full Name'),
              _SignupTextField(
                controller: cubit.fullNameController,
                hint: 'John Doe',
                onChanged: (_) => cubit.clearError(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const _SignupFieldLabel('Email Address'),
              _SignupTextField(
                controller: cubit.emailController,
                hint: 'hello@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => cubit.clearError(),
                validator: (value) => InputValidators.email(value ?? ''),
              ),
              const SizedBox(height: 24),
              const _SignupFieldLabel('Password'),
              _SignupTextField(
                controller: cubit.passwordController,
                hint: 'Create a password',
                obscureText: state.obscurePassword,
                onChanged: (_) => cubit.clearError(),
                validator: (value) => InputValidators.password(value ?? ''),
                suffixIcon: IconButton(
                  onPressed: cubit.togglePassword,
                  icon: Icon(
                    state.obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.hexFF98A2B3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SignupFieldLabel('Confirm Password'),
              _SignupTextField(
                controller: cubit.confirmPasswordController,
                hint: 'Repeat password',
                obscureText: state.obscureConfirmPassword,
                onChanged: (_) => cubit.clearError(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != cubit.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: cubit.toggleConfirmPassword,
                  icon: Icon(
                    state.obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.hexFF98A2B3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _SignupAlternativeDivider(),
        const SizedBox(height: 24),
        AuthGoogleButton(
          label: 'Sign Up with Google',
          onPressed: () {
            AppGet.snackbar(
              'Google Sign Up',
              'Google sign-up is not configured yet.',
              snackPosition: SnackPosition.bottom,
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SignupRoleStep extends StatelessWidget {
  const _SignupRoleStep({required this.state});

  final _SignupState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Choose Your Role',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.hexFF101828,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'How do you want to use Connecta?',
          style: TextStyle(fontSize: 16, color: AppColors.hexFF667085),
        ),
        const SizedBox(height: 32),
        _SignupRoleCard(
          state: state,
          role: UserRole.user,
          title: 'User',
          subtitle: 'Discover amazing content and connect with creators',
          icon: Icons.person_outline,
        ),
        _SignupRoleCard(
          state: state,
          role: UserRole.creator,
          title: 'Creator',
          subtitle: 'Share your work and grow your audience',
          icon: Icons.auto_awesome_outlined,
        ),
        _SignupRoleCard(
          state: state,
          role: UserRole.business,
          title: 'Business',
          subtitle: 'Partner with creators and reach your audience',
          icon: Icons.business_outlined,
        ),
        _SignupRoleCard(
          state: state,
          role: UserRole.seller,
          title: 'Seller',
          subtitle: 'Showcase products and grow your customer community',
          icon: Icons.storefront_outlined,
        ),
        _SignupRoleCard(
          state: state,
          role: UserRole.recruiter,
          title: 'Recruiter',
          subtitle: 'Find talent, build teams, and manage hiring outreach',
          icon: Icons.badge_outlined,
        ),
      ],
    );
  }
}

class _SignupRoleCard extends StatelessWidget {
  const _SignupRoleCard({
    required this.state,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final _SignupState state;
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = state.selectedRole == role;

    return GestureDetector(
      onTap: () => context.read<_SignupCubit>().selectRole(role),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.splashBackground
                : AppColors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.hexFFF9FAFB,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected
                    ? AppColors.splashBackground
                    : AppColors.hexFF475467,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.hexFF101828,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.hexFF667085,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.splashBackground
                      : AppColors.hexFFEAECF0,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.splashBackground
                    : AppColors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
