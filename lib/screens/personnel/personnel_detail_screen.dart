import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/personnel_model.dart';
import 'package:INSPECT/providers/personnel_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonnelDetailScreen extends StatefulWidget {
  final String? personnelId;

  const PersonnelDetailScreen({super.key, this.personnelId});

  @override
  State<PersonnelDetailScreen> createState() => _PersonnelDetailScreenState();
}

class _PersonnelDetailScreenState extends State<PersonnelDetailScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _steps = ['Overview', 'Contact', 'Company', 'Misc Notes'];

  // Overview controllers
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Contact controllers - Business
  final TextEditingController _workMobileController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _workSecondaryEmailController = TextEditingController();
  final TextEditingController _workAddressController = TextEditingController();

  // Contact controllers - Personal
  final TextEditingController _personalMobileController = TextEditingController();
  final TextEditingController _homePhoneController = TextEditingController();
  final TextEditingController _personalEmailController = TextEditingController();
  final TextEditingController _personalSecondaryEmailController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();

  // Company controllers
  final TextEditingController _employeeNumberController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _generalNotesController = TextEditingController();
  final TextEditingController _associatedLoginController = TextEditingController();

  // Misc Notes & Qualifications controllers
  final TextEditingController _miscNotesController = TextEditingController();
  final TextEditingController _iratCertController = TextEditingController();
  final TextEditingController _eddyQualificationController = TextEditingController();
  final TextEditingController _magneticQualificationController = TextEditingController();
  final TextEditingController _liquidQualificationController = TextEditingController();
  final TextEditingController _ultrasonicQualificationController = TextEditingController();

  PersonnelData? _personnelData;

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    // Overview controllers
    _divisionController.dispose();
    _titleController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();

    // Contact controllers
    _workMobileController.dispose();
    _workPhoneController.dispose();
    _workEmailController.dispose();
    _workSecondaryEmailController.dispose();
    _workAddressController.dispose();
    _personalMobileController.dispose();
    _homePhoneController.dispose();
    _personalEmailController.dispose();
    _personalSecondaryEmailController.dispose();
    _homeAddressController.dispose();

    // Company controllers
    _employeeNumberController.dispose();
    _jobTitleController.dispose();
    _generalNotesController.dispose();
    _associatedLoginController.dispose();

    // Misc controllers
    _miscNotesController.dispose();
    _iratCertController.dispose();
    _eddyQualificationController.dispose();
    _magneticQualificationController.dispose();
    _liquidQualificationController.dispose();
    _ultrasonicQualificationController.dispose();
  }

  void _loadPersonnelData() {
    if (widget.personnelId != null) {
      final provider = context.read<PersonnelProvider>();
      _personnelData = provider.getPersonnelById(widget.personnelId!);

      if (_personnelData != null) {
        _populateControllers(_personnelData!);
      }
    } else {
      // New personnel - enable editing mode
      _isEditing = true;
    }
  }

  void _populateControllers(PersonnelData data) {
    // Overview
    _divisionController.text = data.personnel.divisionID;
    _titleController.text = data.personnel.title;
    _firstNameController.text = data.personnel.firstName;
    _middleNameController.text = data.personnel.middleName;
    _lastNameController.text = data.personnel.lastName;

    // Contact - Business
    _workMobileController.text = data.contactInfo.workMobilePhone;
    _workPhoneController.text = data.contactInfo.workPhone;
    _workEmailController.text = data.contactInfo.workEmail;
    _workSecondaryEmailController.text = data.contactInfo.workSecondaryEmail;
    _workAddressController.text = data.contactInfo.workAddress;

    // Contact - Personal
    _personalMobileController.text = data.contactInfo.homePhone;
    _homePhoneController.text = data.contactInfo.homePhone;
    _personalEmailController.text = data.contactInfo.personalEmail;
    _personalSecondaryEmailController.text = data.contactInfo.personalSecondaryEmail;
    _homeAddressController.text = data.contactInfo.homeAddress;

    // Company
    _employeeNumberController.text = data.company.employeeNumber;
    _jobTitleController.text = data.company.jobTitle;
    _generalNotesController.text = data.company.generalNotes;
    _associatedLoginController.text = data.company.associatedLogin;

    // Misc Notes & Qualifications
    _miscNotesController.text = data.personnel.miscNotes;
    _iratCertController.text = data.qualification.iratCert;
    _eddyQualificationController.text = data.qualification.eddyQualification;
    _magneticQualificationController.text = data.qualification.magneticQualification;
    _liquidQualificationController.text = data.qualification.liquidQualification;
    _ultrasonicQualificationController.text = data.qualification.ultrasonicQualification;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _savePersonnel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would typically call the provider method to save/update personnel
      // For now, we'll just simulate the save operation
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.personnelId == null
                  ? 'Personnel created successfully'
                  : 'Personnel updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final isNewPersonnel = widget.personnelId == null;
    final title =
        isNewPersonnel ? 'Add Personnel' : (_isEditing ? 'Edit Personnel' : 'Personnel Details');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        actions: [
          if (!isNewPersonnel && !_isEditing)
            IconButton(onPressed: _toggleEdit, icon: const Icon(Icons.edit), tooltip: 'Edit'),
          if (_isEditing && !_isLoading)
            IconButton(onPressed: _savePersonnel, icon: const Icon(Icons.save), tooltip: 'Save'),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Container(
        padding: context.paddingAll,
        child: Column(
          children: [
            // Horizontal stepper
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _steps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String label = entry.value;
                      bool isActive = _currentStep == index;
                      bool isCompleted = index < _currentStep;

                      return Row(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    isCompleted
                                        ? context.colors.primary
                                        : (isActive ? context.colors.secondary : Colors.grey),
                                child: Text(
                                  '${index + 1}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              context.vS,
                              Text(
                                label,
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (index != _steps.length - 1)
                            Container(
                              width: 40,
                              height: 2,
                              color:
                                  index < _currentStep
                                      ? context.colors.primary
                                      : context.colors.secondary,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            context.vL,
            Expanded(child: _getStepContent(_currentStep)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: context.screenWidth / 2.5,
                  child: CommonButton(
                    onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
                    text: 'Back',
                  ),
                ),
                context.hM,
                SizedBox(
                  width: context.screenWidth / 2.5,
                  child: CommonButton(
                    onPressed:
                        _currentStep < _steps.length - 1
                            ? () => setState(() => _currentStep++)
                            : (_isEditing ? _savePersonnel : null),
                    text:
                        _currentStep < _steps.length - 1 ? 'Next' : (_isEditing ? 'Save' : 'Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: [
              _widgetForm('Division', _divisionController),
              context.vS,
              _widgetForm('Title', _titleController),
              context.vS,
              _widgetForm('First Name', _firstNameController),
              context.vS,
              _widgetForm('Middle Name(s)', _middleNameController),
              context.vS,
              _widgetForm('Last Name', _lastNameController),
            ],
          ),
        );
      case 1:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Contact',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.divider,
              context.vS,
              _widgetForm('Work Address', _workAddressController, maxLines: 2),
              context.vS,
              _widgetForm('Work Mobile Phone No.', _workMobileController),
              context.vS,
              _widgetForm('Work Phone No.', _workPhoneController),
              context.vS,
              _widgetForm('Work Email Address', _workEmailController),
              context.vS,
              _widgetForm('Work Secondary Email', _workSecondaryEmailController),
              context.vL,
              Text(
                'Personal Contact',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.divider,
              context.vS,
              _widgetForm('Home Address', _homeAddressController, maxLines: 2),
              context.vS,
              _widgetForm('Personal Mobile Phone', _personalMobileController),
              context.vS,
              _widgetForm('Home Phone No.', _homePhoneController),
              context.vS,
              _widgetForm('Personal Email Address', _personalEmailController),
              context.vS,
              _widgetForm('Personal Secondary Email', _personalSecondaryEmailController),
              context.vXxl,
            ],
          ),
        );
      case 2:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widgetForm('Employee No', _employeeNumberController),
              context.vS,
              _widgetForm('Associated Login', _associatedLoginController),
              context.vS,
              _widgetForm('Job Title', _jobTitleController),
              context.vM,
              Text(
                'General Notes',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.vS,
              CommonTextField(
                controller: _generalNotesController,
                minLines: 5,
                maxLines: 10,
                enabled: _isEditing,
              ),
              context.vS,
            ],
          ),
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Miscellaneous Notes',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.vS,
              CommonTextField(
                controller: _miscNotesController,
                minLines: 3,
                maxLines: 5,
                enabled: _isEditing,
              ),
              context.vM,
              Text(
                'Qualifications',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.divider,
              context.vS,
              _widgetForm('IRATA Certification', _iratCertController),
              context.vS,
              _widgetForm('Eddy Current Qualification', _eddyQualificationController),
              context.vS,
              _widgetForm('Ultrasonic Qualification', _ultrasonicQualificationController),
              context.vS,
              _widgetForm('Magnetic Particle Qualification', _magneticQualificationController),
              context.vS,
              _widgetForm('Liquid Penetrant Qualification', _liquidQualificationController),
              context.vXxl,
            ],
          ),
        );
      default:
        return const Text('Unknown Step', style: TextStyle(fontSize: 18));
    }
  }

  Widget _widgetForm(String text, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                text,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: CommonTextField(
              controller: controller,
              enabled: _isEditing,
              maxLines: maxLines,
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: _isEditing ? context.colors.onSurface : context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
