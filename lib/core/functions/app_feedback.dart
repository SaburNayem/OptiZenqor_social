import '../navigation/app_navigator.dart';

class AppFeedback {
  AppFeedback._();

  static void showSnackbar({required String title, required String message}) {
    AppNavigator.showSnackBar(title: title, message: message);
  }
}
