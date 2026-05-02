import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/api/api_payload_reader.dart';
import '../model/legal_consent_model.dart';
import '../service/legal_compliance_service.dart';

class LegalComplianceController extends ChangeNotifier {
  LegalComplianceController({LegalComplianceService? service})
    : _service = service ?? LegalComplianceService() {
    unawaited(load());
  }

  final LegalComplianceService _service;

  LegalConsentModel consent = const LegalConsentModel(
    termsAccepted: false,
    privacyAccepted: false,
    guidelinesAccepted: false,
  );
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getEndpoint('compliance');
      final Map<String, dynamic>? payload = ApiPayloadReader.readMap(
        response.data['data'],
      );
      consent = LegalConsentModel(
        termsAccepted:
            ApiPayloadReader.readBool(payload?['termsAccepted']) ?? false,
        privacyAccepted:
            ApiPayloadReader.readBool(payload?['privacyAccepted']) ?? false,
        guidelinesAccepted:
            ApiPayloadReader.readBool(payload?['guidelinesAccepted']) ?? false,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTerms() async {
    await _updateConsent('legal.terms_accepted', !consent.termsAccepted);
  }

  Future<void> togglePrivacy() async {
    await _updateConsent('legal.privacy_accepted', !consent.privacyAccepted);
  }

  Future<void> toggleGuidelines() async {
    await _updateConsent(
      'legal.guidelines_accepted',
      !consent.guidelinesAccepted,
    );
  }

  Future<void> _updateConsent(String key, bool value) async {
    final LegalConsentModel previous = consent;
    consent = LegalConsentModel(
      termsAccepted: consent.termsAccepted,
      privacyAccepted: consent.privacyAccepted,
      guidelinesAccepted: consent.guidelinesAccepted,
    );
    switch (key) {
      case 'legal.terms_accepted':
        consent = LegalConsentModel(
          termsAccepted: value,
          privacyAccepted: consent.privacyAccepted,
          guidelinesAccepted: consent.guidelinesAccepted,
        );
        break;
      case 'legal.privacy_accepted':
        consent = LegalConsentModel(
          termsAccepted: consent.termsAccepted,
          privacyAccepted: value,
          guidelinesAccepted: consent.guidelinesAccepted,
        );
        break;
      default:
        consent = LegalConsentModel(
          termsAccepted: consent.termsAccepted,
          privacyAccepted: consent.privacyAccepted,
          guidelinesAccepted: value,
        );
    }
    errorMessage = null;
    notifyListeners();
    try {
      await _service.patchEndpoint(
        'consents',
        payload: <String, dynamic>{
          if (key == 'legal.terms_accepted') 'terms': value,
          if (key == 'legal.privacy_accepted') 'privacy': value,
          if (key == 'legal.guidelines_accepted') 'guidelines': value,
        },
      );
    } catch (error) {
      consent = previous;
      errorMessage = error.toString();
      notifyListeners();
    }
  }
}
