import 'package:flutter/foundation.dart';

import '../model/job_model.dart';
import '../repository/jobs_networking_repository.dart';

class JobsNetworkingController extends ChangeNotifier {
  JobsNetworkingController({JobsNetworkingRepository? repository})
      : _repository = repository ?? JobsNetworkingRepository();

  final JobsNetworkingRepository _repository;
  List<JobModel> jobs = <JobModel>[];
  JobModel? selected;

  void load() {
    jobs = _repository.listJobs();
    selected = jobs.isEmpty ? null : jobs.first;
    notifyListeners();
  }

  void select(JobModel job) {
    selected = job;
    notifyListeners();
  }
}
