import 'dart:io';

import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/service/media_picker_service.dart';
import '../../../core/data/service/upload_service.dart';
import '../../../core/helpers/media_url_resolver.dart';
import '../../../core/widgets/error_state_view.dart';
import '../controller/support_help_controller.dart';
import '../model/faq_item_model.dart';
import '../model/support_ticket_detail_model.dart';
import '../model/support_ticket_message_model.dart';
import '../model/support_ticket_summary_model.dart';

part 'support_help_ticket_detail.dart';

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({super.key});

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen> {
  static const List<String> _ticketCategories = <String>[
    'Account',
    'Payments',
    'Safety',
    'Content',
    'Technical',
    'Other',
  ];
  static const List<String> _ticketPriorities = <String>[
    'low',
    'normal',
    'high',
    'urgent',
  ];
  static const List<String> _ticketStatuses = <String>[
    'open',
    'reviewing',
    'resolved',
    'closed',
  ];

  late final SupportHelpController _controller;
  final MediaPickerService _mediaPickerService = MediaPickerService();
  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();
    _controller = SupportHelpController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFFBFBFB,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black54),
            onPressed: () {
              AppGet.snackbar(
                'Search',
                'Use the FAQ list below to browse support topics.',
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.black54,
                ),
                onPressed: () {
                  AppGet.toNamed(RouteNames.notifications);
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 8),
            child: CircleAvatar(
              radius: 16,
              child: Icon(Icons.support_agent_outlined),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null) {
            return ErrorStateView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
              onRefresh: _controller.load,
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.hexFFF5F5F5,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Support content, tickets, and replies are synced from the backend.',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How can we help?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Your Tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showCreateTicketSheet,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('New Ticket'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_controller.tickets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'No synced support tickets are available for this account yet.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _showCreateTicketSheet,
                          child: const Text('Create your first ticket'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: Column(children: _buildTicketTiles()),
                  ),
                const SizedBox(height: 32),
                const Text(
                  'Popular Articles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_controller.faqs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: const Text(
                      'No support articles have been published yet.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hexFFF0F0F0),
                    ),
                    child: Column(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < _controller.faqs.length;
                          index++
                        ) ...<Widget>[
                          _buildArticleTile(_controller.faqs[index]),
                          if (index < _controller.faqs.length - 1)
                            const Divider(
                              height: 1,
                              color: AppColors.hexFFF0F0F0,
                            ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                _buildSupportActionsCard(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        currentIndex: 0,
        onTap: _handleBottomNavTap,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: AppColors.primary),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hexFFF0F0F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${_controller.faqs.length} published support articles',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.ticketCount > 0
                ? 'You have ${_controller.ticketCount} support ticket(s) on file.'
                : 'No support tickets found for this account yet.',
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _buildBadge(
                label: _controller.hasChatThread
                    ? 'Ticket chat available'
                    : 'No ticket chat yet',
              ),
              _buildBadge(
                label: _controller.responseTime.isNotEmpty
                    ? _controller.responseTime
                    : 'Response time unavailable',
              ),
              if (_controller.contactEmail.isNotEmpty)
                _buildBadge(label: _controller.contactEmail),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTicketTiles() {
    final int visibleCount = _controller.tickets.length < 4
        ? _controller.tickets.length
        : 4;
    final List<Widget> widgets = <Widget>[];
    for (int index = 0; index < visibleCount; index++) {
      final SupportTicketSummaryModel ticket = _controller.tickets[index];
      widgets.add(
        ListTile(
          onTap: () => _showTicketDetailSheet(ticket.id),
          title: Text(ticket.subject),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  ticket.latestMessage.isNotEmpty
                      ? ticket.latestMessage
                      : ticket.category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _buildStatusChip(ticket.status),
                    _buildMetaChip(ticket.priority.toUpperCase()),
                    _buildMetaChip(ticket.category),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.grey,
          ),
        ),
      );
      if (index < visibleCount - 1) {
        widgets.add(const Divider(height: 1, color: AppColors.hexFFF0F0F0));
      }
    }
    if (_controller.tickets.length > visibleCount) {
      widgets.add(const Divider(height: 1, color: AppColors.hexFFF0F0F0));
      widgets.add(
        ListTile(
          onTap: () => _showTicketDetailSheet(_controller.tickets.first.id),
          title: Text(
            'Showing $visibleCount of ${_controller.tickets.length} tickets',
          ),
          subtitle: const Text('Open any ticket to continue the conversation.'),
          trailing: const Icon(Icons.forum_outlined),
        ),
      );
    }
    return widgets;
  }

  Widget _buildSupportActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hexFFF0F0F0),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.hexFFE0F2F1,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Need more help?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Open a backend-backed ticket and continue the conversation in-app.',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _showCreateTicketSheet,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Create Support Ticket',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                if (_controller.tickets.isNotEmpty) {
                  _showTicketDetailSheet(_controller.tickets.first.id);
                  return;
                }
                final String email = _controller.contactEmail.isNotEmpty
                    ? _controller.contactEmail
                    : _controller.escalationEmail;
                AppGet.snackbar(
                  'Email Support',
                  email.isEmpty ? 'No support email configured.' : email,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.hexFFE0F2F1),
                backgroundColor: AppColors.hexFFF4FDFA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                _controller.tickets.isNotEmpty
                    ? 'Open Latest Ticket'
                    : 'Email Support',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _controller.responseTime.isEmpty
                ? 'Average response time unavailable'
                : 'Average response time: ${_controller.responseTime}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hexFFF5F5F5,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildArticleTile(FaqItemModel item) {
    return ListTile(
      onTap: () {
        AppGet.snackbar(item.question, item.answer);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.hexFFF5F5F5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.article_outlined,
          color: AppColors.grey,
          size: 20,
        ),
      ),
      title: Text(
        item.question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          item.answer,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.grey,
      ),
    );
  }

  Future<void> _showCreateTicketSheet() async {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedCategory = _ticketCategories.first;
    String selectedPriority = 'normal';
    final List<String> selectedImages = <String>[];
    bool isUploadingImages = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Center(
                          child: SizedBox(
                            width: 42,
                            child: Divider(thickness: 4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create Support Ticket',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share the issue once and keep the conversation synced here.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: subjectController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: _ticketCategories
                              .map(
                                (String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setSheetState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: _ticketPriorities
                              .map(
                                (String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item.toUpperCase()),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setSheetState(() {
                              selectedPriority = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: messageController,
                          minLines: 4,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Describe the issue',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: isUploadingImages
                                  ? null
                                  : () async {
                                      final String? imagePath =
                                          await _pickSupportImage();
                                      if (imagePath == null ||
                                          imagePath.isEmpty) {
                                        return;
                                      }
                                      setSheetState(() {
                                        selectedImages.add(imagePath);
                                      });
                                    },
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Add image'),
                            ),
                            const SizedBox(width: 10),
                            if (selectedImages.isNotEmpty)
                              Expanded(
                                child: Text(
                                  '${selectedImages.length} image attached',
                                  style: const TextStyle(color: AppColors.grey),
                                ),
                              ),
                          ],
                        ),
                        if (selectedImages.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedImages
                                .map(
                                  (String imagePath) => InputChip(
                                    label: Text(_attachmentLabel(imagePath)),
                                    onDeleted: isUploadingImages
                                        ? null
                                        : () {
                                            setSheetState(() {
                                              selectedImages.remove(imagePath);
                                            });
                                          },
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (_controller.actionMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _controller.actionMessage!,
                              style: TextStyle(
                                color:
                                    _controller.actionMessage!
                                        .toLowerCase()
                                        .contains('success')
                                    ? AppColors.primary
                                    : AppColors.red,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _controller.isSubmitting
                                ? null
                                : () async {
                                    final String subject = subjectController
                                        .text
                                        .trim();
                                    final String message = messageController
                                        .text
                                        .trim();
                                    if (subject.isEmpty || message.isEmpty) {
                                      AppGet.snackbar(
                                        'Missing details',
                                        'Add both a subject and a message before sending.',
                                      );
                                      return;
                                    }
                                    final NavigatorState navigator =
                                        Navigator.of(context);
                                    setSheetState(() {
                                      isUploadingImages =
                                          selectedImages.isNotEmpty;
                                    });
                                    final List<String> attachments =
                                        await _uploadSupportAttachments(
                                          selectedImages,
                                        );
                                    if (!mounted) {
                                      return;
                                    }
                                    setSheetState(() {
                                      isUploadingImages = false;
                                    });
                                    final bool created = await _controller
                                        .createTicket(
                                          subject: subject,
                                          category: selectedCategory,
                                          message: message,
                                          priority: selectedPriority,
                                          attachments: attachments,
                                        );
                                    if (!mounted) {
                                      return;
                                    }
                                    if (created) {
                                      navigator.pop();
                                      _flushActionMessage('Support');
                                      await _showTicketDetailSheet(
                                        _controller.selectedTicketId ??
                                            _controller.tickets.first.id,
                                      );
                                    } else {
                                      _flushActionMessage('Support');
                                    }
                                  },
                            child: _controller.isSubmitting || isUploadingImages
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Submit ticket'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    subjectController.dispose();
    messageController.dispose();
  }

  Future<void> _showTicketDetailSheet(String ticketId) async {
    _controller.openTicket(ticketId);
    final TextEditingController replyController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, viewInsets.bottom + 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.82,
                child: _controller.isDetailLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.selectedTicket == null
                    ? _buildDetailErrorState()
                    : _buildTicketDetailContent(
                        detail: _controller.selectedTicket!,
                        replyController: replyController,
                      ),
              ),
            );
          },
        );
      },
    );

    replyController.dispose();
    _controller.clearSelectedTicket();
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) {
      AppGet.toNamed(RouteNames.create);
      return;
    }

    final Map<int, int> tabIndexMap = <int, int>{0: 0, 1: 1, 3: 3, 4: 4};
    final int? tabIndex = tabIndexMap[index];
    if (tabIndex == null) {
      return;
    }

    AppGet.offNamed(
      RouteNames.shell,
      arguments: <String, dynamic>{'tabIndex': tabIndex},
    );
  }
}
