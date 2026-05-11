import 'package:flutter/material.dart';

import '../controller/learning_courses_controller.dart';

class LearningCoursesScreen extends StatefulWidget {
  const LearningCoursesScreen({super.key});

  @override
  State<LearningCoursesScreen> createState() => _LearningCoursesScreenState();
}

class _LearningCoursesScreenState extends State<LearningCoursesScreen> {
  late final LearningCoursesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LearningCoursesController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Courses')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          if (_controller.isLoading && _controller.courses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if ((_controller.errorMessage ?? '').isNotEmpty &&
              _controller.courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 120),
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
                ],
              ),
            );
          }
          if (_controller.courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: SizedBox(
                      height: 240,
                      child: Center(
                        child: Text(
                          'No learning courses are available from the backend yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: _controller.courses
                  .map(
                    (course) => Card(
                      child: ListTile(
                        title: Text(course.title),
                        subtitle: Text(
                          [
                            'Lessons: ${course.lessons.length}',
                            'Progress ${(course.progress * 100).toStringAsFixed(0)}%',
                            if (course.instructor.trim().isNotEmpty)
                              'Instructor: ${course.instructor}',
                            if (course.saved) 'Saved course',
                            if (course.certificateSummary.trim().isNotEmpty)
                              course.certificateSummary,
                            if (course.quizSummary.trim().isNotEmpty)
                              course.quizSummary,
                          ].join('\n'),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        },
      ),
    );
  }
}
