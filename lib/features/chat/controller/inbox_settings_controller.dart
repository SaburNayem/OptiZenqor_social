import 'package:flutter/foundation.dart';

class InboxSettingsController extends ChangeNotifier {
  String whoCanMessageMe = 'Everyone';
  bool messageRequestsFolder = true;
  bool autoFilterSpam = true;
  bool allowBusinessMessages = true;

  bool newMessageNotifications = true;
  bool messageRequestNotifications = true;
  bool groupMessageNotifications = true;
  bool silentMode = false;
  String notificationTone = 'Default';
  String notificationChannel = 'Push + In-app';

  bool sendReadReceipts = true;
  bool showSeenStatus = true;
  String lastSeenVisibility = 'Everyone';

  bool showOnlineStatus = true;
  bool showTypingIndicator = true;
  bool showLastActiveTime = true;

  bool cloudBackup = true;
  bool autoSyncDevices = true;
  String exportFormat = 'PDF';

  String imageAutoDownload = 'WiFi';
  String videoAutoDownload = 'WiFi';
  String audioAutoDownload = 'WiFi';
  double storageLimitMb = 512;

  bool aiAutoReply = false;
  bool smartSuggestions = true;
  bool autoTranslate = false;
  bool multiDeviceSessions = true;

  void setWhoCanMessageMe(String value) {
    whoCanMessageMe = value;
    notifyListeners();
  }

  void setMessageRequestsFolder(bool value) {
    messageRequestsFolder = value;
    notifyListeners();
  }

  void setAutoFilterSpam(bool value) {
    autoFilterSpam = value;
    notifyListeners();
  }

  void setAllowBusinessMessages(bool value) {
    allowBusinessMessages = value;
    notifyListeners();
  }

  void setNewMessageNotifications(bool value) {
    newMessageNotifications = value;
    notifyListeners();
  }

  void setMessageRequestNotifications(bool value) {
    messageRequestNotifications = value;
    notifyListeners();
  }

  void setGroupMessageNotifications(bool value) {
    groupMessageNotifications = value;
    notifyListeners();
  }

  void setSilentMode(bool value) {
    silentMode = value;
    notifyListeners();
  }

  void setNotificationTone(String value) {
    notificationTone = value;
    notifyListeners();
  }

  void setNotificationChannel(String value) {
    notificationChannel = value;
    notifyListeners();
  }

  void setSendReadReceipts(bool value) {
    sendReadReceipts = value;
    notifyListeners();
  }

  void setShowSeenStatus(bool value) {
    showSeenStatus = value;
    notifyListeners();
  }

  void setLastSeenVisibility(String value) {
    lastSeenVisibility = value;
    notifyListeners();
  }

  void setShowOnlineStatus(bool value) {
    showOnlineStatus = value;
    notifyListeners();
  }

  void setShowTypingIndicator(bool value) {
    showTypingIndicator = value;
    notifyListeners();
  }

  void setShowLastActiveTime(bool value) {
    showLastActiveTime = value;
    notifyListeners();
  }

  void setCloudBackup(bool value) {
    cloudBackup = value;
    notifyListeners();
  }

  void setAutoSyncDevices(bool value) {
    autoSyncDevices = value;
    notifyListeners();
  }

  void setExportFormat(String value) {
    exportFormat = value;
    notifyListeners();
  }

  void setImageAutoDownload(String value) {
    imageAutoDownload = value;
    notifyListeners();
  }

  void setVideoAutoDownload(String value) {
    videoAutoDownload = value;
    notifyListeners();
  }

  void setAudioAutoDownload(String value) {
    audioAutoDownload = value;
    notifyListeners();
  }

  void setStorageLimitMb(double value) {
    storageLimitMb = value;
    notifyListeners();
  }

  void setAiAutoReply(bool value) {
    aiAutoReply = value;
    notifyListeners();
  }

  void setSmartSuggestions(bool value) {
    smartSuggestions = value;
    notifyListeners();
  }

  void setAutoTranslate(bool value) {
    autoTranslate = value;
    notifyListeners();
  }

  void setMultiDeviceSessions(bool value) {
    multiDeviceSessions = value;
    notifyListeners();
  }
}
