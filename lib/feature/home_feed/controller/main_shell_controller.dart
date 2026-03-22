import 'package:flutter/foundation.dart';

class MainShellController extends ChangeNotifier {
  int index = 0;

  void onTabChanged(int newIndex) {
    index = newIndex;
    notifyListeners();
  }
}
