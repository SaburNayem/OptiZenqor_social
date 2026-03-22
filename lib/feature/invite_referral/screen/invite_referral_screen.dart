import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/invite_referral_controller.dart';

class InviteReferralScreen extends StatelessWidget {
  const InviteReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InviteReferralController();

    return Scaffold(
      appBar: AppBar(title: const Text('Invite & Referral')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.model.benefit),
            const SizedBox(height: 12),
            SelectableText('Code: ${controller.model.inviteCode}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final shareText = controller.buildShareMessage();
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Invite message copied to clipboard'),
                          ),
                        );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share Invite Link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
