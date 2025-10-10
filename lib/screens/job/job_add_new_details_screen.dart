import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_date_picker_input.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JobAddNewDetailsScreen extends StatefulWidget {
  final String customer;
  final String site;

  const JobAddNewDetailsScreen({required this.customer, required this.site, super.key});

  @override
  State<JobAddNewDetailsScreen> createState() => _JobAddNewDetailsScreenState();
}

class _JobAddNewDetailsScreenState extends State<JobAddNewDetailsScreen>
    with TickerProviderStateMixin {
  // Text controllers for form fields
  late TextEditingController jobNoController;
  late TextEditingController createdDateController;
  late TextEditingController poController;
  late TextEditingController procedureController;
  late TextEditingController notesController;
  late TextEditingController divisionController;
  late TextEditingController addressController;
  late TextEditingController allocatedDurationController;
  late TextEditingController estInspectionDurationController;
  late TextEditingController estStartDateController;
  late TextEditingController estEndDateController;
  late TextEditingController engineerCompleteController;
  late TextEditingController offshoreLocationController;
  late TextEditingController authenticatorController;
  late TextEditingController issuingAuthNameController;
  late TextEditingController clientNameController;
  late TextEditingController issuingAuthNameSignatureController;
  late TextEditingController clientSignatureController;

  PlatformFile? _issuingAuthSignatureFile;
  PlatformFile? _clientSignatureFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    jobNoController = TextEditingController();
    createdDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    poController = TextEditingController();
    procedureController = TextEditingController();
    notesController = TextEditingController();
    divisionController = TextEditingController();
    addressController = TextEditingController();
    allocatedDurationController = TextEditingController();
    estInspectionDurationController = TextEditingController();
    estStartDateController = TextEditingController();
    estEndDateController = TextEditingController();
    engineerCompleteController = TextEditingController();
    offshoreLocationController = TextEditingController();
    authenticatorController = TextEditingController();
    issuingAuthNameController = TextEditingController();
    clientNameController = TextEditingController();
    issuingAuthNameSignatureController = TextEditingController();
    clientSignatureController = TextEditingController();
  }

  @override
  void dispose() {
    jobNoController.dispose();
    createdDateController.dispose();
    poController.dispose();
    procedureController.dispose();
    notesController.dispose();
    divisionController.dispose();
    addressController.dispose();
    allocatedDurationController.dispose();
    estInspectionDurationController.dispose();
    estStartDateController.dispose();
    estEndDateController.dispose();
    engineerCompleteController.dispose();
    offshoreLocationController.dispose();
    authenticatorController.dispose();
    issuingAuthNameController.dispose();
    clientNameController.dispose();
    issuingAuthNameSignatureController.dispose();
    clientSignatureController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Replace the _createJob method in JobAddNewDetailsScreen with this fixed version

  Future<void> _createJob() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build job data payload matching API requirements exactly
      final jobData = {
        'customerid': widget.customer, // Lowercase as per API
        'jobno': jobNoController.text, // Lowercase as per API
        'siteID': widget.site, // Keep as siteID (mixed case)
        'createdDate': _formatDateToIso(createdDateController.text),
        'purchaseOrderNo': poController.text,
        'procedureNo': procedureController.text,
        'notes': notesController.text,
        'divisionID': divisionController.text, // Keep as divisionID (mixed case)
        'address': addressController.text,
        'allocatedDuration': int.tryParse(allocatedDurationController.text) ?? 0,
        'estimatedInspectionDuration': int.tryParse(estInspectionDurationController.text) ?? 0,
        'estimatedStartDate': _formatDateToIso(estStartDateController.text),
        'estimatedEndDate': _formatDateToIso(estEndDateController.text),
        'isEngineerComplete': engineerCompleteController.text.toLowerCase() == 'yes',
        'offshoreLocation': offshoreLocationController.text,
        'authenticator': authenticatorController.text,
        'issuingAuthName': issuingAuthNameController.text,
        'issuingAuthSignature': _issuingAuthSignatureFile?.name ?? '',
        'clientName': clientNameController.text,
        'clientSignature': _clientSignatureFile?.name ?? '',
        'startJobNow': true,
      };

      // Validate critical fields
      if (jobData['customerid'] == null || jobData['customerid'].toString().isEmpty) {
        _showError('Customer ID is missing');
        return;
      }

      if (jobData['siteID'] == null || jobData['siteID'].toString().isEmpty) {
        _showError('Site ID is missing');
        return;
      }

      if (jobData['jobno'] == null || jobData['jobno'].toString().isEmpty) {
        _showError('Job No is required');
        return;
      }

      print('Sending job data: $jobData'); // Debug log

      // Call provider to create job
      if (mounted) {
        await Provider.of<JobProvider>(
          context,
          listen: false,
        ).createJobFromDetails(context, jobData);
      }
    } catch (e, stackTrace) {
      print('Error creating job: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating job: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format date to ISO 8601 with Z suffix (matches API requirement)
  String _formatDateToIso(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      // Return in ISO 8601 format with Z suffix as required by API
      return '${date.toIso8601String()}Z';
    } catch (e) {
      print('Date format error: $e');
      return '';
    }
  }

  // Update _validateForm with more specific checks
  bool _validateForm() {
    if (jobNoController.text.trim().isEmpty) {
      _showError('Job No is required');
      return false;
    }

    if (estStartDateController.text.trim().isEmpty) {
      _showError('Estimated Start Date is required');
      return false;
    }

    if (estEndDateController.text.trim().isEmpty) {
      _showError('Estimated End Date is required');
      return false;
    }

    // Validate date format
    try {
      final startDate = DateFormat('yyyy-MM-dd').parse(estStartDateController.text);
      final endDate = DateFormat('yyyy-MM-dd').parse(estEndDateController.text);

      if (endDate.isBefore(startDate)) {
        _showError('End date must be after start date');
        return false;
      }
    } catch (e) {
      _showError('Invalid date format');
      return false;
    }

    return true;
  }

  // Enhanced error display
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: CommonDatePickerInput(label: '', controller: controller)),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title, {
    TextEditingController? controller,
    bool isRequired = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title + (isRequired ? '*' : ''),
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: CommonTextField(controller: controller)),
      ],
    );
  }

  Widget _buildFileUploadRow(
    BuildContext context,
    String label,
    PlatformFile? pickedFile,
    Function() onPickFile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: onPickFile,
                icon: Icon(Icons.upload_file, color: context.colors.primary),
                label: Text(
                  "Choose File",
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (pickedFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${pickedFile.name}',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickIssuingAuthSignature() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _issuingAuthSignatureFile = result.files.first;
        issuingAuthNameSignatureController.text = result.files.first.name;
      });
    }
  }

  Future<void> _pickClientSignature() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _clientSignatureFile = result.files.first;
        clientSignatureController.text = result.files.first.name;
      });
    }
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(context, 'Job No', controller: jobNoController, isRequired: true),
                        context.vS,
                        _buildRow(context, 'Created Date', controller: createdDateController),
                        context.vS,
                        _buildRow(context, 'Purchase Order No', controller: poController),
                        context.vS,
                        _buildRow(context, 'Procedure No', controller: procedureController),
                        context.vS,
                        _buildRow(context, 'Notes', controller: notesController),
                        context.vS,
                        _buildRow(context, 'Division Name', controller: divisionController),
                        context.vS,
                        _buildRow(context, 'Address', controller: addressController),
                        context.vS,
                        _buildRow(
                          context,
                          'Allocated Duration',
                          controller: allocatedDurationController,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
                context.hXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          context,
                          'Est. Inspection Duration',
                          controller: estInspectionDurationController,
                        ),
                        context.vS,
                        _buildDateField(context, 'Est. Start Date', estStartDateController),
                        context.vS,
                        _buildDateField(context, 'Est. End Date', estEndDateController),
                        context.vS,
                        _buildRow(
                          context,
                          'Engineer Complete',
                          controller: engineerCompleteController,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Offshore Location',
                          controller: offshoreLocationController,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Issuing Auth Name',
                          controller: issuingAuthNameController,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Issuing Auth Name Signature',
                          controller: issuingAuthNameSignatureController,
                        ),
                        context.vS,
                        _buildFileUploadRow(
                          context,
                          'Upload Issuing Auth Signature',
                          _issuingAuthSignatureFile,
                          _pickIssuingAuthSignature,
                        ),
                        context.vS,
                        _buildRow(context, 'Client Name', controller: clientNameController),
                        context.vS,
                        _buildRow(
                          context,
                          'Client Signature',
                          controller: clientSignatureController,
                        ),
                        context.vS,
                        _buildFileUploadRow(
                          context,
                          'Upload Client Signature',
                          _clientSignatureFile,
                          _pickClientSignature,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Creating...' : 'Create',
            onPressed: _isLoading ? null : _createJob,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          _buildRow(context, 'Job No', controller: jobNoController, isRequired: true),
          context.vS,
          _buildRow(context, 'Created Date', controller: createdDateController),
          context.vS,
          _buildRow(context, 'Purchase Order No', controller: poController),
          context.vS,
          _buildRow(context, 'Procedure No', controller: procedureController),
          context.vS,
          _buildRow(context, 'Notes', controller: notesController),
          context.vS,
          _buildRow(context, 'Division Name', controller: divisionController),
          context.vS,
          _buildRow(context, 'Address', controller: addressController),
          context.vS,
          _buildRow(context, 'Allocated Duration', controller: allocatedDurationController),
          context.vS,
          _buildRow(
            context,
            'Est. Inspection Duration',
            controller: estInspectionDurationController,
          ),
          context.vS,
          _buildDateField(context, 'Est. Start Date', estStartDateController),
          context.vS,
          _buildDateField(context, 'Est. End Date', estEndDateController),
          context.vS,
          _buildRow(context, 'Engineer Complete', controller: engineerCompleteController),
          context.vS,
          _buildRow(context, 'Offshore Location', controller: offshoreLocationController),
          context.vS,
          _buildRow(context, 'Authenticator', controller: authenticatorController),
          context.vS,
          _buildRow(context, 'Issuing Auth Name', controller: issuingAuthNameController),
          context.vS,
          _buildRow(
            context,
            'Issuing Auth Name Signature',
            controller: issuingAuthNameSignatureController,
          ),
          context.vS,
          _buildFileUploadRow(
            context,
            'Upload Issuing Auth Signature',
            _issuingAuthSignatureFile,
            _pickIssuingAuthSignature,
          ),
          context.vS,
          _buildRow(context, 'Client Name', controller: clientNameController),
          context.vS,
          _buildRow(context, 'Client Signature', controller: clientSignatureController),
          context.vS,
          _buildFileUploadRow(
            context,
            'Upload Client Signature',
            _clientSignatureFile,
            _pickClientSignature,
          ),
          context.vS,
          CommonButton(
            text: _isLoading ? 'Creating...' : 'Create',
            onPressed: _isLoading ? null : _createJob,
          ),
          context.vL,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Details',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context)),
    );
  }
}
