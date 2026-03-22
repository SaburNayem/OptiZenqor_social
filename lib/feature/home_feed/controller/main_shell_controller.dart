import 'package:get/get.dart';

class MainShellController extends GetxController {
  int index = 0;

  void onTabChanged(int newIndex) {
    index = newIndex;
    update();
  }
}
