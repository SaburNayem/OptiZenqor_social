part of '../screen/signup_screen.dart';

class _SignupProfileStep extends StatelessWidget {
  const _SignupProfileStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Set Up Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.hexFF101828,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tell us a bit about yourself',
          style: TextStyle(fontSize: 16, color: AppColors.hexFF667085),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(
                  color: AppColors.hexFFF9FAFB,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 36,
                  color: AppColors.hexFF98A2B3,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  AppGet.snackbar(
                    'Upload Photo',
                    'Static profile photo picker opened',
                    snackPosition: SnackPosition.bottom,
                  );
                },
                child: const Text(
                  'Upload Photo',
                  style: TextStyle(
                    color: AppColors.splashBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SignupFieldLabel('Username'),
        const _SignupTextField(hint: 'johndoe'),
        const SizedBox(height: 24),
        const _SignupFieldLabel('Bio'),
        TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write a short bio about yourself...',
            hintStyle: const TextStyle(color: AppColors.hexFF98A2B3, fontSize: 14),
            fillColor: AppColors.hexFFF9FAFB,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterText: '0/150',
            counterStyle: const TextStyle(color: AppColors.hexFF98A2B3),
          ),
        ),
        const SizedBox(height: 24),
        const _SignupFieldLabel('Interests (Select up to 5)'),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SignupInterestChip('Art'),
            _SignupInterestChip('Music'),
            _SignupInterestChip('Tech'),
            _SignupInterestChip('Travel'),
            _SignupInterestChip('Food'),
            _SignupInterestChip('Fashion'),
            _SignupInterestChip('Sports'),
            _SignupInterestChip('Gaming'),
            _SignupInterestChip('Photography'),
            _SignupInterestChip('Design'),
            _SignupInterestChip('Writing'),
            _SignupInterestChip('Film'),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SignupInterestChip extends StatelessWidget {
  const _SignupInterestChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hexFFEAECF0),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.hexFF344054,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SignupFieldLabel extends StatelessWidget {
  const _SignupFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.hexFF344054,
        ),
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hexFFD0D5DD, fontSize: 14),
        fillColor: AppColors.hexFFF9FAFB,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
