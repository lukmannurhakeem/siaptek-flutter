import 'package:flutter/material.dart';

class ReportingTab extends StatelessWidget {
  final String jobId;

  const ReportingTab({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text('Job Progress for Job: $jobId'),
          const SizedBox(height: 8),
          const Text('Add progress tracking here'),
        ],
      ),
    );
  }
}
