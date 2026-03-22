import 'package:flutter/foundation.dart';

import '../model/verification_request_model.dart';

class VerificationRequestController extends ChangeNotifier {
  VerificationRequestModel model = const VerificationRequestModel(
    status: VerificationStatus.notRequested,
    reason: 'Not submitted',
  );

  void submit() {
    model = const VerificationRequestModel(
      status: VerificationStatus.pending,
      reason: 'Documents uploaded. Under review.',
    );
    notifyListeners();
  }
}
