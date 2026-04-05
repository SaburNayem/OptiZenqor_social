import 'package:flutter/foundation.dart';

class ChatSettingsController extends ChangeNotifier {
  ChatSettingsController({required this.chatId});

  final String chatId;

  bool saveMediaToGallery = true;
  bool autoDownloadMedia = true;
  bool priorityNotifications = false;
  bool blockUser = false;
  bool restrictUser = false;
  bool disappearingMessages = false;
  bool encryptionEnabled = false;
  bool voiceVideoCallsAllowed = true;
  bool reactionsEnabled = true;
  bool groupMentionsEnabled = true;

  String muteDuration = 'Off';
  String notificationTone = 'Default';
  String customTheme = 'Ocean';
  String nickname = '';
  String wallpaper = 'Default';
  String selfDestructTimer = 'Off';
  String messagePermission = 'Everyone';
  String memberAddPermission = 'Admins only';

  void setSaveMediaToGallery(bool value) {
    saveMediaToGallery = value;
    notifyListeners();
  }

  void setAutoDownloadMedia(bool value) {
    autoDownloadMedia = value;
    notifyListeners();
  }

  void setPriorityNotifications(bool value) {
    priorityNotifications = value;
    notifyListeners();
  }

  void setBlockUser(bool value) {
    blockUser = value;
    notifyListeners();
  }

  void setRestrictUser(bool value) {
    restrictUser = value;
    notifyListeners();
  }

  void setDisappearingMessages(bool value) {
    disappearingMessages = value;
    notifyListeners();
  }

  void setEncryptionEnabled(bool value) {
    encryptionEnabled = value;
    notifyListeners();
  }

  void setVoiceVideoCallsAllowed(bool value) {
    voiceVideoCallsAllowed = value;
    notifyListeners();
  }

  void setReactionsEnabled(bool value) {
    reactionsEnabled = value;
    notifyListeners();
  }

  void setGroupMentionsEnabled(bool value) {
    groupMentionsEnabled = value;
    notifyListeners();
  }

  void setMuteDuration(String value) {
    muteDuration = value;
    notifyListeners();
  }

  void setNotificationTone(String value) {
    notificationTone = value;
    notifyListeners();
  }

  void setCustomTheme(String value) {
    customTheme = value;
    notifyListeners();
  }

  void setNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  void setWallpaper(String value) {
    wallpaper = value;
    notifyListeners();
  }

  void setSelfDestructTimer(String value) {
    selfDestructTimer = value;
    notifyListeners();
  }

  void setMessagePermission(String value) {
    messagePermission = value;
    notifyListeners();
  }

  void setMemberAddPermission(String value) {
    memberAddPermission = value;
    notifyListeners();
  }
}
