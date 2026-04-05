import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../route/route_names.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 1;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF868E96)),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Get.back();
            }
          },
        ),
        title: Row(
          children: [
            Text(
              'Step $_currentStep of 3',
              style: const TextStyle(
                color: Color(0xFF868E96),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${((_currentStep / 3) * 100).toInt()} %',
              style: const TextStyle(
                color: Color(0xFF868E96),
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
                value: _currentStep / 3,
                backgroundColor: const Color(0xFFF2F4F7),
                valueColor: AlwaysStoppedAnimation<Color>(
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
          child: _buildCurrentStep(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: FilledButton(
          onPressed: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              Get.offAllNamed(RouteNames.shell);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.splashBackground,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _currentStep == 3 ? 'Finish Setup' : 'Continue',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Let\'s get you started on Connecta',
          style: TextStyle(fontSize: 16, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 40),
        _buildLabel('Full Name'),
        _buildTextField(hint: 'John Doe'),
        const SizedBox(height: 24),
        _buildLabel('Email Address'),
        _buildTextField(hint: 'hello@example.com'),
        const SizedBox(height: 24),
        _buildLabel('Password'),
        _buildTextField(
          hint: 'Create a password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF98A2B3),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('Confirm Password'),
        _buildTextField(
          hint: 'Repeat password',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF98A2B3),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Choose Your Role',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'How do you want to use Connecta?',
          style: TextStyle(fontSize: 16, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 32),
        _roleCard(
          'User',
          'Discover amazing content and connect with creators',
          Icons.person_outline,
        ),
        _roleCard(
          'Creator',
          'Share your work and grow your audience',
          Icons.auto_awesome_outlined,
        ),
        _roleCard(
          'Business',
          'Partner with creators and reach your audience',
          Icons.business_outlined,
        ),
      ],
    );
  }

  Widget _roleCard(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedRole == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.splashBackground : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected
                    ? AppColors.splashBackground
                    : const Color(0xFF475467),
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
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
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
                      : const Color(0xFFEAECF0),
                  width: 2,
                ),
                color: isSelected ? AppColors.splashBackground : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Set Up Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tell us a bit about yourself',
          style: TextStyle(fontSize: 16, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 36,
                  color: Color(0xFF98A2B3),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Upload Photo',
                    'Static profile photo picker opened',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Text(
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
        _buildLabel('Username'),
        _buildTextField(hint: 'johndoe'),
        const SizedBox(height: 24),
        _buildLabel('Bio'),
        TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write a short bio about yourself...',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterText: '0/150',
            counterStyle: const TextStyle(color: Color(0xFF98A2B3)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('Interests (Select up to 5)'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _interestChip('Art'),
            _interestChip('Music'),
            _interestChip('Tech'),
            _interestChip('Travel'),
            _interestChip('Food'),
            _interestChip('Fashion'),
            _interestChip('Sports'),
            _interestChip('Gaming'),
            _interestChip('Photography'),
            _interestChip('Design'),
            _interestChip('Writing'),
            _interestChip('Film'),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _interestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF344054),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD0D5DD), fontSize: 14),
        fillColor: const Color(0xFFF9FAFB),
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
