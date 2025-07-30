import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_file_upload_input.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class SiteCreateNewScreen extends StatefulWidget {
  const SiteCreateNewScreen({super.key});

  @override
  State<SiteCreateNewScreen> createState() => _SiteCreateNewScreenState();
}

class _SiteCreateNewScreenState extends State<SiteCreateNewScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Site',
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
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is used for creating Sites belonging to a Customer',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vM,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField()),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Site Code',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField()),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Customer',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField()),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Area',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField()),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Description',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField(minLines: 3, maxLines: 4)),
                  ],
                ),
                context.vS,

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Note',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonTextField(minLines: 3, maxLines: 4)),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Logo',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonFileUploadInput()),
                  ],
                ),
                context.vL,
                CommonButton(text: 'Save', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
