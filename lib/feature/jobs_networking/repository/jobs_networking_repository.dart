import 'package:flutter/material.dart';
import '../model/job_model.dart';

class JobsNetworkingRepository {
  List<JobModel> listJobs() {
    return const [
      JobModel(
        id: '1',
        title: 'Senior React Developer',
        company: 'TechCorp Inc.',
        location: 'Remote',
        type: 'Full-time',
        salary: '\$120k - \$150k',
        postedTime: '2 hours ago',
        logoColor: Colors.blue,
        logoInitial: 'T',
      ),
      JobModel(
        id: '2',
        title: 'UI/UX Designer',
        company: 'Creative Studio',
        location: 'New York, NY',
        type: 'Hybrid',
        salary: '\$90k - \$110k',
        postedTime: '5 hours ago',
        logoColor: Colors.purple,
        logoInitial: 'C',
      ),
      JobModel(
        id: '3',
        title: 'Content Creator',
        company: 'Media Group',
        location: 'Los Angeles, CA',
        type: 'Contract',
        salary: '\$60k - \$80k',
        postedTime: '1 day ago',
        logoColor: Colors.pink,
        logoInitial: 'M',
      ),
      JobModel(
        id: '4',
        title: 'Marketing Manager',
        company: 'Growth Startup',
        location: 'Remote',
        type: 'Full-time',
        salary: '\$100k - \$130k',
        postedTime: '2 days ago',
        logoColor: Colors.green,
        logoInitial: 'G',
      ),
      JobModel(
        id: '5',
        title: 'Data Analyst',
        company: 'FinTech Solutions',
        location: 'London, UK',
        type: 'On-site',
        salary: '\$50k - \$70k',
        postedTime: '3 days ago',
        logoColor: Colors.indigo,
        logoInitial: 'F',
      ),
    ];
  }
}
