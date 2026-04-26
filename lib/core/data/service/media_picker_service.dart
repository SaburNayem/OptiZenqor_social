import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> pickPostMedia() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: <String>[
        'jpg',
        'jpeg',
        'png',
        'webp',
        'mp4',
        'mov',
        'm4v',
        'webm',
      ],
    );
    if (result == null) {
      return <String>[];
    }
    return result.files
        .map((file) => file.path)
        .whereType<String>()
        .toList(growable: false);
  }

  Future<List<String>> pickImages() async {
    final files = await _picker.pickMultiImage();
    return files.map((file) => file.path).toList(growable: false);
  }

  Future<String?> pickImage({
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return file?.path;
  }

  Future<String?> captureImage({
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return file?.path;
  }

  Future<String?> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    return file?.path;
  }

  Future<String?> captureVideo({
    Duration? maxDuration,
  }) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration,
    );
    return file?.path;
  }
}
