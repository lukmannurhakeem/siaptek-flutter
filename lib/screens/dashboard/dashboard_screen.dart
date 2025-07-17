import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/screens/dashboard/dashboard_open_job_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_side_report_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_summary_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabs = const [
    Tab(text: 'Summary'),
    Tab(text: 'Open Jobs'),
    Tab(text: 'Site Report Summary'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 70,
            child: TabBarView(
              controller: _tabController,
              children: [
                SummaryScreen(),
                OpenJobsScreen(),
                SiteReportScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
