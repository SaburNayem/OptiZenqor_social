import 'media_viewer_item_model.dart';

class MediaViewerRouteArguments {
  const MediaViewerRouteArguments({
    required this.items,
    this.initialIndex = 0,
    this.title,
  });

  final List<MediaViewerItemModel> items;
  final int initialIndex;
  final String? title;
}
