import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class PersonnelCreateTeamScreen extends StatefulWidget {
  const PersonnelCreateTeamScreen({super.key});

  @override
  State<PersonnelCreateTeamScreen> createState() => _PersonnelCreateTeamScreenState();
}

class _PersonnelCreateTeamScreenState extends State<PersonnelCreateTeamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Team',
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.onPrimary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.onPrimary),
        backgroundColor: context.colors.primary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Container(
        padding: context.paddingAll,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _widgetForm('Name'),
              context.vS,
              _widgetForm('Parent Team'),
              context.vS,
              _widgetForm('Type'),
              context.vS,
              _widgetForm('Description'),
              context.vXxl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: context.screenWidth / 2.5,
                    child: CommonButton(onPressed: () {}, text: 'Add'),
                  ),
                  context.hM,
                  SizedBox(
                    width: context.screenWidth / 2.5,
                    child: CommonButton(onPressed: () {}, text: 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
