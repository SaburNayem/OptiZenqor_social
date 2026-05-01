import '../../../core/data/api/api_payload_reader.dart';

enum JobType {
  remote,
  fullTime,
  partTime,
  freelance,
  internship,
  contract,
  hybrid,
  onsite,
}

enum ExperienceLevel { entry, mid, senior, lead }

enum ApplicationStatus { pending, viewed, shortlisted, rejected }

enum AlertFrequency { instant, daily, weekly }

enum JobsUserRole { seeker, provider }

class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.experienceLevel,
    required this.postedTime,
    required this.logoInitial,
    required this.logoColorValue,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.skills,
    required this.benefits,
    required this.aboutCompany,
    required this.quickApplyEnabled,
    required this.verifiedEmployer,
    this.saved = false,
    this.applied = false,
    this.featured = false,
    this.remoteFriendly = false,
    this.draft = false,
    this.closed = false,
    this.externalApplyEnabled = false,
    this.contactLink,
    this.deadlineLabel,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final JobType type;
  final ExperienceLevel experienceLevel;
  final String postedTime;
  final String logoInitial;
  final int logoColorValue;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> skills;
  final List<String> benefits;
  final String aboutCompany;
  final bool quickApplyEnabled;
  final bool verifiedEmployer;
  final bool saved;
  final bool applied;
  final bool featured;
  final bool remoteFriendly;
  final bool draft;
  final bool closed;
  final bool externalApplyEnabled;
  final String? contactLink;
  final String? deadlineLabel;

  factory JobModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? company = ApiPayloadReader.readMap(
      json['company'],
    );
    final String companyName = ApiPayloadReader.readString(
      json['companyName'] ?? json['company'] ?? company?['name'],
      fallback: 'Unknown company',
    );
    final String title = ApiPayloadReader.readString(
      json['title'],
      fallback: 'Job opportunity',
    );
    final String location = ApiPayloadReader.readString(
      json['location'],
      fallback: 'Remote',
    );

    return JobModel(
      id: ApiPayloadReader.readString(json['id']),
      title: title,
      company: companyName,
      location: location,
      salary: ApiPayloadReader.readString(
        json['salary'] ?? json['salaryLabel'],
      ),
      type: _jobTypeFromValue(json['type'] ?? json['jobType']),
      experienceLevel: _experienceLevelFromValue(
        json['experienceLevel'] ?? json['level'],
      ),
      postedTime: ApiPayloadReader.readString(
        json['postedTime'] ?? json['createdAt'],
        fallback: 'Recently posted',
      ),
      logoInitial: companyName.isEmpty ? 'J' : companyName.substring(0, 1),
      logoColorValue: ApiPayloadReader.readInt(
        json['logoColorValue'] ?? company?['logoColorValue'],
      ),
      description: ApiPayloadReader.readString(json['description']),
      responsibilities: ApiPayloadReader.readStringList(
        json['responsibilities'],
      ),
      requirements: ApiPayloadReader.readStringList(json['requirements']),
      skills: ApiPayloadReader.readStringList(json['skills']),
      benefits: ApiPayloadReader.readStringList(json['benefits']),
      aboutCompany: ApiPayloadReader.readString(
        json['aboutCompany'] ?? company?['about'],
      ),
      quickApplyEnabled:
          ApiPayloadReader.readBool(json['quickApplyEnabled']) ?? true,
      verifiedEmployer:
          ApiPayloadReader.readBool(
            json['verifiedEmployer'] ?? company?['verified'],
          ) ??
          false,
      saved: ApiPayloadReader.readBool(json['saved']) ?? false,
      applied: ApiPayloadReader.readBool(json['applied']) ?? false,
      featured: ApiPayloadReader.readBool(json['featured']) ?? false,
      remoteFriendly:
          ApiPayloadReader.readBool(json['remoteFriendly']) ??
          location.toLowerCase().contains('remote'),
      draft: ApiPayloadReader.readBool(json['draft']) ?? false,
      closed: ApiPayloadReader.readBool(json['closed']) ?? false,
      externalApplyEnabled:
          ApiPayloadReader.readBool(json['externalApplyEnabled']) ?? false,
      contactLink: ApiPayloadReader.readString(
        json['contactLink'] ?? json['applyUrl'],
      ),
      deadlineLabel: ApiPayloadReader.readString(json['deadlineLabel']),
    );
  }

  JobModel copyWith({
    bool? saved,
    bool? applied,
    bool? closed,
    bool? draft,
    String? title,
    String? company,
    String? location,
    String? salary,
    JobType? type,
    ExperienceLevel? experienceLevel,
    String? description,
    List<String>? responsibilities,
    List<String>? requirements,
    List<String>? skills,
    List<String>? benefits,
    bool? quickApplyEnabled,
    bool? externalApplyEnabled,
    String? contactLink,
    String? deadlineLabel,
  }) {
    return JobModel(
      id: id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      type: type ?? this.type,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      postedTime: postedTime,
      logoInitial: logoInitial,
      logoColorValue: logoColorValue,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      benefits: benefits ?? this.benefits,
      aboutCompany: aboutCompany,
      quickApplyEnabled: quickApplyEnabled ?? this.quickApplyEnabled,
      verifiedEmployer: verifiedEmployer,
      saved: saved ?? this.saved,
      applied: applied ?? this.applied,
      featured: featured,
      remoteFriendly: remoteFriendly,
      draft: draft ?? this.draft,
      closed: closed ?? this.closed,
      externalApplyEnabled: externalApplyEnabled ?? this.externalApplyEnabled,
      contactLink: contactLink ?? this.contactLink,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
    );
  }

  static JobType _jobTypeFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'remote':
        return JobType.remote;
      case 'part_time':
      case 'parttime':
      case 'part-time':
        return JobType.partTime;
      case 'freelance':
        return JobType.freelance;
      case 'internship':
        return JobType.internship;
      case 'contract':
        return JobType.contract;
      case 'hybrid':
        return JobType.hybrid;
      case 'onsite':
      case 'on_site':
      case 'on-site':
        return JobType.onsite;
      case 'full_time':
      case 'fulltime':
      case 'full-time':
      default:
        return JobType.fullTime;
    }
  }

  static ExperienceLevel _experienceLevelFromValue(Object? value) {
    switch ((value?.toString() ?? '').trim().toLowerCase()) {
      case 'entry':
      case 'junior':
        return ExperienceLevel.entry;
      case 'senior':
        return ExperienceLevel.senior;
      case 'lead':
        return ExperienceLevel.lead;
      case 'mid':
      default:
        return ExperienceLevel.mid;
    }
  }
}

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logoInitial,
    required this.colorValue,
    required this.followers,
    this.followed = false,
    this.verified = false,
  });

  final String id;
  final String name;
  final String tagline;
  final String logoInitial;
  final int colorValue;
  final int followers;
  final bool followed;
  final bool verified;

  CompanyModel copyWith({bool? followed}) {
    return CompanyModel(
      id: id,
      name: name,
      tagline: tagline,
      logoInitial: logoInitial,
      colorValue: colorValue,
      followers: followers,
      followed: followed ?? this.followed,
      verified: verified,
    );
  }
}

class JobAlertModel {
  const JobAlertModel({
    required this.id,
    required this.keyword,
    required this.location,
    required this.frequency,
    this.enabled = true,
  });

  final String id;
  final String keyword;
  final String location;
  final AlertFrequency frequency;
  final bool enabled;

  JobAlertModel copyWith({
    String? keyword,
    String? location,
    AlertFrequency? frequency,
    bool? enabled,
  }) {
    return JobAlertModel(
      id: id,
      keyword: keyword ?? this.keyword,
      location: location ?? this.location,
      frequency: frequency ?? this.frequency,
      enabled: enabled ?? this.enabled,
    );
  }
}

class CareerProfileModel {
  const CareerProfileModel({
    required this.name,
    required this.title,
    required this.skills,
    required this.experience,
    required this.education,
    required this.resumeLabel,
    required this.portfolioLinks,
    required this.availability,
  });

  final String name;
  final String title;
  final List<String> skills;
  final List<String> experience;
  final List<String> education;
  final String resumeLabel;
  final List<String> portfolioLinks;
  final String availability;

  factory CareerProfileModel.fromApiJson(Map<String, dynamic> json) {
    return CareerProfileModel(
      name: ApiPayloadReader.readString(
        json['name'],
        fallback: 'Professional profile',
      ),
      title: ApiPayloadReader.readString(json['title']),
      skills: ApiPayloadReader.readStringList(json['skills']),
      experience: ApiPayloadReader.readStringList(json['experience']),
      education: ApiPayloadReader.readStringList(json['education']),
      resumeLabel: ApiPayloadReader.readString(
        json['resumeLabel'],
        fallback: 'Primary resume',
      ),
      portfolioLinks: ApiPayloadReader.readStringList(json['portfolioLinks']),
      availability: ApiPayloadReader.readString(
        json['availability'],
        fallback: 'Open to work',
      ),
    );
  }
}

class EmployerStatsModel {
  const EmployerStatsModel({
    required this.totalJobs,
    required this.totalApplicants,
    required this.shortlistedCandidates,
    required this.messages,
  });

  final int totalJobs;
  final int totalApplicants;
  final int shortlistedCandidates;
  final int messages;
}

class EmployerProfileModel {
  const EmployerProfileModel({
    required this.companyName,
    required this.hiringTitle,
    required this.about,
    required this.hiringFocus,
    required this.location,
    required this.openRoles,
    required this.teamHighlights,
  });

  final String companyName;
  final String hiringTitle;
  final String about;
  final String location;
  final List<String> hiringFocus;
  final List<String> openRoles;
  final List<String> teamHighlights;
}
