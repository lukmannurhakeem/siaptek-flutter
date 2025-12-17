import 'package:flutter/material.dart';

class FilesTab extends StatelessWidget {
  final String jobId;

  const FilesTab({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text('Files for Job: $jobId'),
          const SizedBox(height: 8),
          const Text('Add file management here'),
        ],
      ),
    );
  }
}
