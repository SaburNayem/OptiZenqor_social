import 'dart:async';

enum UploadStatus { queued, uploading, completed, failed, cancelled, background }

class UploadProgress {
  const UploadProgress({
    required this.taskId,
    required this.progress,
    required this.status,
    this.remotePath,
    this.error,
  });

  final String taskId;
  final double progress;
  final UploadStatus status;
  final String? remotePath;
  final String? error;
}

class UploadService {
  final Map<String, bool> _cancelled = <String, bool>{};

  Stream<UploadProgress> uploadFile({
    required String taskId,
    required String localPath,
    bool runInBackground = false,
  }) async* {
    _cancelled[taskId] = false;
    if (runInBackground) {
      yield UploadProgress(
        taskId: taskId,
        progress: 0,
        status: UploadStatus.background,
      );
    }

    yield UploadProgress(
      taskId: taskId,
      progress: 0,
      status: UploadStatus.uploading,
    );

    for (var i = 1; i <= 20; i++) {
      if (_cancelled[taskId] == true) {
        yield UploadProgress(
          taskId: taskId,
          progress: i / 20,
          status: UploadStatus.cancelled,
          error: 'Upload cancelled by user',
        );
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
      yield UploadProgress(
        taskId: taskId,
        progress: i / 20,
        status: UploadStatus.uploading,
      );
    }

    yield UploadProgress(
      taskId: taskId,
      progress: 1,
      status: UploadStatus.completed,
      remotePath: 'remote://uploaded/$localPath',
    );
  }

  void cancel(String taskId) {
    _cancelled[taskId] = true;
  }

  Stream<UploadProgress> retry({
    required String taskId,
    required String localPath,
  }) {
    _cancelled[taskId] = false;
    return uploadFile(taskId: taskId, localPath: localPath);
  }
}
