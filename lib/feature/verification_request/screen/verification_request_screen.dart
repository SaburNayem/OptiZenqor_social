import 'package:flutter/material.dart';

import '../controller/verification_request_controller.dart';
import '../model/verification_request_model.dart';

class VerificationRequestScreen extends StatelessWidget {
  VerificationRequestScreen({super.key}) {
    _controller.load();
  }

  final VerificationRequestController _controller =
      VerificationRequestController();

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
                      'Document upload placeholders',
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
                          : _controller.submit,
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
}
