import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_date_picker_input.dart';
import 'package:base_app/widget/common_dropdown.dart';
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
  // Division selection
  String? selectedDivisionId;

  // Authenticator selection (personnelID)
  String? selectedAuthenticatorId;

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

    // Fetch divisions and personnel when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);
      if (systemProvider.divisions.isEmpty) {
        systemProvider.fetchDivision();
      }

      final personnelProvider = Provider.of<PersonnelProvider>(context, listen: false);
      if (personnelProvider.personnelList.isEmpty) {
        personnelProvider.fetchPersonnel();
      }
    });
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

  Future<void> _createJob() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobData = {
        'customerid': widget.customer,
        'jobno': jobNoController.text,
        'siteID': widget.site,
        'createdDate': _formatDateToIso(createdDateController.text),
        'purchaseOrderNo': poController.text,
        'procedureNo': procedureController.text,
        'notes': notesController.text,
        'divisionID': divisionController.text,
        'address': addressController.text,
        'allocatedDuration': int.tryParse(allocatedDurationController.text) ?? 0,
        'estimatedInspectionDuration': int.tryParse(estInspectionDurationController.text) ?? 0,
        'estimatedStartDate': _formatDateToIso(estStartDateController.text),
        'estimatedEndDate': _formatDateToIso(estEndDateController.text),
        'isEngineerComplete': engineerCompleteController.text.toLowerCase() == 'yes',
        'offshoreLocation': offshoreLocationController.text,
        'authenticator': selectedAuthenticatorId ?? '', // Use personnelID instead
        'issuingAuthName': issuingAuthNameController.text,
        'issuingAuthSignature': _issuingAuthSignatureFile?.name ?? '',
        'clientName': clientNameController.text,
        'clientSignature': _clientSignatureFile?.name ?? '',
        'startJobNow': true,
      };

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
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error creating job: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  String _formatDateToIso(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return '${date.toIso8601String()}Z';
    } catch (e) {
      print('Date format error: $e');
      return '';
    }
  }

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
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
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title + (isRequired ? ' *' : ''),
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionDropdown(BuildContext context, {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  'Division Name',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Consumer<SystemProvider>(
            builder: (context, systemProvider, child) {
              if (systemProvider.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return CommonDropdown<String>(
                value: selectedDivisionId,
                items:
                    systemProvider.divisions.map((division) {
                      return DropdownMenuItem<String>(
                        value: division.divisionid,
                        child: Text(
                          division.divisionname ?? 'Unknown',
                          style: context.topology.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDivisionId = value;
                    divisionController.text = value ?? '';
                  });
                },
                borderColor: context.colors.primary,
                textStyle: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatorDropdown(BuildContext context, {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  'Authenticator',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Consumer<PersonnelProvider>(
            builder: (context, personnelProvider, child) {
              if (personnelProvider.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              // Get active personnel only
              final activePersonnel = personnelProvider.activePersonnel;

              return CommonDropdown<String>(
                value: selectedAuthenticatorId,
                items:
                    activePersonnel.map((personnelData) {
                      return DropdownMenuItem<String>(
                        value: personnelData.personnel.personnelID,
                        child: Text(
                          personnelData.fullName,
                          style: context.topology.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAuthenticatorId = value;
                  });
                },
                borderColor: context.colors.primary,
                textStyle: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              );
            },
          ),
        ),
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
          child: Row(
            children: [
              Icon(Icons.upload_file, size: 16, color: context.colors.primary.withOpacity(0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onPickFile,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, color: context.colors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Choose File",
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pickedFile != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pickedFile.name,
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                        _buildSectionHeader(context, 'Job Information', Icons.work_outline),
                        context.vM,
                        _buildRow(
                          context,
                          'Job No',
                          controller: jobNoController,
                          isRequired: true,
                          icon: Icons.tag,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Created Date',
                          controller: createdDateController,
                          icon: Icons.calendar_today,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Purchase Order No',
                          controller: poController,
                          icon: Icons.shopping_cart,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Procedure No',
                          controller: procedureController,
                          icon: Icons.description,
                        ),
                        context.vS,
                        _buildRow(context, 'Notes', controller: notesController, icon: Icons.notes),
                        context.vL,
                        _buildSectionHeader(context, 'Location Details', Icons.location_on),
                        context.vM,
                        _buildDivisionDropdown(context, icon: Icons.business),
                        context.vS,
                        _buildRow(
                          context,
                          'Address',
                          controller: addressController,
                          icon: Icons.home,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Offshore Location',
                          controller: offshoreLocationController,
                          icon: Icons.water,
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
                        _buildSectionHeader(context, 'Duration & Schedule', Icons.schedule),
                        context.vM,
                        _buildRow(
                          context,
                          'Allocated Duration',
                          controller: allocatedDurationController,
                          icon: Icons.timer,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Est. Inspection Duration',
                          controller: estInspectionDurationController,
                          icon: Icons.hourglass_empty,
                        ),
                        context.vS,
                        _buildDateField(
                          context,
                          'Est. Start Date',
                          estStartDateController,
                          icon: Icons.event,
                        ),
                        context.vS,
                        _buildDateField(
                          context,
                          'Est. End Date',
                          estEndDateController,
                          icon: Icons.event_available,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Engineer Complete',
                          controller: engineerCompleteController,
                          icon: Icons.engineering,
                        ),
                        context.vL,
                        _buildSectionHeader(context, 'Authorization', Icons.verified_user),
                        context.vM,
                        _buildAuthenticatorDropdown(context, icon: Icons.admin_panel_settings),
                        context.vS,
                        _buildRow(
                          context,
                          'Issuing Auth Name',
                          controller: issuingAuthNameController,
                          icon: Icons.person,
                        ),
                        context.vS,
                        _buildFileUploadRow(
                          context,
                          'Issuing Auth Signature',
                          _issuingAuthSignatureFile,
                          _pickIssuingAuthSignature,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Client Name',
                          controller: clientNameController,
                          icon: Icons.person_outline,
                        ),
                        context.vS,
                        _buildFileUploadRow(
                          context,
                          'Client Signature',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CommonButton(
                  text: _isLoading ? 'Creating...' : 'Create Job',
                  onPressed: _isLoading ? null : _createJob,
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          context.vM,
          _buildSectionHeader(context, 'Job Information', Icons.work_outline),
          context.vM,
          _buildRow(
            context,
            'Job No',
            controller: jobNoController,
            isRequired: true,
            icon: Icons.tag,
          ),
          context.vS,
          _buildRow(
            context,
            'Created Date',
            controller: createdDateController,
            icon: Icons.calendar_today,
          ),
          context.vS,
          _buildRow(
            context,
            'Purchase Order No',
            controller: poController,
            icon: Icons.shopping_cart,
          ),
          context.vS,
          _buildRow(
            context,
            'Procedure No',
            controller: procedureController,
            icon: Icons.description,
          ),
          context.vS,
          _buildRow(context, 'Notes', controller: notesController, icon: Icons.notes),
          context.vL,
          _buildSectionHeader(context, 'Location Details', Icons.location_on),
          context.vM,
          _buildDivisionDropdown(context, icon: Icons.business),
          context.vS,
          _buildRow(context, 'Address', controller: addressController, icon: Icons.home),
          context.vS,
          _buildRow(
            context,
            'Offshore Location',
            controller: offshoreLocationController,
            icon: Icons.water,
          ),
          context.vL,
          _buildSectionHeader(context, 'Duration & Schedule', Icons.schedule),
          context.vM,
          _buildRow(
            context,
            'Allocated Duration',
            controller: allocatedDurationController,
            icon: Icons.timer,
          ),
          context.vS,
          _buildRow(
            context,
            'Est. Inspection Duration',
            controller: estInspectionDurationController,
            icon: Icons.hourglass_empty,
          ),
          context.vS,
          _buildDateField(context, 'Est. Start Date', estStartDateController, icon: Icons.event),
          context.vS,
          _buildDateField(
            context,
            'Est. End Date',
            estEndDateController,
            icon: Icons.event_available,
          ),
          context.vS,
          _buildRow(
            context,
            'Engineer Complete',
            controller: engineerCompleteController,
            icon: Icons.engineering,
          ),
          context.vL,
          _buildSectionHeader(context, 'Authorization', Icons.verified_user),
          context.vM,
          _buildAuthenticatorDropdown(context, icon: Icons.admin_panel_settings),
          context.vS,
          _buildRow(
            context,
            'Issuing Auth Name',
            controller: issuingAuthNameController,
            icon: Icons.person,
          ),
          context.vS,
          _buildFileUploadRow(
            context,
            'Issuing Auth Signature',
            _issuingAuthSignatureFile,
            _pickIssuingAuthSignature,
          ),
          context.vS,
          _buildRow(
            context,
            'Client Name',
            controller: clientNameController,
            icon: Icons.person_outline,
          ),
          context.vS,
          _buildFileUploadRow(
            context,
            'Client Signature',
            _clientSignatureFile,
            _pickClientSignature,
          ),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Creating...' : 'Create Job',
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_task, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'New Job Details',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: context.colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Creating job...',
                      style: context.topology.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              )
              : (context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context)),
    );
  }
}
