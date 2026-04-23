import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/auth_exception.dart';
import '../../repository/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final AuthRepository _authRepository = AuthRepository();

  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      _codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_codeLength, (_) => FocusNode());
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

  String get _trimmedEmail => widget.email?.trim() ?? '';

  bool get _hasEmail => _trimmedEmail.isNotEmpty;

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

    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _continueToReset() {
    if (!_hasEmail) {
      setState(() {
        _errorMessage =
            'Email address is missing. Please go back and request a new reset code.';
      });
      return;
    }

    if (!_isCodeComplete) {
      setState(() {
        _errorMessage = 'Please enter the full 6-digit reset code.';
      });
      return;
    }

    AppGet.toNamed(
      RouteNames.resetPassword,
      arguments: <String, String>{'email': _trimmedEmail, 'otp': _code},
    );
  }

  Future<void> _resendCode(String displayEmail) async {
    if (_isResending) {
      return;
    }

    if (!_hasEmail) {
      setState(() {
        _errorMessage =
            'Email address is missing. Please go back and request a new reset code.';
      });
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final String message = await _authRepository.forgotPassword(
        email: _trimmedEmail,
      );
      if (!mounted) {
        return;
      }

      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes.first.requestFocus();
      setState(() {
        _isResending = false;
      });
      AppGet.snackbar(
        'Code Sent',
        message.isNotEmpty
            ? message
            : 'A new reset code was sent to $displayEmail.',
      );
    } on AuthException catch (error, stackTrace) {
      debugPrint('[ForgotPasswordOtp] Resend failed: ${error.message}');
      debugPrint('$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isResending = false;
        _errorMessage = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint('[ForgotPasswordOtp] Resend failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isResending = false;
        _errorMessage = 'Unable to resend the reset code right now.';
      });
    }
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
        enabled: !_isResending,
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: AppColors.hexFFEAECF0),
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
            _continueToReset();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayEmail = _hasEmail ? _trimmedEmail : 'your email';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.hexFF868E96),
          onPressed: AppGet.back,
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.hexFFE9ECEF,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.splashBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.hexFFE9ECEF,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            48,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Reset Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.hexFF101828,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to $displayEmail. Enter it below to continue.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.hexFF667085,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
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
                      'Reset code',
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
                      'This code is required on the next step when you set your new password.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.hexFF667085,
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null &&
                  _errorMessage!.trim().isNotEmpty) ...[
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
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continueToReset,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.splashBackground,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
                  child: Text(
                    _isResending ? 'Sending...' : 'Resend Code',
                    style: const TextStyle(
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
