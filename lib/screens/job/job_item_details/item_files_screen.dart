import 'package:base_app/core/extension/theme_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileItem {
  final String name;
  final String path;
  final DateTime dateAdded;
  final int size;

  FileItem({required this.name, required this.path, required this.dateAdded, required this.size});
}

class ItemFilesScreen extends StatefulWidget {
  const ItemFilesScreen({super.key});

  @override
  State<ItemFilesScreen> createState() => _ItemFilesScreenState();
}

class _ItemFilesScreenState extends State<ItemFilesScreen> {
  List<FileItem> _files = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildUploadSection(context),
        const SizedBox(height: 24),
        _buildFilesSection(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildUploadSection(context),
        const SizedBox(height: 24),
        _buildFilesSection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Item Files',
      style: context.topology.textTheme.titleMedium?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: context.colors.primary.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: context.colors.primary),
          const SizedBox(height: 8),
          Text(
            'Upload Files',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select files to upload for this item',
            style: context.topology.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _isUploading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                onPressed: _pickAndUploadFiles,
                icon: const Icon(Icons.add),
                label: const Text('Choose Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFilesSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Files (${_files.length})',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
              if (_files.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearAllFiles,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: _files.isEmpty ? _buildEmptyState(context) : _buildFilesList(context)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: context.colors.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No files uploaded yet',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload files to see them listed here',
            style: context.topology.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(BuildContext context) {
    return ListView.separated(
      itemCount: _files.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final file = _files[index];
        return _buildFileListItem(context, file, index);
      },
    );
  }

  Widget _buildFileListItem(BuildContext context, FileItem file, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: context.colors.primary.withOpacity(0.1),
        child: Icon(_getFileIcon(file.name), color: context.colors.primary, size: 20),
      ),
      title: Text(
        file.name,
        style: context.topology.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatFileSize(file.size)} • ${_formatDate(file.dateAdded)}',
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _viewFile(file),
            icon: const Icon(Icons.visibility),
            tooltip: 'View File',
          ),
          IconButton(
            onPressed: () => _downloadFile(file),
            icon: const Icon(Icons.download),
            tooltip: 'Download File',
          ),
          IconButton(
            onPressed: () => _deleteFile(index),
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: 'Delete File',
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          if (file.path != null) {
            final fileItem = FileItem(
              name: file.name,
              path: file.path!,
              dateAdded: DateTime.now(),
              size: file.size,
            );

            setState(() {
              _files.add(fileItem);
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded ${result.files.length} file(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading files: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _viewFile(FileItem file) {
    // Implement file viewing logic here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing ${file.name}')));
  }

  void _downloadFile(FileItem file) {
    // Implement file download logic here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${file.name}')));
  }

  void _deleteFile(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete File'),
            content: Text('Are you sure you want to delete "${_files[index].name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  setState(() {
                    _files.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File deleted successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  void _clearAllFiles() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Files'),
            content: const Text('Are you sure you want to delete all files?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  setState(() {
                    _files.clear();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All files cleared successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}
