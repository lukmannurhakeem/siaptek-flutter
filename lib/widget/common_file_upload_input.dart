import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CommonFileUploadInput extends StatefulWidget {
  const CommonFileUploadInput({super.key});

  @override
  State<CommonFileUploadInput> createState() => _CommonFileUploadInputState();
}

class _CommonFileUploadInputState extends State<CommonFileUploadInput> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: Icon(Icons.upload_file, color: context.colors.primary),
          label: Text(
            "Choose File",
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        if (_pickedFile != null)
          Text(
            'Selected File: ${_pickedFile!.name}',
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
      ],
    );
  }
}
