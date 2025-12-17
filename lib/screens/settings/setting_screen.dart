import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/widget/common_collapsible_widget.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          _buildContent('Super Search'),
          context.vS,
          _buildContent('Schedule Email'),
          context.vS,
          _buildContent('Dashboard Setup'),
          context.vS,
          _buildContent('Planner Setup'),
          context.vS,
          _buildContent('Data Import'),
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
      backgroundColor: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    );
  }
}
