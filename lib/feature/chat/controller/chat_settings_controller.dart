import 'package:flutter/foundation.dart';

class ChatSettingsController extends ChangeNotifier {
  ChatSettingsController({required this.chatId});

  final String chatId;

  bool muteNotifications = false;
  bool pinnedConversation = false;
  bool readReceipts = true;
  bool mediaAutoDownload = true;
  bool disappearingMessages = false;

  void toggleMute(bool value) {
    muteNotifications = value;
    notifyListeners();
  }

  void togglePinned(bool value) {
    pinnedConversation = value;
    notifyListeners();
  }

  void toggleReadReceipts(bool value) {
    readReceipts = value;
    notifyListeners();
  }

  void toggleMediaAutoDownload(bool value) {
    mediaAutoDownload = value;
    notifyListeners();
  }

  void toggleDisappearingMessages(bool value) {
    disappearingMessages = value;
    notifyListeners();
  }
}
