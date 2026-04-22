import 'package:flutter/foundation.dart';

import '../model/report_item_model.dart';

class ReportCenterController extends ChangeNotifier {
  final List<String> reasons = const [
    'Spam',
    'Harassment',
    'Violence',
    'False information',
  ];

  List<ReportItemModel> history = const [
    ReportItemModel(reason: 'Spam', status: 'Submitted'),
  ];

  void submit(String reason) {
    history = [
      ReportItemModel(reason: reason, status: 'Submitted'),
      ...history,
    ];
    notifyListeners();
  }
}
