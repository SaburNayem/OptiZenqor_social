import 'package:flutter/material.dart';

import '../../../app_route/route_names.dart';
import '../../../core/data/models/user_model.dart';
import '../controller/verification_request_controller.dart';
import '../model/verification_request_model.dart';
import 'verification_submission_complete_screen.dart';

class VerificationRequestScreen extends StatefulWidget {
  const VerificationRequestScreen({
    super.key,
    this.returnRouteName = RouteNames.settings,
    this.completionTargetLabel = 'Settings',
    this.requestedForUser,
  });

  final String returnRouteName;
  final String completionTargetLabel;
  final UserModel? requestedForUser;

  @override
  State<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState extends State<VerificationRequestScreen> {
  final VerificationRequestController _controller =
      VerificationRequestController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Verification Request')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.requestedForUser != null) ...[
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              widget.requestedForUser!.avatar,
                            ),
                          ),
                          title: Text(widget.requestedForUser!.name),
                          subtitle: Text(
                            '@${widget.requestedForUser!.username} needs ID verification before creating marketplace listings.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: ListTile(
                        title: Text('Status: ${_controller.model.status.name}'),
                        subtitle: Text(_controller.model.reason),
                        trailing: Chip(
                          label: Text(
                            _controller.model.status.name.toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                    if (_controller.model.submittedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Submitted: ${_controller.model.submittedAt}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload the required ID documents',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._controller.requiredDocuments.map(
                      (document) => CheckboxListTile(
                        value: _controller.model.selectedDocuments.contains(
                          document,
                        ),
                        title: Text(document),
                        subtitle: const Text(
                          'Placeholder for backend upload integration',
                        ),
                        onChanged: (_) => _controller.toggleDocument(document),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _controller.model.selectedDocuments.isEmpty
                          ? null
                          : _submitRequest,
                      child: const Text('Submit request'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: VerificationStatus.values.map((status) {
                        return OutlinedButton(
                          onPressed: () => _controller.updateStatus(status),
                          child: Text('Mark ${status.name}'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _submitRequest() async {
    await _controller.submit();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VerificationSubmissionCompleteScreen(
          returnRouteName: widget.returnRouteName,
          targetLabel: widget.completionTargetLabel,
        ),
      ),
    );
  }
}
