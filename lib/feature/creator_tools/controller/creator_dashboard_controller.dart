import 'package:flutter/foundation.dart';

import '../model/creator_metric_model.dart';

class CreatorDashboardController extends ChangeNotifier {
  final List<CreatorMetricModel> metrics = const [
    CreatorMetricModel(label: 'Engagement', value: '8.2%'),
    CreatorMetricModel(label: 'Followers Growth', value: '+1.4K'),
    CreatorMetricModel(label: 'Reach', value: '124K'),
    CreatorMetricModel(label: 'Estimated Earnings', value: '\$2,430'),
  ];
}
