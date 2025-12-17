import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/widget/common_collapsible_widget.dart';
import 'package:flutter/material.dart';

class ReportSetupScreen extends StatefulWidget {
  const ReportSetupScreen({super.key});

  @override
  State<ReportSetupScreen> createState() => _ReportSetupScreen();
}

class _ReportSetupScreen extends State<ReportSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          _buildContent('Cycles'),
          context.vS,
          _buildContent('Approval Levels'),
          context.vS,
          _buildContent('Approval Overrides'),
          context.vS,
          _buildContent('Report Types'),
          context.vS,
          _buildContent('Status Admin'),
          context.vS,
        ],
      ),
    );
  }

  Widget _buildContent(String title) {
    return CommonCollapsibleWidget(
      header: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          title,
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
      ),
      content: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'This is the collapsible content. It can contain any widget you want to show/hide.',
        ),
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }
}
