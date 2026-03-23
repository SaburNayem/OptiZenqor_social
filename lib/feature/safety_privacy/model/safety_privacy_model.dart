class SafetyPrivacyModel {
  const SafetyPrivacyModel({this.isPrivate = false, this.hideContentFromUnknown = false, this.allowMentions = true});
  final bool isPrivate;
  final bool hideContentFromUnknown;
  final bool allowMentions;
  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPrivacyModel copyWi  SafetyPriv);
  final LocalStorageService _storage;

  Future<SafetyPrivacyModel> load() async {
    final raw = await _storage.readJson(StorageKeys.settingsState);
    if (raw == null) return const SafetyPrivacyModel();
    return SafetyPrivacyModel(
      isPrivate: raw['isPrivate'] as bool? ?? false,
      hideContentFromUnknown: raw['hideContentFromUnknown'] as bool? ?? false,
      allowMentions: raw['allowMentions'] as bool? ?? true,
    );
  }

  Future<void> save(SafetyPrivacyModel value) {
    return _storage.writeJson(StorageKeys.settingsState, <String, dynamic>{
      'isPrivate': value.isPrivate,
      'hideContentFromUnknown': value.hideContentFromUnknown,
      'allowMentions': value.allowMentions,
    });
  }
}
