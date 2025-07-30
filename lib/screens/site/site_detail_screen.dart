import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/site_model.dart';
import 'package:flutter/material.dart';

class SiteDetailsScreen extends StatefulWidget {
  final SiteModel sideModel;

  const SiteDetailsScreen({super.key, required this.sideModel});

  @override
  State<SiteDetailsScreen> createState() => _SiteDetailsScreenState();
}

class _SiteDetailsScreenState extends State<SiteDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
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
                  'Overview',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vS,
                context.divider,
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
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.sideModel.siteName ?? '-',
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
                        'Site Code',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.sideModel.siteCode ?? '-',
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
                        'Customer',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.sideModel.customerName ?? '-',
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
                        'Area',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.sideModel.area ?? '-',
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
                        'Address',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.sideModel.address ?? '-',
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
                      child: Text(
                        widget.sideModel.division ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
