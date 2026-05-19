part of 'support_help_screen.dart';

extension _SupportHelpTicketDetail on _SupportHelpScreenState {
  Widget _buildDetailErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.mark_email_read_outlined,
            size: 36,
            color: AppColors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            _controller.actionMessage ?? 'Unable to load ticket details.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final String ticketId = _controller.selectedTicketId ?? '';
              if (ticketId.isNotEmpty) {
                _controller.openTicket(ticketId);
              }
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailContent({
    required SupportTicketDetailModel detail,
    required TextEditingController replyController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Center(child: SizedBox(width: 42, child: Divider(thickness: 4))),
        const SizedBox(height: 12),
        Text(
          detail.summary.subject,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _buildStatusChip(detail.summary.status),
            _buildMetaChip(detail.summary.priority.toUpperCase()),
            _buildMetaChip(detail.summary.category),
            if (detail.channel.isNotEmpty) _buildMetaChip(detail.channel),
          ],
        ),
        const SizedBox(height: 12),
        if (detail.userLabel.isNotEmpty ||
            detail.slaDueAt.isNotEmpty ||
            detail.adminNotes.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.hexFFF5F5F5,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (detail.userLabel.isNotEmpty)
                  Text('Requester: ${detail.userLabel}'),
                if (detail.slaDueAt.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text('SLA due: ${detail.slaDueAt}'),
                ],
                if (detail.adminNotes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    'Internal notes: ${detail.adminNotes.join(' | ')}',
                    style: const TextStyle(color: AppColors.grey),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _SupportHelpScreenState._ticketStatuses
                .map((String status) {
                  final bool active =
                      detail.summary.status.trim().toLowerCase() ==
                      status.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: active,
                      onSelected: _controller.isSubmitting
                          ? null
                          : (_) async {
                              final bool updated = await _controller
                                  .updateSelectedTicket(status: status);
                              if (updated) {
                                _flushActionMessage('Support');
                              } else {
                                _flushActionMessage('Support');
                              }
                            },
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Conversation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: detail.messages.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.hexFFF5F5F5,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No replies yet. Send a message below to continue the ticket.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: detail.messages.length,
                  separatorBuilder: (BuildContext _, int index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final SupportTicketMessageModel message =
                        detail.messages[index];
                    return Align(
                      alignment: message.isFromSupport
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: message.isFromSupport
                              ? AppColors.hexFFF5F5F5
                              : AppColors.hexFFE0F2F1,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              message.senderLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(message.body),
                            if (message.attachments.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: message.attachments
                                    .map(_buildAttachmentPreview)
                                    .toList(growable: false),
                              ),
                            ],
                            if (message.createdAt.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              Text(
                                message.createdAt,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: replyController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a reply to support',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        if (_controller.actionMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _controller.actionMessage!,
              style: TextStyle(
                color:
                    _controller.actionMessage!.toLowerCase().contains('success')
                    ? AppColors.primary
                    : AppColors.red,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _controller.isSubmitting
                ? null
                : () async {
                    final String reply = replyController.text.trim();
                    if (reply.isEmpty) {
                      AppGet.snackbar(
                        'Reply required',
                        'Write a message before sending your reply.',
                      );
                      return;
                    }
                    final bool sent = await _controller.sendReply(reply);
                    if (sent) {
                      replyController.clear();
                    }
                    _flushActionMessage('Support');
                  },
            icon: _controller.isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_controller.isSubmitting ? 'Sending...' : 'Send Reply'),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickSupportImage() {
    return _mediaPickerService.pickImage(
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }

  Future<List<String>> _uploadSupportAttachments(
    List<String> imagePaths,
  ) async {
    final List<String> uploaded = <String>[];
    for (final String imagePath in imagePaths) {
      if (_isRemoteAttachment(imagePath)) {
        uploaded.add(imagePath);
        continue;
      }
      UploadProgress? lastProgress;
      await for (final UploadProgress progress in _uploadService.uploadFile(
        taskId:
            'support-${DateTime.now().microsecondsSinceEpoch}-${uploaded.length}',
        localPath: imagePath,
        fields: const <String, String>{
          'folder': 'support',
          'resourceType': 'image',
        },
      )) {
        lastProgress = progress;
        if (progress.status == UploadStatus.completed &&
            progress.remotePath != null &&
            progress.remotePath!.trim().isNotEmpty) {
          uploaded.add(progress.remotePath!.trim());
          break;
        }
      }
      if (lastProgress?.status != UploadStatus.completed) {
        throw Exception(lastProgress?.error ?? 'Support image upload failed.');
      }
    }
    return uploaded;
  }

  bool _isRemoteAttachment(String value) {
    final Uri? uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _attachmentLabel(String value) {
    final String normalized = value.replaceAll('\\', '/');
    final int index = normalized.lastIndexOf('/');
    return index == -1 ? normalized : normalized.substring(index + 1);
  }

  bool _isImageAttachment(String value) {
    final String lower = value.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.contains('image/upload');
  }

  Widget _buildAttachmentPreview(String attachment) {
    final String resolved = MediaUrlResolver.resolve(attachment);
    if (_isImageAttachment(resolved)) {
      final Widget image = _isRemoteAttachment(resolved)
          ? Image.network(resolved, fit: BoxFit.cover)
          : Image.file(File(resolved), fit: BoxFit.cover);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 96, height: 96, child: image),
      );
    }
    return Chip(label: Text(_attachmentLabel(attachment)));
  }

  Widget _buildStatusChip(String status) {
    final String normalized = status.trim().toLowerCase();
    final Color color = switch (normalized) {
      'resolved' => AppColors.primary,
      'closed' => AppColors.grey,
      'reviewing' => AppColors.hexFFFFC107,
      _ => AppColors.hexFF42A5F5,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hexFFF5F5F5,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.grey),
      ),
    );
  }

  void _flushActionMessage(String title) {
    final String? message = _controller.actionMessage;
    if (message == null || message.isEmpty) {
      return;
    }
    AppGet.snackbar(title, message);
    _controller.consumeActionMessage();
  }
}
