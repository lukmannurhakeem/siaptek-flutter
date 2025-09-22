import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/screens/job/job_item_details/item_files_screen.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ReportTypeScreen extends StatefulWidget {
  const ReportTypeScreen({super.key});

  @override
  State<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends State<ReportTypeScreen> with TickerProviderStateMixin {
  List<FileItem> _files = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchReportType();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        // Show snackbars after frame is built
        if (provider.hasData && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonSnackbar.showSuccess(context, "Successfully loaded report");
          });
        }

        if (provider.hasError && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonSnackbar.showError(context, provider.errorMessage!);
          });
        }

        // Loading state
        if (provider.isLoading && !provider.hasReport) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading report...'),
              ],
            ),
          );
        }

        // Error state
        if (provider.hasError && !provider.hasReport) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Failed to load report', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchReportType(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (!provider.hasReport || provider.getReportTypeModel?.data?.isEmpty == true) {
          return SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - kToolbarHeight * 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/no-file.svg',
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 16),
                Text(
                  'No report found',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vM,
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          text: 'Create',
                          icon: Icons.add,
                          onPressed: () {
                            NavigationService().navigateTo(AppRoutes.reportCreate);
                          },
                        ),
                      ),
                      context.hM,
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickAndUploadFiles,
                          icon: const Icon(Icons.add),
                          label: const Text('Choose Files'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Main content with data
        return Column(
          children: [
            // Header with Create button
            Container(
              padding: const EdgeInsets.only(right: 30),
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 150,
                      child: CommonButton(
                        onPressed: () {
                          NavigationService().navigateTo(AppRoutes.reportCreate);
                        },
                        iconSize: 15,
                        icon: Icons.add,
                        text: 'Create',
                      ),
                    ),
                    context.hM,
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: _pickAndUploadFiles,
                        icon: const Icon(Icons.add),
                        label: const Text('Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data table
            Expanded(
              child:
                  context.isTablet
                      ? _buildTabletView(context, provider)
                      : _buildMobileView(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletView(BuildContext context, SystemProvider provider) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32, // Account for padding
        ),
        child: DataTable(
          showCheckboxColumn: false,
          columns: _buildDataColumns(context),
          rows: _buildDataRows(context, provider),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, SystemProvider provider) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _buildDataColumns(context),
          rows: _buildDataRows(context, provider),
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns(BuildContext context) {
    return [
      DataColumn(
        label: Expanded(
          child: Text(
            'Name',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Description',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Categories',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Document Code',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Revision No',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Archived',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildDataRows(BuildContext context, SystemProvider provider) {
    return List.generate(provider.getReportTypeModel!.data!.length, (index) {
      final data = provider.getReportTypeModel!.data![index].reportType;
      final isEven = index % 2 == 0;

      return DataRow(
        onSelectChanged: (selected) {
          if (selected == true) {
            // Navigate to Edit Report Template screen
            NavigationService().navigateTo(
              AppRoutes.reportTypeDetails,
              arguments: {'reportTypeID': data?.categoryId},
            );
          }
        },
        color: MaterialStateProperty.resolveWith<Color?>((states) {
          return isEven ? context.colors.primary.withOpacity(0.05) : null;
        }),
        cells: [
          DataCell(
            Text(
              data?.reportName ?? '-',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
          DataCell(
            Text(
              data?.description ?? '-',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
          DataCell(
            Text(
              data?.categoryId ?? '-',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
          DataCell(
            Text(
              data?.documentCode ?? '-',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
          DataCell(
            Text(
              data?.competencyId ?? '-',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
          DataCell(
            Text(
              data?.archived == true ? 'Archived' : 'Active',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      );
    });
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
}
