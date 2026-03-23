import '../model/job_model.dart';

class JobsNetworkingRepository {
  List<JobModel> listJobs() {
    return const <JobModel>[
      JobModel(
        id: 'j1',
        title: 'Flutter Engineer',
        company: 'OptiZenqor',
        description: 'Build social platform experiences.',
      ),
      JobModel(
        id: 'j2',
        title: 'Product Designer',
        company: 'Nexa Studio',
        description: 'Design growth-focused community and marketplace experiences.',
      ),
      JobModel(
        id: 'j3',
        title: 'Community Manager',
        company: 'Orbit Circle',
        description: 'Lead creator programs, onboarding, and moderation workflows.',
      ),
    ];
  }
}
