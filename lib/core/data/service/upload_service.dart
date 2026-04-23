import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_end_points.dart';
import '../service_model/service_response_model.dart';
import 'api_client_service.dart';

enum UploadStatus {
  queued,
  uploading,
  completed,
  failed,
  cancelled,
  background,
}

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
  UploadService({ApiClientService? apiClient})
    : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;
  final Map<String, bool> _cancelled = <String, bool>{};

  Stream<UploadProgress> uploadFile({
    required String taskId,
    required String localPath,
    bool runInBackground = false,
    String endpoint = ApiEndPoints.uploads,
    String fileField = 'file',
    Map<String, String> fields = const <String, String>{},
  }) async* {
    if (kDebugMode) {
      debugPrint(
        '[UploadService] start taskId=$taskId endpoint=$endpoint '
        'file=$localPath fields=$fields',
      );
    }
    _cancelled[taskId] = false;
    if (runInBackground) {
      yield UploadProgress(
        taskId: taskId,
        progress: 0,
        status: UploadStatus.background,
      );
    }

    if (_cancelled[taskId] == true) {
      yield UploadProgress(
        taskId: taskId,
        progress: 0,
        status: UploadStatus.cancelled,
        error: 'Upload cancelled by user',
      );
      return;
    }

    yield UploadProgress(
      taskId: taskId,
      progress: 0,
      status: UploadStatus.uploading,
    );

    try {
      final ServiceResponseModel<Map<String, dynamic>> response =
          await _apiClient.postMultipart(
            endpoint,
            fileField: fileField,
            filePath: localPath,
            fields: fields,
          );

      if (_cancelled[taskId] == true) {
        if (kDebugMode) {
          debugPrint('[UploadService] cancelled taskId=$taskId');
        }
        yield UploadProgress(
          taskId: taskId,
          progress: 0,
          status: UploadStatus.cancelled,
          error: 'Upload cancelled by user',
        );
        return;
      }

      if (!response.isSuccess || response.data['success'] == false) {
        if (kDebugMode) {
          debugPrint(
            '[UploadService] failed taskId=$taskId status=${response.statusCode} '
            'message=${_extractMessage(response)}',
          );
        }
        yield UploadProgress(
          taskId: taskId,
          progress: 0,
          status: UploadStatus.failed,
          error:
              _extractMessage(response) ?? 'Unable to upload file right now.',
        );
        return;
      }

      final String? remotePath = _extractRemotePath(response.data);
      if (remotePath == null || remotePath.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[UploadService] failed taskId=$taskId no remote path returned',
          );
        }
        yield UploadProgress(
          taskId: taskId,
          progress: 0,
          status: UploadStatus.failed,
          error: 'Upload finished but no file path was returned by the API.',
        );
        return;
      }

      yield UploadProgress(
        taskId: taskId,
        progress: 1,
        status: UploadStatus.completed,
        remotePath: remotePath.trim(),
      );
      if (kDebugMode) {
        debugPrint(
          '[UploadService] completed taskId=$taskId remotePath=${remotePath.trim()}',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[UploadService] exception taskId=$taskId error=$error');
      }
      yield UploadProgress(
        taskId: taskId,
        progress: 0,
        status: UploadStatus.failed,
        error: error.toString(),
      );
    } finally {
      _cancelled.remove(taskId);
    }
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

  String? _extractRemotePath(Map<String, dynamic> payload) {
    const List<String> keys = <String>[
      'url',
      'path',
      'remotePath',
      'fileUrl',
      'filePath',
      'location',
      'secureUrl',
      'secure_url',
      'cdnUrl',
    ];

    for (final String key in keys) {
      final dynamic value = payload[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    const List<String> nestedKeys = <String>[
      'data',
      'result',
      'file',
      'upload',
      'asset',
    ];

    for (final String key in nestedKeys) {
      final dynamic value = payload[key];
      if (value is Map<String, dynamic>) {
        final String? nestedPath = _extractRemotePath(value);
        if (nestedPath != null && nestedPath.isNotEmpty) {
          return nestedPath;
        }
      } else if (value is Map) {
        final String? nestedPath = _extractRemotePath(
          Map<String, dynamic>.from(value),
        );
        if (nestedPath != null && nestedPath.isNotEmpty) {
          return nestedPath;
        }
      }
    }

    return null;
  }

  String? _extractMessage(ServiceResponseModel<Map<String, dynamic>> response) {
    final dynamic message = response.data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return response.message;
  }
}
