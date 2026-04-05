import 'package:get/get.dart';

class AppFeedback {
  AppFeedback._();

  static void showSnackbar({required String title, required String message}) {
    Get.snackbar(title, message);
  }
}
