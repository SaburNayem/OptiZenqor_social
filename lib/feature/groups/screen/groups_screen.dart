import 'package:flutter/material.dart';

import '../../communities/screen/communities_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunitiesScreen(
      showJoinedFirst: true,
      title: 'Groups',
    );
  }
}
