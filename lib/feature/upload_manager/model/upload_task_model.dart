enum UploadStatus { queued, uploading, paused, failed, completed }

class UploadTaskModel {
  const UploadTaskModel({
    required this.id,
    required this.fileName,
    required this.progress,
    required this.status,
  });

  final String id;
  final String fileName;
  final double progress;
  final UploadStatus status;
}
