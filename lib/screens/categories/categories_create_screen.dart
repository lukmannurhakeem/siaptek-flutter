import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class CategoriesCreateScreen extends StatefulWidget {
  const CategoriesCreateScreen({super.key});

  @override
  State<CategoriesCreateScreen> createState() => _CategoriesCreateScreenState();
}

class _CategoriesCreateScreenState extends State<CategoriesCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Category',
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Container(
        padding: context.paddingHorizontal,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widgetForm('Category Name'),
              context.vS,
              _widgetForm('Code'),
              context.vS,
              _widgetForm('Parent Category'),
              context.vS,
              _widgetForm('Description'),
              context.vM,
              Text(
                'Description Template',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.vS,
              CommonTextField(minLines: 3, maxLines: 5),
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
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(flex: 3, child: CommonTextField()),
      ],
    );
  }
}
