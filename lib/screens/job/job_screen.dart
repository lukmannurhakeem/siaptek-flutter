import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  List<JobModel> jobModel = [
    JobModel(
      'VEL/N8/2023/001',
      'Velesto Energy Berhad',
      'Naga 8',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'BSL/BTL/2022/001',
      'BSL Containers Sdn Bhd',
      'BSL Bintulu',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPT/KL/IMT/2022/001',
      'Trone Solutions & Technologies Sdn. Bhd.',
      'Trone Solutions & Technologies Sdn. Bhd. HQ',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'KHLHSB/KT/2022/001',
      'Johan Jitu Sdn Bhd',
      'Johan Jitu Yard, Kuala Terengganu',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPK0028',
      'Schlumberger (M) Sdn Bhd',
      'Malaysia',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPT/SSB/LBN/2023/001',
      'Serimatik Yard, Labuan',
      'Naga 8',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel('SPK0018', 'DEME Group', 'Pinocchio', Status.started, DateTime.now(), DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: context.paddingAll,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    jobModel.asMap().entries.map((entry) {
                      final item = entry.value;

                      return Column(
                        children: [
                          _buildJobCard(
                            context,
                            item.registerNum,
                            item.customerName,
                            item.siteName,
                          ),
                          context.vS,
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                CommonDialog.show(
                  context,
                  widget: SizedBox(
                    height: context.screenHeight / 2.35,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Customer',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: CommonTextField(
                                hintText: 'Customer Name',
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
                              flex: 1,
                              child: Text(
                                'Job No',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: CommonTextField(
                                hintText: 'Customer Name',
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
                              flex: 1,
                              child: Text(
                                'Site',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: CommonTextField(
                                hintText: 'Site Name',
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
                              flex: 1,
                              child: Text(
                                'Status',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: CommonTextField(
                                hintText: 'Status',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        context.vL,
                        CommonButton(
                          text: 'Search',
                          onPressed: () {
                            NavigationService().goBack();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              tooltip: 'Search',
              child: const Icon(Icons.search),
              backgroundColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    String registerNum,
    String customerName,
    String siteName,
  ) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Started',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
              _buildRow(context, 'No', registerNum),
              context.vS,
              _buildRow(context, 'Customer', customerName),
              context.vS,
              _buildRow(context, 'Site', siteName),
              context.vS,
              _buildRow(context, 'Start Date', '${DateTime.now().formatShortDate}'),
              context.vS,
              _buildRow(context, 'End Date', '${DateTime.now().formatShortDate}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
