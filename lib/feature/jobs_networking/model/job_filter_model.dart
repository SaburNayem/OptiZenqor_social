import 'job_model.dart';

class JobFilterModel {
  const JobFilterModel({
    this.keyword = '',
    this.location = 'Any',
    this.salaryRange = 'Any',
    this.jobType,
    this.experienceLevel,
    this.workMode = 'Any',
    this.companySize = 'Any',
  });

  final String keyword;
  final String location;
  final String salaryRange;
  final JobType? jobType;
  final ExperienceLevel? experienceLevel;
  final String workMode;
  final String companySize;

  JobFilterModel copyWith({
    String? keyword,
    String? location,
    String? salaryRange,
    JobType? jobType,
    ExperienceLevel? experienceLevel,
    String? workMode,
    String? companySize,
    bool clearJobType = false,
    bool clearExperience = false,
  }) {
    return JobFilterModel(
      keyword: keyword ?? this.keyword,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      experienceLevel:
          clearExperience ? null : (experienceLevel ?? this.experienceLevel),
      workMode: workMode ?? this.workMode,
      companySize: companySize ?? this.companySize,
    );
  }
}
