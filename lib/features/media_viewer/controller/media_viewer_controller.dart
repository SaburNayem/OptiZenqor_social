import '../model/media_viewer_item_model.dart';

class MediaViewerController {
  final List<MediaViewerItemModel> items = const [
    MediaViewerItemModel(
      url: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200',
      type: 'image',
    ),
    MediaViewerItemModel(
      url: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1200',
      type: 'image',
    ),
  ];
}
