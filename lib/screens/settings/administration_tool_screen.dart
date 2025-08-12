import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/widget/common_collapsible_widget.dart';
import 'package:flutter/material.dart';

class AdministrationToolsScreen extends StatefulWidget {
  const AdministrationToolsScreen({super.key});

  @override
  State<AdministrationToolsScreen> createState() => _AdministrationToolsScreen();
}

class _AdministrationToolsScreen extends State<AdministrationToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          _buildContent('Lookup Manager'),
          context.vS,
          _buildContent('Fields'),
          context.vS,
          _buildContent('Customised Views'),
          context.vS,
          _buildContent('Location Templates'),
          context.vS,
          _buildContent('Number Templates'),
          context.vS,
          _buildContent('Filestore Templates'),
          context.vS,
          _buildContent('File Types'),
          context.vS,
          _buildContent('Branding'),
          context.vS,
          _buildContent('Settings'),
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
