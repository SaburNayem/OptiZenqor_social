import 'package:flutter/material.dart';

import '../../../core/common_widget/empty_state_view.dart';
import '../../../core/data/models/reel_model.dart';
import '../repository/archive_repository.dart';

class ArchiveReelsScreen extends StatelessWidget {
  const ArchiveReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArchiveRepository repository = ArchiveRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Archived reels')),
      body: FutureBuilder<List<ReelModel>>(
        future: repository.archivedReels(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ReelModel>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final List<ReelModel> reels =
                  snapshot.data ?? const <ReelModel>[];
              if (reels.isEmpty) {
                return const EmptyStateView(
                  title: 'No archived reels',
                  message: 'Archived reels from backend will appear here.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(2),
                itemCount: reels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final ReelModel reel = reels[index];
                  final String imageUrl =
                      reel.coverUrl?.trim().isNotEmpty == true
                      ? reel.coverUrl!.trim()
                      : reel.thumbnail.trim();
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isEmpty
                          ? Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            )
                          : Image.network(imageUrl, fit: BoxFit.cover),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
      ),
    );
  }
}
