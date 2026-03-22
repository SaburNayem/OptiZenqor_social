class LegalConsentModel {
  const LegalConsentModel({
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.guidelinesAccepted,
  });

  final bool termsAccepted;
  final bool privacyAccepted;
  final bool guidelinesAccepted;
}
