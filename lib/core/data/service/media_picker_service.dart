import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> pickImages() async {
    final files = await _picker.pickMultiImage();
    return files.map((file) => file.path).toList(growable: false);
  }

  Future<String?> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  Future<String?> captureImage() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  Future<String?> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    return file?.path;
  }
}
