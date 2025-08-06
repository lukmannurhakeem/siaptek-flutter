import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_file_upload_input.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerCreateNewScreen extends StatefulWidget {
  const CustomerCreateNewScreen({super.key});

  @override
  State<CustomerCreateNewScreen> createState() => _CustomerCreateNewScreenState();
}

class _CustomerCreateNewScreenState extends State<CustomerCreateNewScreen> {
  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Customer',
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Customer Name',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Customer Name',
                        controller: customerProvider.customerNameController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Account Code',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Account Code',
                        controller: customerProvider.customerCodeController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Agent',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Agent',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Notes',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Notes',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Division',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Division',
                        controller: customerProvider.divisionController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Division',
                        controller: customerProvider.statusController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
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
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Address',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Address',
                        controller: customerProvider.addressController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vL,
                CommonButton(
                  text: 'Save',
                  onPressed: () {
                    customerProvider.createCustomer(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
