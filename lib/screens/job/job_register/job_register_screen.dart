import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/job_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inspection_register_tab.dart';
import 'item_register_tab.dart';
import 'report_approvals_tab.dart';

class JobRegisterScreen extends StatefulWidget {
  final String jobId;

  const JobRegisterScreen({super.key, required this.jobId});

  @override
  State<JobRegisterScreen> createState() => _JobRegisterScreenState();
}

class _JobRegisterScreenState extends State<JobRegisterScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabs = const [
    Tab(text: 'Item Register'),
    Tab(text: 'Inspection Register'),
    Tab(text: 'Report Approvals'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<JobProvider>();
      await provider.fetchJobRegisterModel(context, widget.jobId);
      await provider.fetchReportApprovals(context, widget.jobId);
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(JobRegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<JobProvider>();
        await provider.fetchJobRegisterModel(context, widget.jobId);
        await provider.fetchReportApprovals(context, widget.jobId);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Register - ${widget.jobId}',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () => NavigationService().goBack(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data: ${provider.error}',
                    style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobRegisterModel(context, widget.jobId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: context.paddingHorizontal,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: tabs,
                    labelColor: context.colors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: context.colors.primary,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ItemRegisterTab(jobId: widget.jobId),
                      InspectionRegisterTab(jobId: widget.jobId),
                      ReportApprovalsTab(jobId: widget.jobId),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
