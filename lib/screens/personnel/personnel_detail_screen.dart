import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class PersonnelDetailScreen extends StatefulWidget {
  const PersonnelDetailScreen({super.key});

  @override
  State<PersonnelDetailScreen> createState() => _PersonnelDetailScreenState();
}

class _PersonnelDetailScreenState extends State<PersonnelDetailScreen> {
  int _currentStep = 0;

  final List<String> _steps = ['Overview', 'Contact', 'Company', 'Misc Notes'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Details',
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
                              margin: EdgeInsets.symmetric(horizontal: 4),
                            ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            context.vL,
            Expanded(child: Center(child: _getStepContent(_currentStep))),
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
                            : null,
                    text: 'Next',
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
        return Column(
          children: [
            _widgetForm('Division'),
            context.vS,
            _widgetForm('Title'),
            context.vS,
            _widgetForm('First Name'),
            context.vS,
            _widgetForm('Middle Name(s)'),
            context.vS,
            _widgetForm('Last Name'),
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
              _widgetForm('Work Mobile Phone No.'),
              context.vS,
              _widgetForm('Work Phone No.'),
              context.vS,
              _widgetForm('Work Email Address'),
              context.vS,
              _widgetForm('Secondary Email Address'),
              context.vL,
              Text(
                'Personal Contact',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.divider,
              context.vS,
              _widgetForm('Mobile Phone No.'),
              context.vS,
              _widgetForm('Home Phone No.'),
              context.vS,
              _widgetForm('Email Address'),
              context.vS,
              _widgetForm('Secondary Email Address'),
              context.vXxl,
            ],
          ),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetForm('Employee No'),
            context.vS,
            _widgetForm('Job Title'),
            context.vM,
            Text(
              'General Notes',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
            context.vS,
            CommonTextField(minLines: 5, maxLines: 10),
            context.vS,
          ],
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widgetForm('Misc Notes'),
              context.vS,
              _widgetForm('LEEA Qualification'),
              context.vS,
              _widgetForm('IRATA Qualification'),
              context.vS,
              _widgetForm('API 2C & 2D Qualification'),
              context.vS,
              _widgetForm('API RP 4G Qualification'),
              context.vS,
              _widgetForm('DROPS Qualification'),
              context.vS,
              _widgetForm('Eddy Current Inspection Qualification'),
              context.vS,
              _widgetForm('Ultrasonic Inspection Qualification'),
              context.vS,
              _widgetForm('Magnetic Particle Inspection Qualification'),
              context.vS,
              _widgetForm('Liquid Penetrant Inspection Qualification'),
              context.vXxl,
            ],
          ),
        );
      default:
        return Text('Unknown Step', style: TextStyle(fontSize: 18));
    }
  }

  Widget _widgetForm(String text) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            text,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(flex: 3, child: CommonTextField()),
      ],
    );
  }
}
