import 'dart:io';

import 'package:flutter/material.dart';

import '../data/models/post_model.dart';
import '../data/models/user_model.dart';
import '../helpers/format_helper.dart';
import 'app_avatar.dart';
import 'inline_video_player.dart';
import '../constants/app_colors.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.author,
    this.likeCount,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onTap,
    this.onAuthorTap,
    this.onMoreTap,
    this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
    this.onBookmarkTap,
    super.key,
  });

  final PostModel post;
  final UserModel author;
  final int? likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: author.avatar,
                      verified: author.verified,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: onAuthorTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              FormatHelper.timeAgo(post.createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMoreTap,
                      icon: const Icon(Icons.more_horiz, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Media
              if (post.media.isNotEmpty)
                Builder(
                  builder: (context) {
                    final media = post.media.first;
                    final lower = media.toLowerCase();
                    final isVideo =
                        lower.endsWith('.mp4') ||
                        lower.endsWith('.mov') ||
                        lower.endsWith('.webm') ||
                        lower.endsWith('.m4v');
                    final isNetworkMedia =
                        media.startsWith('http://') ||
                        media.startsWith('https://');
                    final Widget mediaPreview = isVideo
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: InlineVideoPlayer(
                              networkUrl: isNetworkMedia ? media : null,
                              filePath: isNetworkMedia ? null : media,
                              autoPlay: true,
                            ),
                          )
                        : _PostPhotoPreview(
                            source: media,
                            isNetworkSource: isNetworkMedia,
                          );
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          mediaPreview,
                          if (post.media.length > 1)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withValues(
                                    alpha: 0.55,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${post.media.length} items',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 12),
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onLikeTap,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.red : null,
                      ),
                    ),
                    IconButton(
                      onPressed: onCommentTap,
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                    IconButton(
                      onPressed: onShareTap,
                      icon: const Icon(Icons.share_outlined),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onBookmarkTap,
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppColors.black87 : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Likes and Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${FormatHelper.formatCompactNumber(likeCount ?? post.likes)} likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '@${author.username} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: post.caption),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (post.comments > 0)
                      InkWell(
                        onTap: onCommentTap,
                        child: Text(
                          'View all ${post.comments} comments',
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (post.shareCount > 0 || post.viewCount > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (post.shareCount > 0)
                            '${FormatHelper.formatCompactNumber(post.shareCount)} shares',
                          if (post.viewCount > 0)
                            '${FormatHelper.formatCompactNumber(post.viewCount)} views',
                        ].join(' | '),
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostPhotoPreview extends StatefulWidget {
  const _PostPhotoPreview({
    required this.source,
    required this.isNetworkSource,
  });

  final String source;
  final bool isNetworkSource;

  @override
  State<_PostPhotoPreview> createState() => _PostPhotoPreviewState();
}

class _PostPhotoPreviewState extends State<_PostPhotoPreview> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(covariant _PostPhotoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.isNetworkSource != widget.isNetworkSource) {
      _aspectRatio = null;
      _resolveAspectRatio();
    }
  }

  @override
  void dispose() {
    _removeImageStreamListener();
    super.dispose();
  }

  void _resolveAspectRatio() {
    _removeImageStreamListener();
    final ImageProvider provider = widget.isNetworkSource
        ? NetworkImage(widget.source)
        : FileImage(File(widget.source));
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        final int width = imageInfo.image.width;
        final int height = imageInfo.image.height;
        if (width > 0 && height > 0 && mounted) {
          setState(() {
            _aspectRatio = width / height;
          });
        }
        stream.removeListener(listener);
        if (_imageStream == stream) {
          _imageStream = null;
          _imageStreamListener = null;
        }
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (_imageStream == stream) {
          _imageStream = null;
          _imageStreamListener = null;
        }
      },
    );
    _imageStream = stream;
    _imageStreamListener = listener;
    stream.addListener(listener);
  }

  void _removeImageStreamListener() {
    final ImageStream? stream = _imageStream;
    final ImageStreamListener? listener = _imageStreamListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final double aspectRatio = _aspectRatio ?? 1;
    final double maxMediaHeight = screenSize.height * 0.62;
    final double mediaHeight = (screenSize.width / aspectRatio).clamp(
      1,
      maxMediaHeight,
    );
    final int cacheWidth = (screenSize.width * devicePixelRatio).round();
    final int cacheHeight = (mediaHeight * devicePixelRatio).round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: mediaHeight,
      width: double.infinity,
      color: const Color(0xFFF2F5F7),
      child: widget.isNetworkSource
          ? Image.network(
              widget.source,
              width: double.infinity,
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            )
          : Image.file(
              File(widget.source),
              width: double.infinity,
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            ),
    );
  }
}
