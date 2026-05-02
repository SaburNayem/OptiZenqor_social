import 'dart:math' as math;

import '../model/media_viewer_item_model.dart';
import '../model/media_viewer_route_arguments.dart';

class MediaViewerController {
  MediaViewerController({
    List<MediaViewerItemModel>? items,
    int initialIndex = 0,
    this.title,
  }) : items = List<MediaViewerItemModel>.unmodifiable(
         items ?? const <MediaViewerItemModel>[],
       ),
       initialIndex = items == null || items.isEmpty
           ? 0
           : math.max(0, math.min(initialIndex, items.length - 1));

  factory MediaViewerController.fromArguments(
    MediaViewerRouteArguments? arguments,
  ) {
    return MediaViewerController(
      items: arguments?.items,
      initialIndex: arguments?.initialIndex ?? 0,
      title: arguments?.title,
    );
  }

  final List<MediaViewerItemModel> items;
  final int initialIndex;
  final String? title;

  MediaViewerItemModel itemAt(int index) => items[index];

  static List<MediaViewerItemModel> fromSources(List<String> sources) {
    return sources.map(MediaViewerItemModel.fromSource).toList(growable: false);
  }
}
