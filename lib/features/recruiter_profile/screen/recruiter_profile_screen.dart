import 'package:flutter/material.dart';

import '../controller/recruiter_profile_controller.dart';

class RecruiterProfileScreen extends StatelessWidget {
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RecruiterProfileController();

    return Scaffold(
      appBar: AppBar(title: const Text('Recruiter Profile')),
      body: ListTile(
        title: Text(controller.profile.company),
        subtitle: Text('${controller.profile.openRoles} open roles'),
      ),
    );
  }
}
