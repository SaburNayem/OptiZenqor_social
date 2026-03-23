class SafetyPrivacyModel {
  const SafetyPrivacyModel({
    this.isPrivate = false,
    this.hideContentFromUnknown = false,
    this.allowMentions = true,
  });

  final bool isPrivate;
  final bool hideContentFromUnknown;
  final bool allowMentions;

  SafetyPrivacyModel copyWith({
    bool? isPrivate,
    bool? hideContentFromUnknown,
    bool? allowMentions,
  }) {
    return SafetyPrivacyModel(
      isPrivate: isPrivate ?? this.isPrivate,
      hideContentFromUnknown:
          hideContentFromUnknown ?? this.hideContentFromUnknown,
      allowMentions: allowMentions ?? this.allowMentions,
    );
  }
}
