import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../app_route/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/service/auth_session_service.dart';
import '../controller/events_controller.dart';
import '../model/event_item_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsController _controller = EventsController();
  final AuthSessionService _sessionService = AuthSessionService();
  String _currentUserAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    await _controller.load();
    final session = await _sessionService.readSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentUserAvatar = session?.user?.avatar ?? '';
    });
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
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black87),
              onPressed: AppGet.back,
            ),
            title: const Text(
              'Events',
              style: TextStyle(
                color: AppColors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.black87),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.grey100,
                  backgroundImage: _currentUserAvatar.trim().isEmpty
                      ? null
                      : NetworkImage(_currentUserAvatar),
                  child: _currentUserAvatar.trim().isEmpty
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => AppGet.toNamed(RouteNames.eventsCreate),
                      icon: Icon(
                        Icons.add,
                        color: AppColors.hexFF26C6DA.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((_controller.errorMessage ?? '').isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.black87),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _controller.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller.events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No events are available from the backend yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _controller.events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            _buildEventCard(_controller.events[index]),
      ),
    );
  }

  Widget _buildEventCard(EventItemModel event) {
    final String imageUrl = event.mediaGallery.firstWhere(
      (item) => item.trim().isNotEmpty,
      orElse: () => '',
    );
    final String statsLabel = event.statsLabel.trim().isEmpty
        ? '${event.attendeeAvatarUrls.length} going'
        : event.statsLabel.trim();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.hexFF26C6DA,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.date.toLocal().toString(),
                      style: TextStyle(color: AppColors.grey600, fontSize: 13),
                    ),
                  ],
                ),
                if (event.location.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.hexFF26C6DA,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        statsLabel,
                        style: TextStyle(
                          color: AppColors.grey400,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (event.priceLabel.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          event.priceLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black87,
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: () => _controller.rsvp(event.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.hexFFE0F7FA,
                        foregroundColor: AppColors.hexFF00ACC1,
                      ),
                      child: Text(event.rsvped ? 'Going' : 'RSVP'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
