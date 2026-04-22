import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/constants/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, this.email});

  final String? email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  static const int _codeLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(
      _codeLength,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  bool get _isCodeComplete => _code.length == _codeLength;

  void _handleDigitChanged(int index, String value) {
    final String digit = value.isEmpty ? '' : value.substring(value.length - 1);
    if (_controllers[index].text != digit) {
      _controllers[index].value = TextEditingValue(
        text: digit,
        selection: TextSelection.collapsed(offset: digit.length),
      );
    }

    if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (digit.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _confirmCode() {
    if (!_isCodeComplete) {
      AppGet.snackbar(
        'Enter Code',
        'Please enter the full 6-digit verification code.',
        snackPosition: SnackPosition.bottom,
      );
      return;
    }
    AppGet.offAllNamed(RouteNames.shell);
  }

  void _resendCode(String displayEmail) {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {});
    AppGet.snackbar(
      'Code Sent',
      'A new 6-digit code was sent to $displayEmail.',
      snackPosition: SnackPosition.bottom,
    );
  }

  Widget _buildCodeField({
    required int index,
    required double width,
    required double height,
    required double fontSize,
  }) {
    final BorderRadius borderRadius = BorderRadius.circular(
      width < 40 ? 12 : 14,
    );

    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: index == _codeLength - 1
            ? TextInputAction.done
            : TextInputAction.next,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.hexFF101828,
        ),
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(
              color: AppColors.hexFFEAECF0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: _controllers[index].text.isNotEmpty
                  ? AppColors.splashBackground
                  : AppColors.hexFFEAECF0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(
              color: AppColors.splashBackground,
              width: 1.6,
            ),
          ),
        ),
        onChanged: (value) => _handleDigitChanged(index, value),
        onSubmitted: (_) {
          if (index == _codeLength - 1) {
            _confirmCode();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayEmail = (widget.email?.trim().isNotEmpty ?? false)
        ? widget.email!.trim()
        : 'your email';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.hexFF868E96),
          onPressed: AppGet.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.hexFF101828,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to $displayEmail. Enter it below to confirm your account.',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.hexFF667085,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.hexFFF9FAFB,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hexFFEAECF0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hexFF344054,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double spacing = constraints.maxWidth < 280
                            ? 4
                            : 8;
                        final double fieldWidth =
                            (constraints.maxWidth -
                                    (spacing * (_codeLength - 1))) /
                                _codeLength;
                        final double fieldHeight = fieldWidth < 40 ? 54 : 58;
                        final double fontSize = fieldWidth < 38 ? 18 : 22;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            (_codeLength * 2) - 1,
                            (position) {
                              if (position.isOdd) {
                                return SizedBox(width: spacing);
                              }
                              final int index = position ~/ 2;
                              return _buildCodeField(
                                index: index,
                                width: fieldWidth,
                                height: fieldHeight,
                                fontSize: fontSize,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Did not get the code? You can resend it below.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.hexFF667085,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirmCode,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _resendCode(displayEmail),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(color: AppColors.hexFFEAECF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: AppColors.hexFF344054,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: AppGet.back,
                  child: const Text(
                    'Use a different email',
                    style: TextStyle(
                      color: AppColors.splashBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
