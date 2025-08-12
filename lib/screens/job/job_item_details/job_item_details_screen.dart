import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/screens/job/job_item_details/item_cycles_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_files_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_movements_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_overview_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_reports_screen.dart';
import 'package:flutter/material.dart';

class JobItemDetailsScreen extends StatefulWidget {
  final String item;
  final String site;

  const JobItemDetailsScreen({required this.item, required this.site, super.key});

  @override
  State<JobItemDetailsScreen> createState() => _JobItemDetailsScreenState();
}

class _JobItemDetailsScreenState extends State<JobItemDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Files'),
    Tab(text: 'Reports'),
    Tab(text: 'Cycles'),
    Tab(text: 'Movements'),
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
      body: Padding(
        padding: context.paddingHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${widget.item}',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            context.vS,
            Text(
              '${widget.site}',
              style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
            ),
            context.vM,
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
                  ItemOverviewScreen(),
                  ItemFilesScreen(),
                  ItemReportScreen(),
                  ItemCyclesScreen(),
                  ItemMovementScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
