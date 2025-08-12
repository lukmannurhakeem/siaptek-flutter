import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

Future<void> exportCSV(String csvContent, BuildContext context) async {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor =
      html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'job_register_${DateTime.now().millisecondsSinceEpoch}.csv';

  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('CSV file downloaded successfully!'),
      backgroundColor: Colors.green,
    ),
  );
}
