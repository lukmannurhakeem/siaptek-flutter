import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/widget/common_collapsible_widget.dart';
import 'package:flutter/material.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreen();
}

class _AccessScreen extends State<AccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          _buildContent('User Groups'),
          context.vS,
          _buildContent('Logins'),
          context.vS,
          _buildContent('Customer Groups'),
          context.vS,
          _buildContent('Site Groups'),
          context.vS,
          _buildContent('API Keys'),
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
