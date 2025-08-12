import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class ItemOverviewScreen extends StatefulWidget {
  const ItemOverviewScreen({super.key});

  @override
  State<ItemOverviewScreen> createState() => _ItemOverviewScreenState();
}

class _ItemOverviewScreenState extends State<ItemOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(context, 'Item No'),
                context.vS,
                _buildRow(context, 'Archived'),
                context.vS,
                _buildRow(context, 'RFID No'),
                context.vS,
                _buildRow(context, 'Category'),
                context.vS,
                _buildRow(context, 'Location'),
                context.vS,
                _buildRow(context, 'Detailed Location'),
                context.vS,
                _buildRow(context, 'Internal Notes'),
                context.vS,
                _buildRow(context, 'External Notes'),
                context.vS,
              ],
            ),
          ),
        ),
        context.hXl,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(context, 'Manufacturer'),
                context.vS,
                _buildRow(context, 'Manufacturer Address'),
                context.vS,
                _buildRow(context, 'Manufacture Date'),
                context.vS,
                _buildRow(context, 'First Use Date'),
                context.vS,
                _buildRow(context, 'Out of Service'),
                context.vS,
                _buildRow(context, 'SWL'),
                context.vS,
                _buildRow(context, 'Photo Reference'),
                context.vS,
                _buildRow(context, 'Standard & Reference'),
                context.vS,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRow(context, 'Item No'),
          context.vS,
          _buildRow(context, 'Archived'),
          context.vS,
          _buildRow(context, 'RFID No'),
          context.vS,
          _buildRow(context, 'Category'),
          context.vS,
          _buildRow(context, 'Location'),
          context.vS,
          _buildRow(context, 'Detailed Location'),
          context.vS,
          _buildRow(context, 'Internal Notes'),
          context.vS,
          _buildRow(context, 'External Notes'),
          context.vS,
          _buildRow(context, 'Manufacturer'),
          context.vS,
          _buildRow(context, 'Manufacturer Address'),
          context.vS,
          _buildRow(context, 'Manufacture Date'),
          context.vS,
          _buildRow(context, 'First Use Date'),
          context.vS,
          _buildRow(context, 'Out of Service'),
          context.vS,
          _buildRow(context, 'SWL'),
          context.vS,
          _buildRow(context, 'Photo Reference'),
          context.vS,
          _buildRow(context, 'Standard & Reference'),
          context.vS,
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: CommonTextField()),
      ],
    );
  }
}
