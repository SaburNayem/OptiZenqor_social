import 'package:flutter/material.dart';

import '../model/job_model.dart';

class JobApplicationFlowScreen extends StatefulWidget {
  const JobApplicationFlowScreen({
    required this.job,
    required this.onSubmit,
    super.key,
  });

  final JobModel job;
  final void Function(String coverLetter, String portfolioLink) onSubmit;

  @override
  State<JobApplicationFlowScreen> createState() => _JobApplicationFlowScreenState();
}

class _JobApplicationFlowScreenState extends State<JobApplicationFlowScreen> {
  int _step = 0;
  String _resume = 'Primary resume';
  final TextEditingController _coverLetter = TextEditingController();
  final TextEditingController _portfolio = TextEditingController();

  @override
  void dispose() {
    _coverLetter.dispose();
    _portfolio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply job')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step == 3) {
            widget.onSubmit(_coverLetter.text.trim(), _portfolio.text.trim());
            Navigator.of(context).pop();
            return;
          }
          setState(() => _step += 1);
        },
        onStepCancel: () {
          if (_step == 0) {
            Navigator.of(context).pop();
            return;
          }
          setState(() => _step -= 1);
        },
        steps: [
          Step(
            title: const Text('Select resume'),
            isActive: _step >= 0,
            content: DropdownButtonFormField<String>(
              value: _resume,
              items: const [
                DropdownMenuItem(value: 'Primary resume', child: Text('Primary resume')),
                DropdownMenuItem(value: 'Product resume', child: Text('Product resume')),
                DropdownMenuItem(value: 'Design resume', child: Text('Design resume')),
              ],
              onChanged: (value) => setState(() => _resume = value ?? _resume),
            ),
          ),
          Step(
            title: const Text('Add cover letter'),
            isActive: _step >= 1,
            content: TextField(
              controller: _coverLetter,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tell the employer why you are a fit',
              ),
            ),
          ),
          Step(
            title: const Text('Add portfolio link'),
            isActive: _step >= 2,
            content: TextField(
              controller: _portfolio,
              decoration: const InputDecoration(
                hintText: 'https://portfolio.example.com',
              ),
            ),
          ),
          Step(
            title: const Text('Submit application'),
            isActive: _step >= 3,
            content: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.job.title),
              subtitle: Text('${widget.job.company} • $_resume'),
            ),
          ),
        ],
      ),
    );
  }
}
