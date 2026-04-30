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
        builder: (_, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if ((_controller.errorMessage ?? '').isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _controller.load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_controller.courses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No learning courses are available from the backend yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: _controller.courses
                .map(
                  (course) => Card(
                    child: ListTile(
                      title: Text(course.title),
                      subtitle: Text(
                        'Lessons: ${course.lessons.length} | '
                        'Progress ${(course.progress * 100).toStringAsFixed(0)}%\n'
                        'Instructor: ${course.instructor}\n'
                        'Saved courses | ${course.certificateSummary} | ${course.quizSummary}',
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
