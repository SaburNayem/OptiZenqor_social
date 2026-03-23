import '../model/job_model.dart';

class JobsNetworkingRepository {
  List<JobModel> listJobs() {
    return const <JobModel>[
      JobModel(id: 'j1', title: 'Flutter Engineer', company: 'OptiZenqor', description: 'Build social platform experiences.'),
      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', description: 'Design growt      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', description: 'Design growt      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', description: 'Design growt      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', descriptionext      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', description: 'Design growt      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', description: 'Design growt      JobModel(id: 'j2', title: 'Product Designer', company: 'Nexa Studio', descrip _repository.listJobs();
    selected = jobs.isEmpty ? null : jobs.first;
    notifyListeners();
  }

  void select(JobModel job) {
    selected = job;
    notifyListeners();
  }
}
