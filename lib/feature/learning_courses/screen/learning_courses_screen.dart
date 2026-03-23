import 'package:flutter/material.dart';

import '../controller/learning_courses_controller.dart';

class LearningCoursesScreen extends StatelessWidget {
  LearningCoursesScreen({super.key}) {
    _controller.load();
  }

  final LearningCoursesController _controller = LearningCoursesController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Courses')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: _controller.courses
              .map(
                (course) => Card(
                  child: ListTile(
                    title: Text(course.title),
                    subtitle: Text(
                      'Lessons: ${course.lessons.length} • '
                      'Progress ${(course.progress * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
