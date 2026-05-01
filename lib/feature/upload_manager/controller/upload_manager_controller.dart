import 'package:flutter/foundation.dart';

import '../model/upload_task_model.dart';

class UploadManagerController extends ChangeNotifier {
  List<UploadTaskModel> tasks = const [
    UploadTaskModel(
      id: 'u1',
      fileName: 'reel_clip.mp4',
      progress: 0.64,
      status: UploadStatus.uploading,
    ),
    UploadTaskModel(
      id: 'u2',
      fileName: 'story_photo.jpg',
      progress: 0.0,
      status: UploadStatus.failed,
    ),
  ];

  void retry(String id) {
    tasks = tasks
        .map(
          (task) => task.id == id
              ? UploadTaskModel(
                  id: task.id,
                  fileName: task.fileName,
                  progress: 0.2,
                  status: UploadStatus.uploading,
                )
              : task,
        )
        .toList();
    notifyListeners();
  }
}
