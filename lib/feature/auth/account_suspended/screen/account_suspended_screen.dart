import 'package:flutter/material.dart';

import '../../../../app_route/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/models/user_model.dart';
import '../../../../core/navigation/app_get.dart';
import '../../repository/auth_repository.dart';

class AccountSuspendedScreen extends StatefulWidget {
  const AccountSuspendedScreen({super.key, this.user});

  final UserModel? user;

  @override
  State<AccountSuspendedScreen> createState() => _AccountSuspendedScreenState();
}

class _AccountSuspendedScreenState extends State<AccountSuspendedScreen> {
  final AuthRepository _authRepository = AuthRepository();
  late final Future<UserModel?> _userFuture;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.user == null
        ? _authRepository.currentUser()
        : Future.value(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: FutureBuilder<UserModel?>(
            future: _userFuture,
            builder: (context, snapshot) {
              final UserModel? user = snapshot.data ?? widget.user;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(
                          Icons.lock_clock_outlined,
                          size: 72,
                          color: AppColors.splashBackground,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Account suspended',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.black87,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _messageFor(user),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.grey700,
                                height: 1.45,
                              ),
                        ),
                        if (user?.id.trim().isNotEmpty == true) ...<Widget>[
                          const SizedBox(height: 20),
                          _InfoLine(label: 'Account ID', value: user!.id),
                        ],
                        if (user?.suspensionReason?.trim().isNotEmpty ==
                            true) ...<Widget>[
                          const SizedBox(height: 10),
                          _InfoLine(
                            label: 'Reason',
                            value: user!.suspensionReason!.trim(),
                          ),
                        ],
                        if (user?.suspendedUntil != null) ...<Widget>[
                          const SizedBox(height: 10),
                          _InfoLine(
                            label: 'Until',
                            value: _formatDate(user!.suspendedUntil!),
                          ),
                        ],
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _signingOut ? null : _signOut,
                          child: Text(
                            _signingOut ? 'Signing out...' : 'Sign out',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _messageFor(UserModel? user) {
    final DateTime? until = user?.suspendedUntil;
    if (until == null) {
      return 'Your account is suspended by admin review. You cannot use the app until an admin clears the suspension.';
    }
    return 'Your account is suspended by admin review until ${_formatDate(until)}. You cannot use the app before this suspension ends or an admin clears it.';
  }

  String _formatDate(DateTime value) {
    return value.toLocal().toString().split('.').first;
  }

  Future<void> _signOut() async {
    setState(() {
      _signingOut = true;
    });
    await _authRepository.logout();
    if (!mounted) {
      return;
    }
    AppGet.offAllNamed(RouteNames.login);
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hexFFE9EEF5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
