import 'package:flutter/foundation.dart';

import '../model/legal_consent_model.dart';

class LegalComplianceController extends ChangeNotifier {
  LegalConsentModel consent = const LegalConsentModel(
    termsAccepted: false,
    privacyAccepted: false,
    guidelinesAccepted: false,
  );

  void toggleTerms() {
    consent = LegalConsentModel(
      termsAccepted: !consent.termsAccepted,
      privacyAccepted: consent.privacyAccepted,
      guidelinesAccepted: consent.guidelinesAccepted,
    );
    notifyListeners();
  }

  void togglePrivacy() {
    consent = LegalConsentModel(
      termsAccepted: consent.termsAccepted,
      privacyAccepted: !consent.privacyAccepted,
      guidelinesAccepted: consent.guidelinesAccepted,
    );
    notifyListeners();
  }

  void toggleGuidelines() {
    consent = LegalConsentModel(
      termsAccepted: consent.termsAccepted,
      privacyAccepted: consent.privacyAccepted,
      guidelinesAccepted: !consent.guidelinesAccepted,
    );
    notifyListeners();
  }
}
