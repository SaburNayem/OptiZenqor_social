import 'package:flutter/foundation.dart';

import '../model/verification_request_model.dart';
import '../repository/verification_request_repository.dart';

class VerificationRequestController extends ChangeNotifier {
  VerificationRequestController({VerificationRequestRepository? repository})
    : _repository = repository ?? VerificationRequestRepository();

  final VerificationRequestRepository _repository;
  List<String> requiredDocuments = const <String>[
    'Government ID',
    'Business proof',
    'Profile photo',
  ];

  VerificationRequestModel model = const VerificationRequestModel(
    status: VerificationStatus.notRequested,
    reason: 'Not submitted',
    selectedDocuments: <String>[],
  );
  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    requiredDocuments =
        await _repository.loadRequiredDocuments() ?? requiredDocuments;
    model = await _repository.load();
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDocument(String documentName) async {
    final updated = List<String>.from(model.selectedDocuments);
    if (updated.contains(documentName)) {
      updated.remove(documentName);
    } else {
      updated.add(documentName);
    }
    model = model.copyWith(selectedDocuments: updated);
    await _repository.save(model);
    notifyListeners();
  }

  Future<void> submit() async {
    model = await _repository.submit(model);
    notifyListeners();
  }

  Future<void> updateStatus(VerificationStatus status) async {
    final reason = switch (status) {
      VerificationStatus.notRequested =>
        'Submit creator or business documents to start review.',
      VerificationStatus.pending => 'Documents uploaded. Under review.',
      VerificationStatus.approved =>
        'Approved. Verification badge is ready to appear on your profile.',
      VerificationStatus.rejected =>
        'Rejected. Update your documents and try again.',
    };
    model = model.copyWith(
      status: status,
      reason: reason,
      submittedAt: status == VerificationStatus.notRequested
          ? null
          : model.submittedAt ?? DateTime.now(),
      clearSubmittedAt: status == VerificationStatus.notRequested,
    );
    await _repository.save(model);
    notifyListeners();
  }
}
