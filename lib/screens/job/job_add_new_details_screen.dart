import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class JobAddNewDetailsScreen extends StatefulWidget {
  final String customer;
  final String site;

  const JobAddNewDetailsScreen({required this.customer, required this.site, super.key});

  @override
  State<JobAddNewDetailsScreen> createState() => _JobAddNewDetailsScreenState();
}

class _JobAddNewDetailsScreenState extends State<JobAddNewDetailsScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
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
        actions: [],
      ),
      body: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(context, 'Job No'),
                  context.vS,
                  _buildRow(context, 'Created Date'),
                  context.vS,
                  _buildRow(context, 'Purchase Order No'),
                  context.vS,
                  _buildRow(context, 'Procedure No'),
                  context.vS,
                  _buildRow(context, 'Notes'),
                  context.vS,
                  _buildRow(context, 'Division Name'),
                  context.vS,
                  _buildRow(context, 'Address'),
                  context.vS,
                  _buildRow(context, 'Allocated Duration'),
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
                  _buildRow(context, 'Est. Inspection Duration'),
                  context.vS,
                  _buildRow(context, 'Est. Start Date'),
                  context.vS,
                  _buildRow(context, 'Est. End Date'),
                  context.vS,
                  _buildRow(context, 'Engineer Complete'),
                  context.vS,
                  _buildRow(context, 'Offshore Location'),
                  context.vS,
                  _buildRow(context, 'Authenticator'),
                  context.vS,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRow(context, 'Job No'),
          context.vS,
          _buildRow(context, 'Created Date'),
          context.vS,
          _buildRow(context, 'Purchase Order No'),
          context.vS,
          _buildRow(context, 'Procedure No'),
          context.vS,
          _buildRow(context, 'Notes'),
          context.vS,
          _buildRow(context, 'Division Name'),
          context.vS,
          _buildRow(context, 'Address'),
          context.vS,
          _buildRow(context, 'Allocated Duration'),
          context.vS,
          _buildRow(context, 'Est. Inspection Duration'),
          context.vS,
          _buildRow(context, 'Est. Start Date'),
          context.vS,
          _buildRow(context, 'Est. End Date'),
          context.vS,
          _buildRow(context, 'Engineer Complete'),
          context.vS,
          _buildRow(context, 'Offshore Location'),
          context.vS,
          _buildRow(context, 'Authenticator'),
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
