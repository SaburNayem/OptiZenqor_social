import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';
import '../controller/events_controller.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsController _controller = EventsController();
  int _selectedDateIndex = 2; // Default to Wednesday 14

  final List<Map<String, String>> _dates = [
    {'day': 'Mon', 'date': '12'},
    {'day': 'Tue', 'date': '13'},
    {'day': 'Wed', 'date': '14'},
    {'day': 'Thu', 'date': '15'},
    {'day': 'Fri', 'date': '16'},
    {'day': 'Sat', 'date': '17'},
    {'day': 'Sun', 'date': '18'},
  ];

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => AppGet.back(),
        ),
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.black87,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(currentUser.avatar),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Calendar
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDateIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF26C6DA)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dates[index]['day']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dates[index]['date']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.add,
                  color: const Color(0xFF26C6DA).withValues(alpha: 0.8),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildEventCard(
                      'Tech Innovators Meetup',
                      'Wed, Oct 14 • 6:00 PM',
                      'Downtown Hub, NY',
                      'https://picsum.photos/seed/tech/800/400',
                      '\$25.00',
                      '+124 going',
                    ),
                    const SizedBox(height: 16),
                    _buildEventCard(
                      'Modern Art Exhibition',
                      'Fri, Oct 16 • 10:00 AM',
                      'City Gallery',
                      'https://picsum.photos/seed/art/800/400',
                      '\$20.00',
                      '+85 going',
                    ),
                    const SizedBox(height: 16),
                    _buildEventCard(
                      'Summer Music Festival',
                      'Sat, Oct 17 • 2:00 PM',
                      'Central Park',
                      'https://picsum.photos/seed/music/800/400',
                      '\$35.00',
                      '+1500 going',
                    ),
                    const SizedBox(height: 16),
                    _buildEventCard(
                      'Food & Wine Tasting',
                      'Sun, Oct 18 • 5:00 PM',
                      'Grand Hotel',
                      'https://picsum.photos/seed/food/800/400',
                      '\$45.00',
                      '+42 going',
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String time,
    String location,
    String imageUrl,
    String price,
    String stats,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                      color: Color(0xFF26C6DA),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF26C6DA),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar stack mock
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(
                                  MockData.users[0].avatar,
                                ),
                              ),
                              Positioned(
                                left: 12,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage(
                                    MockData.users[1].avatar,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 24,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundImage: NetworkImage(
                                    MockData.users[2].avatar,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stats,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'RSVP',
                        style: TextStyle(
                          color: Color(0xFF00ACC1),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
