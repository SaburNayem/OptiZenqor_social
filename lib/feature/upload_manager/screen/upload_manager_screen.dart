import 'package:flutter/material.dart';

import '../controller/upload_manager_controller.dart';
import '../model/upload_task_model.dart';

class UploadManagerScreen extends StatelessWidget {
  UploadManagerScreen({super.key});

  final UploadManagerController _controller = UploadManagerController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Upload Manager')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                )
              : _controller.tasks.isEmpty
              ? const Center(child: Text('No uploads found from the backend.'))
              : ListView.builder(
                  itemCount: _controller.tasks.length,
                  itemBuilder: (context, index) {
                    final task = _controller.tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: task.progress),
                            const SizedBox(height: 6),
                            Text(task.status.name),
                          ],
                        ),
                        trailing: task.status == UploadStatus.failed
                            ? IconButton(
                                onPressed: () => _controller.retry(task.id),
                                icon: const Icon(Icons.refresh),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
