import 'package:flutter/material.dart';

import '../../../core/navigation/app_get.dart';
import '../../../app_route/route_names.dart';
import '../controller/events_controller.dart';
import '../../../core/constants/app_colors.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventsController _controller = EventsController();
  final TextEditingController _titleController = TextEditingController(
    text: 'Creator meetup',
  );
  final TextEditingController _dateController = TextEditingController(
    text: 'Apr 20, 2026 • 6:30 PM',
  );
  final TextEditingController _locationController = TextEditingController(
    text: 'Dhaka Creative Hub',
  );

  final List<_PoolDraft> _pools = <_PoolDraft>[
    const _PoolDraft(
      name: 'VIP table',
      amount: '\$250',
      limit: '8 spots',
      benefit: 'Priority seating and private host support',
    ),
    const _PoolDraft(
      name: 'Friends pass',
      amount: '\$80',
      limit: '20 spots',
      benefit: 'Shared entry package for close friends',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(color: AppColors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.hexFFF7FEFF,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.hexFFB2EBF2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set up your event',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add event details and configure pools from this separate create flow.',
                style: TextStyle(color: AppColors.grey600),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _titleController,
                label: 'Event title',
                icon: Icons.edit_calendar_outlined,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _dateController,
                label: 'Date and time',
                icon: Icons.schedule,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              _buildPoolsSection(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hexFF26C6DA,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Publish event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: _openCreatePoolScreen,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Create pool'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hexFF00ACC1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add pricing or access pools from a dedicated setup screen.',
          style: TextStyle(color: AppColors.grey600),
        ),
        const SizedBox(height: 14),
        ..._pools.map(_buildPoolCard),
      ],
    );
  }

  Widget _buildPoolCard(_PoolDraft pool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hexFFE0F7FA),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.hexFFE0F7FA,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.groups_2_outlined, color: AppColors.hexFF00ACC1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pool.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pool.amount} • ${pool.limit}',
                  style: TextStyle(color: AppColors.grey600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  pool.benefit,
                  style: TextStyle(color: AppColors.grey500, fontSize: 12),
                ),
              ],
            ),
          ),
          const Text(
            'Ready',
            style: TextStyle(
              color: AppColors.hexFF00ACC1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.hexFF26C6DA),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _handleCreateEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppGet.snackbar('Missing title', 'Enter an event title to continue.');
      return;
    }

    await _controller.create(
      title,
      location: _locationController.text.trim(),
    );
    AppGet.snackbar('Event ready', 'Your event draft has been created.');
  }

  Future<void> _openCreatePoolScreen() async {
    final result = await AppGet.toNamed<Map<String, String>>(
      RouteNames.eventsPoolCreate,
    );
    if (result == null) {
      return;
    }

    setState(() {
      _pools.insert(
        0,
        _PoolDraft(
          name: result['name'] ?? '',
          amount: result['amount'] ?? '',
          limit: result['limit'] ?? '',
          benefit: result['benefit'] ?? '',
        ),
      );
    });

    AppGet.snackbar('Pool added', 'The new pool is now attached to this event.');
  }
}

class _PoolDraft {
  const _PoolDraft({
    required this.name,
    required this.amount,
    required this.limit,
    required this.benefit,
  });

  final String name;
  final String amount;
  final String limit;
  final String benefit;
}



