import '../model/job_application_model.dart';
import '../model/job_model.dart';

class JobsNetworkingRepository {
  List<JobModel> listJobs() {
    return const <JobModel>[
      JobModel(
        id: 'j1',
        title: 'Senior Product Designer',
        company: 'Northstar Labs',
        location: 'Remote',
        salary: '\$110k - \$140k',
        type: JobType.remote,
        experienceLevel: ExperienceLevel.senior,
        postedTime: '2 hours ago',
        logoInitial: 'N',
        logoColorValue: 0xFF2563EB,
        description: 'Lead end-to-end product design for creator tools and premium growth surfaces.',
        responsibilities: ['Design end-to-end flows', 'Run design reviews', 'Partner with PM and engineering'],
        requirements: ['5+ years experience', 'Strong systems thinking', 'Portfolio with shipped work'],
        skills: ['Figma', 'Design systems', 'Prototyping'],
        benefits: ['Remote stipend', 'Healthcare', 'Learning budget'],
        aboutCompany: 'Northstar Labs builds growth products for modern social platforms.',
        quickApplyEnabled: true,
        verifiedEmployer: true,
        featured: true,
        remoteFriendly: true,
        deadlineLabel: 'Apr 28',
      ),
      JobModel(
        id: 'j2',
        title: 'Flutter Engineer',
        company: 'Pixel Harbor',
        location: 'Dhaka, Bangladesh',
        salary: '\$40k - \$58k',
        type: JobType.fullTime,
        experienceLevel: ExperienceLevel.mid,
        postedTime: '5 hours ago',
        logoInitial: 'P',
        logoColorValue: 0xFF7C3AED,
        description: 'Build polished mobile social experiences with scalable architecture and production-ready UI.',
        responsibilities: ['Ship mobile features', 'Review code', 'Improve performance'],
        requirements: ['3+ years in Flutter', 'State management experience', 'API integration'],
        skills: ['Flutter', 'Dart', 'Bloc'],
        benefits: ['Hybrid work', 'Bonus', 'Device allowance'],
        aboutCompany: 'Pixel Harbor creates mobile products for creators and communities.',
        quickApplyEnabled: true,
        verifiedEmployer: true,
        remoteFriendly: false,
      ),
      JobModel(
        id: 'j3',
        title: 'Community Operations Intern',
        company: 'Circle Hive',
        location: 'Remote',
        salary: '\$900 / month',
        type: JobType.internship,
        experienceLevel: ExperienceLevel.entry,
        postedTime: '1 day ago',
        logoInitial: 'C',
        logoColorValue: 0xFFF97316,
        description: 'Support community growth, moderation, and live event operations for a global creator network.',
        responsibilities: ['Help moderators', 'Track trends', 'Support events'],
        requirements: ['Strong communication', 'Curious mindset', 'Availability 20 hrs/week'],
        skills: ['Community ops', 'Content review', 'Scheduling'],
        benefits: ['Mentorship', 'Certificate', 'Flexible hours'],
        aboutCompany: 'Circle Hive runs creator and founder communities across multiple regions.',
        quickApplyEnabled: true,
        verifiedEmployer: false,
        featured: true,
        remoteFriendly: true,
      ),
      JobModel(
        id: 'j4',
        title: 'Video Content Producer',
        company: 'Motion Arc',
        location: 'Singapore',
        salary: '\$65k - \$84k',
        type: JobType.contract,
        experienceLevel: ExperienceLevel.mid,
        postedTime: '2 days ago',
        logoInitial: 'M',
        logoColorValue: 0xFFEC4899,
        description: 'Produce launch videos, tutorials, and short-form social content.',
        responsibilities: ['Plan shoots', 'Edit reels', 'Collaborate with brand'],
        requirements: ['Strong editing reel', 'Motion sense', 'Camera workflow'],
        skills: ['Premiere Pro', 'After Effects', 'Storyboarding'],
        benefits: ['Creative budget', 'Travel support'],
        aboutCompany: 'Motion Arc turns product launches into memorable campaigns.',
        quickApplyEnabled: false,
        verifiedEmployer: true,
        externalApplyEnabled: true,
        contactLink: 'https://motionarc.local/jobs',
      ),
      JobModel(
        id: 'j5',
        title: 'Growth Marketing Lead',
        company: 'Wave Commerce',
        location: 'Hybrid • Kuala Lumpur',
        salary: '\$95k - \$120k',
        type: JobType.hybrid,
        experienceLevel: ExperienceLevel.lead,
        postedTime: '3 days ago',
        logoInitial: 'W',
        logoColorValue: 0xFF059669,
        description: 'Own performance, lifecycle, and referral growth across emerging markets.',
        responsibilities: ['Drive acquisition', 'Build referral loops', 'Lead experiments'],
        requirements: ['Performance marketing depth', 'Lifecycle knowledge', 'Leadership experience'],
        skills: ['Growth', 'Analytics', 'Lifecycle'],
        benefits: ['Bonus', 'Equity', 'Flexible team'],
        aboutCompany: 'Wave Commerce helps social sellers and creators monetize at scale.',
        quickApplyEnabled: true,
        verifiedEmployer: true,
      ),
    ];
  }

  List<JobModel> myJobs() {
    return <JobModel>[
      listJobs()[1].copyWith(draft: false, applied: false),
      listJobs()[4].copyWith(closed: true, applied: false),
      listJobs()[2].copyWith(draft: true, applied: false),
    ];
  }

  List<JobApplicationModel> myApplications() {
    return const <JobApplicationModel>[
      JobApplicationModel(
        id: 'a1',
        jobId: 'j1',
        applicantName: 'You',
        status: ApplicationStatus.pending,
        appliedDate: 'Apr 4',
        timeline: ['Application submitted', 'Recruiter review pending'],
      ),
      JobApplicationModel(
        id: 'a2',
        jobId: 'j2',
        applicantName: 'You',
        status: ApplicationStatus.viewed,
        appliedDate: 'Apr 1',
        timeline: ['Application submitted', 'Viewed by hiring manager'],
      ),
      JobApplicationModel(
        id: 'a3',
        jobId: 'j4',
        applicantName: 'You',
        status: ApplicationStatus.shortlisted,
        appliedDate: 'Mar 28',
        timeline: ['Application submitted', 'Viewed', 'Shortlisted'],
      ),
    ];
  }

  List<JobAlertModel> alerts() {
    return const <JobAlertModel>[
      JobAlertModel(
        id: 'al1',
        keyword: 'Flutter',
        location: 'Remote',
        frequency: AlertFrequency.daily,
      ),
      JobAlertModel(
        id: 'al2',
        keyword: 'Product Design',
        location: 'Asia',
        frequency: AlertFrequency.instant,
      ),
    ];
  }

  List<CompanyModel> companies() {
    return const <CompanyModel>[
      CompanyModel(
        id: 'c1',
        name: 'Northstar Labs',
        tagline: 'Creator growth tools',
        logoInitial: 'N',
        colorValue: 0xFF2563EB,
        followers: 18200,
        verified: true,
      ),
      CompanyModel(
        id: 'c2',
        name: 'Pixel Harbor',
        tagline: 'Mobile social products',
        logoInitial: 'P',
        colorValue: 0xFF7C3AED,
        followers: 9100,
        verified: true,
      ),
      CompanyModel(
        id: 'c3',
        name: 'Circle Hive',
        tagline: 'Communities at scale',
        logoInitial: 'C',
        colorValue: 0xFFF97316,
        followers: 6400,
      ),
    ];
  }

  CareerProfileModel profile() {
    return const CareerProfileModel(
      name: 'Maya Quinn',
      title: 'Product Designer',
      skills: ['Product Design', 'Design Systems', 'User Research', 'Figma'],
      experience: ['Senior Product Designer at North Peak', 'UI Designer at Delta Studio'],
      education: ['B.Des in Interaction Design'],
      resumeLabel: 'maya_quinn_resume.pdf',
      portfolioLinks: ['https://portfolio.maya.local', 'https://dribbble.com/mayaquinn'],
      availability: 'Open to work',
    );
  }

  EmployerStatsModel employerStats() {
    return const EmployerStatsModel(
      totalJobs: 8,
      totalApplicants: 124,
      shortlistedCandidates: 19,
      messages: 12,
    );
  }

  List<ApplicantModel> applicants() {
    return const <ApplicantModel>[
      ApplicantModel(
        id: 'ap1',
        name: 'Raisa Ahmed',
        title: 'Senior Flutter Engineer',
        skills: ['Flutter', 'Dart', 'Architecture'],
        status: ApplicationStatus.shortlisted,
        resumeLabel: 'raisa_flutter_resume.pdf',
      ),
      ApplicantModel(
        id: 'ap2',
        name: 'Noor Rahman',
        title: 'Product Designer',
        skills: ['Figma', 'Systems', 'Research'],
        status: ApplicationStatus.viewed,
        resumeLabel: 'noor_design_resume.pdf',
      ),
      ApplicantModel(
        id: 'ap3',
        name: 'Arian Hasan',
        title: 'Community Ops Specialist',
        skills: ['Moderation', 'Community Growth', 'Events'],
        status: ApplicationStatus.pending,
        resumeLabel: 'arian_ops_resume.pdf',
      ),
    ];
  }
}
