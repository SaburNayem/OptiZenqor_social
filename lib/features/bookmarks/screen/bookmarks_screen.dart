import 'package:flutter/material.dart';
import 'package:optizenqor_social/core/navigation/app_get.dart';

import '../../../core/data/mock/mock_data.dart';
import '../controller/bookmarks_controller.dart';
import '../../../core/constants/app_colors.dart';

class BookmarksScreen extends StatelessWidget {
  BookmarksScreen({super.key}) {
    _controller.load();
  }

  final BookmarksController _controller = BookmarksController();

  @override
  Widget build(BuildContext context) {
    final currentUser = MockData.users.first;

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
          'Saved Collections',
          style: TextStyle(color: AppColors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.black87),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          // New Collection Button
          InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey200, width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 32, color: AppColors.grey400),
                          const SizedBox(height: 12),
                          Text(
                            'New Collection',
                            style: TextStyle(color: AppColors.grey500, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Opacity(opacity: 0, child: Text('Placeholder')), // For spacing
              ],
            ),
          ),

          _buildCollectionCard(
            'All Posts',
            '124',
            [
              'https://picsum.photos/seed/s1/200/200',
              'https://picsum.photos/seed/s2/200/200',
              'https://picsum.photos/seed/s3/200/200',
              'https://picsum.photos/seed/s4/200/200',
            ],
          ),
          _buildCollectionCard(
            'Travel Inspo',
            '42',
            [
              'https://picsum.photos/seed/s5/200/200',
              'https://picsum.photos/seed/s6/200/200',
              'https://picsum.photos/seed/s7/200/200',
              'https://picsum.photos/seed/s8/200/200',
            ],
          ),
          _buildCollectionCard(
            'Recipes',
            '18',
            [
              'https://picsum.photos/seed/s9/200/200',
              'https://picsum.photos/seed/s10/200/200',
              'https://picsum.photos/seed/s11/200/200',
              'https://picsum.photos/seed/s12/200/200',
            ],
          ),
          _buildCollectionCard(
            'Design Ideas',
            '56',
            [
              'https://picsum.photos/seed/s13/200/200',
              'https://picsum.photos/seed/s14/200/200',
              'https://picsum.photos/seed/s15/200/200',
              'https://picsum.photos/seed/s16/200/200',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(String title, String count, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              children: images.map((url) => Image.network(url, fit: BoxFit.cover)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '$count saved items',
          style: TextStyle(color: AppColors.grey500, fontSize: 12),
        ),
      ],
    );
  }
}


