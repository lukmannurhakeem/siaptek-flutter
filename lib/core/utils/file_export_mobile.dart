import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> exportCSV(String csvContent, BuildContext context) async {
  try {
    // Request storage permission
    bool hasPermission = false;

    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we don't need storage permission for Downloads
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        hasPermission = true;
      } else {
        // Try without permission for newer Android versions
        hasPermission = true;
      }
    } else if (Platform.isIOS) {
      hasPermission = true; // iOS doesn't need explicit storage permission
    }

    if (hasPermission) {
      Directory? directory;

      if (Platform.isAndroid) {
        // Try to get the Downloads directory
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              directory = Directory('${directory.path}/Download');
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
            }
          }
        } catch (e) {
          // Fallback to external storage directory
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final fileName = 'job_register_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');

        await file.writeAsString(csvContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved to: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                // You can add functionality to open file manager here
              },
            ),
          ),
        );
      } else {
        throw Exception('Could not access storage directory');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save the file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error saving file: $e'), backgroundColor: Colors.red));
  }
}
