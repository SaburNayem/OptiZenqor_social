import 'package:flutter/material.dart';

import '../controller/legal_compliance_controller.dart';

class LegalComplianceScreen extends StatelessWidget {
  LegalComplianceScreen({super.key});

  final LegalComplianceController _controller = LegalComplianceController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Legal & Compliance')),
          body: ListView(
            children: [
              CheckboxListTile(
                value: _controller.consent.termsAccepted,
                onChanged: (_) => _controller.toggleTerms(),
                title: const Text('Accept Terms and Conditions'),
              ),
              CheckboxListTile(
                value: _controller.consent.privacyAccepted,
                onChanged: (_) => _controller.togglePrivacy(),
                title: const Text('Accept Privacy Policy'),
              ),
              CheckboxListTile(
                value: _controller.consent.guidelinesAccepted,
                onChanged: (_) => _controller.toggleGuidelines(),
                title: const Text('Accept Community Guidelines'),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Age gate and consent screen placeholders are ready.'),
              ),
            ],
          ),
        );
      },
    );
  }
}
