import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportFieldsScreen extends StatefulWidget {
  final String reportTypeId;
  final String reportName;
  final Item item;

  const ReportFieldsScreen({
    required this.reportTypeId,
    required this.reportName,
    super.key,
    required this.item,
  });

  @override
  State<ReportFieldsScreen> createState() => _ReportFieldsScreenState();
}

class _ReportFieldsScreenState extends State<ReportFieldsScreen> {
  // State variables
  Map<String, TextEditingController> _controllers = {};
  List<String> _fields = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  DateTime? _selectedReportDate;

  // Additional controllers for fixed fields
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _regulationController = TextEditingController();
  String _selectedStatus = 'draft';
  String? _selectedInspectedById;

  @override
  void initState() {
    super.initState();
    _fetchReportFields();
    // Fetch personnel data for the dropdown
    Future.microtask(() {
      context.read<PersonnelProvider>().fetchPersonnel();
    });
  }

  Future<void> _fetchReportFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SystemProvider>();
      final result = await provider.getReportFields(widget.reportTypeId);

      if (result != null && result['data'] != null) {
        final List<dynamic> data = result['data'];

        // Parse the comma-separated fields from the response
        List<String> allFields = [];
        for (var item in data) {
          if (item is String) {
            // Split by comma and trim whitespace
            final fields = item.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            allFields.addAll(fields);
          }
        }

        setState(() {
          _fields = allFields;
          // Initialize controllers for each field
          _controllers = {for (var field in _fields) field: TextEditingController()};
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No fields data available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _itemIdController.dispose();
    _itemNoController.dispose();
    _regulationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reportName,
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
      body: Stack(
        children: [
          Column(children: [_buildFixedDataSection(), Expanded(child: _buildBody())]),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFixedDataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: context.colors.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Information',
            style: context.topology.textTheme.titleSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Report Type ID:', widget.reportTypeId),
          const SizedBox(height: 8),
          _buildInfoRow('Report Name:', widget.reportName),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 12),
          _buildStatusDropdown(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Date',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedReportDate != null
                        ? _selectedReportDate!.formatMediumDate
                        : 'Select date',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color:
                          _selectedReportDate != null
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: context.colors.primary),
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          items:
              ['draft', 'submitted', 'approved', 'rejected'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedStatus = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
              onPrimary: context.colors.onPrimary,
              onSurface: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedReportDate) {
      setState(() {
        _selectedReportDate = picked;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchReportFields, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_fields.isEmpty) {
      return Center(
        child: Text(
          'No fields available for this report',
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: context.paddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Information',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.vM,
          _buildRequiredField('Item ID', _itemIdController, 'Enter item ID'),
          const SizedBox(height: 12),
          _buildRequiredField('Item No', _itemNoController, 'Enter item number'),
          const SizedBox(height: 12),
          _buildInspectedByDropdown(),
          const SizedBox(height: 12),
          _buildRequiredField('Regulation', _regulationController, 'Enter regulation'),
          context.vL,
          Text(
            'Report Fields',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.vM,
          ..._buildFieldRows(),
          context.vL,
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildRequiredField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodyMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CommonTextField(controller: controller, hintText: hint),
      ],
    );
  }

  Widget _buildInspectedByDropdown() {
    return Consumer<PersonnelProvider>(
      builder: (context, personnelProvider, _) {
        final personnelList = personnelProvider.personnelList;

        // Build dropdown items from personnel list
        final items =
            personnelList.map((personnel) {
              final displayName =
                  personnel.displayName.isNotEmpty ? personnel.displayName : personnel.fullName;
              final id = personnel.personnel.personnelID;

              return DropdownMenuItem<String>(value: id, child: Text(displayName));
            }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspected By',
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CommonDropdown<String>(
              value: _selectedInspectedById,
              items: items,
              onChanged: (value) {
                setState(() {
                  _selectedInspectedById = value;
                });
              },
              borderColor: context.colors.primary.withOpacity(0.3),
              backgroundColor: context.colors.onPrimary,
              label: null,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFieldRows() {
    return _fields.map((field) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field,
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CommonTextField(controller: _controllers[field], hintText: 'Enter $field'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: context.colors.primary.withOpacity(0.5),
        ),
        child: Text(
          _isSubmitting ? 'Submitting...' : 'Submit',
          style: context.topology.textTheme.bodyMedium?.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Validate required fields
    if (_selectedReportDate == null) {
      _showErrorSnackBar('Please select a report date');
      return;
    }

    if (_itemIdController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Item ID');
      return;
    }

    if (_itemNoController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Item No');
      return;
    }

    if (_selectedInspectedById == null || _selectedInspectedById!.isEmpty) {
      _showErrorSnackBar('Please select an inspector');
      return;
    }

    if (_regulationController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Regulation');
      return;
    }

    // Collect all field values
    Map<String, String> fieldValues = {};
    for (var entry in _controllers.entries) {
      fieldValues[entry.key] = entry.value.text;
    }

    // Get the selected inspector name
    final personnelProvider = context.read<PersonnelProvider>();
    final selectedPersonnel = personnelProvider.getPersonnelById(_selectedInspectedById!);
    final inspectedByName =
        selectedPersonnel?.displayName.isNotEmpty == true
            ? selectedPersonnel!.displayName
            : selectedPersonnel?.fullName ?? '';

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Submission'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow('Report Date:', _selectedReportDate!.formatMediumDate),
                  _buildConfirmationRow('Status:', _selectedStatus.toUpperCase()),
                  _buildConfirmationRow('Item ID:', _itemIdController.text),
                  _buildConfirmationRow('Item No:', _itemNoController.text),
                  _buildConfirmationRow('Inspected By:', inspectedByName),
                  _buildConfirmationRow('Regulation:', _regulationController.text),
                  const SizedBox(height: 12),
                  Text(
                    'Field Values:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary),
                  ),
                  const SizedBox(height: 8),
                  ...fieldValues.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${e.key}: ${e.value.isEmpty ? "(empty)" : e.value}'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitReportData(fieldValues);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _submitReportData(Map<String, String> fieldValues) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<SystemProvider>();

      // Format the report date to ISO 8601 format with timezone
      final reportDateISO = _selectedReportDate!.toUtc().toIso8601String();

      // Transform field values to match API structure
      Map<String, Map<String, String>> reportData = {};
      fieldValues.forEach((key, value) {
        reportData[key] = {"value": value};
      });

      // Get the selected inspector name
      final personnelProvider = context.read<PersonnelProvider>();
      final selectedPersonnel = personnelProvider.getPersonnelById(_selectedInspectedById!);
      final inspectedByName =
          selectedPersonnel?.displayName.isNotEmpty == true
              ? selectedPersonnel!.displayName
              : selectedPersonnel?.fullName ?? '';

      // Call the createReportData method from SystemProvider
      final result = await provider.createReportData(
        reportTypeId: widget.reportTypeId,
        itemId: widget.item.itemId ?? '',
        itemNo: widget.item.itemNo ?? '',
        status: _selectedStatus,
        inspectedBy: inspectedByName,
        reportDate: reportDateISO,
        regulation: _regulationController.text.trim(),
        reportData: reportData,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success message with result info if available
        final message =
            result != null && result['message'] != null
                ? result['message']
                : 'Report submitted successfully for ${_selectedReportDate!.formatMediumDate}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear form after successful submission (optional)
        _clearForm();

        // Navigate back after successful submission
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            NavigationService().goBack();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Extract meaningful error message
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }
        if (errorMessage.contains('Failed to create report data: ')) {
          errorMessage = errorMessage.replaceFirst('Failed to create report data: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _submitReportData(fieldValues),
            ),
          ),
        );
      }
    }
  }

  void _clearForm() {
    // Clear all text controllers
    _itemIdController.clear();
    _itemNoController.clear();
    _regulationController.clear();

    for (var controller in _controllers.values) {
      controller.clear();
    }

    setState(() {
      _selectedReportDate = null;
      _selectedStatus = 'draft';
      _selectedInspectedById = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.orange));
  }
}
