import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfData;
  final String reportName;

  const PdfViewerScreen({Key? key, required this.pdfData, this.reportName = 'Report'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    return Scaffold(
      appBar: AppBar(
        title: Text(reportName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              final anchor =
                  html.AnchorElement(href: url)
                    ..download = '$reportName.pdf'
                    ..click();
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => html.window.open(url, '_blank'),
          child: const Text('Open PDF'),
        ),
      ),
    );
  }
}
