import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonnelCreateScreen extends StatefulWidget {
  const PersonnelCreateScreen({super.key});

  @override
  State<PersonnelCreateScreen> createState() => _PersonnelCreateScreenState();
}

class _PersonnelCreateScreenState extends State<PersonnelCreateScreen> {
  int _currentStep = 0;
  final List<String> _steps = ['Overview', 'Contact', 'Company', 'Misc Notes'];

  // Form controllers for Overview step
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Form controllers for Contact step - Business
  final TextEditingController _workMobileController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _workSecondaryEmailController = TextEditingController();

  // Form controllers for Contact step - Personal
  final TextEditingController _personalMobileController = TextEditingController();
  final TextEditingController _homePhoneController = TextEditingController();
  final TextEditingController _personalEmailController = TextEditingController();
  final TextEditingController _personalSecondaryEmailController = TextEditingController();

  // Form controllers for Company step
  final TextEditingController _employeeNoController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _generalNotesController = TextEditingController();

  // Form controllers for Misc Notes step
  final TextEditingController _miscNotesController = TextEditingController();
  final TextEditingController _leeaQualificationController = TextEditingController();
  final TextEditingController _irataQualificationController = TextEditingController();
  final TextEditingController _api2cQualificationController = TextEditingController();
  final TextEditingController _api4gQualificationController = TextEditingController();
  final TextEditingController _dropsQualificationController = TextEditingController();
  final TextEditingController _eddyCurrentController = TextEditingController();
  final TextEditingController _ultrasonicController = TextEditingController();
  final TextEditingController _magneticParticleController = TextEditingController();
  final TextEditingController _liquidPenetrantController = TextEditingController();

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose all controllers
    _divisionController.dispose();
    _titleController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _workMobileController.dispose();
    _workPhoneController.dispose();
    _workEmailController.dispose();
    _workSecondaryEmailController.dispose();
    _personalMobileController.dispose();
    _homePhoneController.dispose();
    _personalEmailController.dispose();
    _personalSecondaryEmailController.dispose();
    _employeeNoController.dispose();
    _jobTitleController.dispose();
    _generalNotesController.dispose();
    _miscNotesController.dispose();
    _leeaQualificationController.dispose();
    _irataQualificationController.dispose();
    _api2cQualificationController.dispose();
    _api4gQualificationController.dispose();
    _dropsQualificationController.dispose();
    _eddyCurrentController.dispose();
    _ultrasonicController.dispose();
    _magneticParticleController.dispose();
    _liquidPenetrantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Person',
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Consumer<PersonnelProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: context.paddingAll,
            child: Form(
              key: _formKey,
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
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                  context.vL,
                  Expanded(child: Center(child: _getStepContent(_currentStep))),
                  if (provider.isLoading)
                    Padding(padding: const EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(provider.errorMessage!, style: TextStyle(color: Colors.red)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: context.screenWidth / 2.5,
                        child: CommonButton(
                          onPressed:
                              _currentStep > 0 && !provider.isLoading
                                  ? () => setState(() => _currentStep--)
                                  : null,
                          text: 'Back',
                        ),
                      ),
                      context.hM,
                      SizedBox(
                        width: context.screenWidth / 2.5,
                        child: CommonButton(
                          onPressed: !provider.isLoading ? _handleNextOrSubmit : null,
                          text: _currentStep < _steps.length - 1 ? 'Next' : 'Submit',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return Column(
          children: [
            _widgetForm('Division', _divisionController, isRequired: true),
            context.vS,
            _widgetForm('Title', _titleController),
            context.vS,
            _widgetForm('First Name', _firstNameController, isRequired: true),
            context.vS,
            _widgetForm('Middle Name(s)', _middleNameController),
            context.vS,
            _widgetForm('Last Name', _lastNameController, isRequired: true),
          ],
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
              _widgetForm('Work Mobile Phone No.', _workMobileController),
              context.vS,
              _widgetForm('Work Phone No.', _workPhoneController),
              context.vS,
              _widgetForm('Work Email Address', _workEmailController),
              context.vS,
              _widgetForm('Secondary Email Address', _workSecondaryEmailController),
              context.vL,
              Text(
                'Personal Contact',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.divider,
              context.vS,
              _widgetForm('Mobile Phone No.', _personalMobileController),
              context.vS,
              _widgetForm('Home Phone No.', _homePhoneController),
              context.vS,
              _widgetForm('Email Address', _personalEmailController),
              context.vS,
              _widgetForm('Secondary Email Address', _personalSecondaryEmailController),
              context.vXxl,
            ],
          ),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetForm('Employee No', _employeeNoController),
            context.vS,
            _widgetForm('Job Title', _jobTitleController),
            context.vM,
            Text(
              'General Notes',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
            context.vS,
            CommonTextField(controller: _generalNotesController, minLines: 5, maxLines: 10),
            context.vS,
          ],
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widgetForm('Misc Notes', _miscNotesController),
              context.vS,
              _widgetForm('LEEA Qualification', _leeaQualificationController),
              context.vS,
              _widgetForm('IRATA Qualification', _irataQualificationController),
              context.vS,
              _widgetForm('API 2C & 2D Qualification', _api2cQualificationController),
              context.vS,
              _widgetForm('API RP 4G Qualification', _api4gQualificationController),
              context.vS,
              _widgetForm('DROPS Qualification', _dropsQualificationController),
              context.vS,
              _widgetForm('Eddy Current Inspection Qualification', _eddyCurrentController),
              context.vS,
              _widgetForm('Ultrasonic Inspection Qualification', _ultrasonicController),
              context.vS,
              _widgetForm(
                'Magnetic Particle Inspection Qualification',
                _magneticParticleController,
              ),
              context.vS,
              _widgetForm('Liquid Penetrant Inspection Qualification', _liquidPenetrantController),
              context.vXxl,
            ],
          ),
        );
      default:
        return Text('Unknown Step', style: TextStyle(fontSize: 18));
    }
  }

  Widget _widgetForm(String text, TextEditingController controller, {bool isRequired = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            text + (isRequired ? ' *' : ''),
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            controller: controller,
            validator:
                isRequired
                    ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                    : null,
          ),
        ),
      ],
    );
  }

  void _handleNextOrSubmit() {
    if (_currentStep < _steps.length - 1) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
      }
    } else {
      // Submit form
      _submitForm();
    }
  }

  bool _validateCurrentStep() {
    // Basic validation for required fields in step 0
    if (_currentStep == 0) {
      if (_divisionController.text.isEmpty ||
          _firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
        return false;
      }
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final personnelData = _buildPersonnelData();
    final provider = Provider.of<PersonnelProvider>(context, listen: false);

    final success = await provider.createPersonnel(personnelData);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Personnel created successfully!')));
      NavigationService().goBack();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create personnel. Please try again.')));
    }
  }

  Map<String, dynamic> _buildPersonnelData() {
    return {
      "divisionID": _divisionController.text,
      "title": _titleController.text,
      "firstName": _firstNameController.text,
      "middleName": _middleNameController.text,
      "lastName": _lastNameController.text,
      "signatureFile": "",
      "isHiddenFromPlanner": false,
      "miscNotes": _miscNotesController.text,
      "contactInfo": {
        "workAddress": "",
        "workMobilePhone": _workMobileController.text,
        "workPhone": _workPhoneController.text,
        "workEmail": _workEmailController.text,
        "workSecondaryEmail": _workSecondaryEmailController.text,
        "homeAddress": "",
        "homePhone": _homePhoneController.text,
        "personalEmail": _personalEmailController.text,
        "personalSecondaryEmail": _personalSecondaryEmailController.text,
      },
      "company": {
        "associatedLogin": "",
        "employeeNumber": _employeeNoController.text,
        "jobTitle": _jobTitleController.text,
        "generalNotes": _generalNotesController.text,
      },
      "availability": [
        {"dayOfWeek": "Monday", "startTime": "09:00", "endTime": "17:00"},
        {"dayOfWeek": "Tuesday", "startTime": "09:00", "endTime": "17:00"},
        {"dayOfWeek": "Wednesday", "startTime": "09:00", "endTime": "17:00"},
        {"dayOfWeek": "Thursday", "startTime": "09:00", "endTime": "17:00"},
        {"dayOfWeek": "Friday", "startTime": "09:00", "endTime": "17:00"},
      ],
      "qualification": {
        "iratCert": _irataQualificationController.text,
        "eddyQualification": _eddyCurrentController.text,
        "magneticQualification": _magneticParticleController.text,
        "liquidQualification": _liquidPenetrantController.text,
        "ultrasonicQualification": _ultrasonicController.text,
      },
    };
  }
}
