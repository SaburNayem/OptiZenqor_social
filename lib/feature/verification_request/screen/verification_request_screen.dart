import 'package:flutter/material.dart';

import '../controller/verification_request_controller.dart';

class VerificationRequestScreen extends StatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  State<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState extends State<VerificationRequestScreen> {
  final VerificationRequestController _controller =
      VerificationRequestController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Verification Request')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text('Status: ${_controller.model.status.name}'),
                subtitle: Text(_controller.model.reason),
              ),
              const ListTile(
                title: Text('Identity/Business documents'),
                subtitle: Text('Upload placeholders for KYC and proof of business.'),
              ),
              FilledButton(
                onPressed: _controller.submit,
                child: const Text('Submit request'),
              ),
            ],
          ),
        );
      },
    );
  }
}
