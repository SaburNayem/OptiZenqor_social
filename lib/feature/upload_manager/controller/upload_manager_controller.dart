import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/service_model/service_response_model.dart';
import '../model/upload_task_model.dart';
import '../service/upload_manager_service.dart';

class UploadManagerController extends ChangeNotifier {
  UploadManagerController({UploadManagerService? service})
    : _service = service ?? UploadManagerService() {
    load();
  }

  final UploadManagerService _service;

  List<UploadTaskModel> tasks = const <UploadTaskModel>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ServiceResponseModel<Map<String, dynamic>> response = await _service
          .getEndpoint('uploads');
      if (!response.isSuccess || response.data['success'] == false) {
        throw Exception(response.message ?? 'Unable to load uploads.');
      }

      final List<UploadTaskModel> resolvedTasks =
          ApiPayloadReader.readMapList(
                response.data,
                preferredKeys: const <String>['items', 'uploads', 'results'],
              )
              .map(_taskFromApiJson)
              .where((UploadTaskModel item) => item.id.isNotEmpty)
              .toList(growable: false);

      tasks = resolvedTasks;
      errorMessage = null;
    } catch (error) {
      tasks = const <UploadTaskModel>[];
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry(String id) async {
    await load();
  }

  UploadTaskModel _taskFromApiJson(Map<String, dynamic> json) {
    final String statusValue = ApiPayloadReader.readString(
      json['status'],
      fallback: 'queued',
    ).toLowerCase();

    return UploadTaskModel(
      id: ApiPayloadReader.readString(json['id']),
      fileName: ApiPayloadReader.readString(
        json['fileName'] ?? json['originalFilename'] ?? json['publicId'],
        fallback: 'Upload',
      ),
      progress: _progressForStatus(statusValue),
      status: _statusFromValue(statusValue),
    );
  }

  UploadStatus _statusFromValue(String value) {
    switch (value) {
      case 'completed':
      case 'success':
        return UploadStatus.completed;
      case 'failed':
      case 'error':
        return UploadStatus.failed;
      case 'uploading':
      case 'processing':
        return UploadStatus.uploading;
      case 'paused':
        return UploadStatus.paused;
      default:
        return UploadStatus.queued;
    }
  }

  double _progressForStatus(String value) {
    switch (value) {
      case 'completed':
      case 'success':
        return 1;
      case 'uploading':
      case 'processing':
        return 0.5;
      default:
        return 0;
    }
  }
}
