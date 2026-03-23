import 'package:flutter/foundation.dart';

import '../model/course_model.dart';
import '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repimport '../repository/learnimport '../repository/learnimport '../repository/learnimport 'Eimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repository/learnimport '../repositorycaffold(
      appBar: AppBar(title: const Text('Learning Courses')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: _controller.courses.map((c) => Card(child: ListTile(title: Text(c.title), subtitle: Text('Lessons: ${c.lessons.length} • Progress ${(c.progress * 100).toStringAsFixed(0)}%')))).toList(),
        ),
      ),
    );
  }
}
