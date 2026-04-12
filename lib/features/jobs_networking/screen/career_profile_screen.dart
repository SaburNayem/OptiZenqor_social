import 'package:flutter/material.dart';

import '../model/job_model.dart';

class CareerProfileScreen extends StatelessWidget {
  const CareerProfileScreen({
    required this.profile,
    super.key,
  });

  final CareerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Career profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.person_rounded, size: 34)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(profile.title),
                    const SizedBox(height: 4),
                    Text(profile.availability, style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _section('Skills', profile.skills.join(', ')),
          _section('Experience', profile.experience.join('\n')),
          _section('Education', profile.education.join('\n')),
          _section('Resume upload', profile.resumeLabel),
          _section('Portfolio links', profile.portfolioLinks.join('\n')),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Resume builder')),
              Chip(label: Text('Skill endorsements')),
              Chip(label: Text('Open to work')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
