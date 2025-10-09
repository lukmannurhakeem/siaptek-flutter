import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/screens/job/job_item_details/item_cycles_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_files_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_movements_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_overview_screen.dart';
import 'package:base_app/screens/job/job_item_details/item_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobItemDetailsScreen extends StatefulWidget {
  final Item item; // This is itemID (UUID)

  const JobItemDetailsScreen({required this.item, super.key});

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

    // Set the current item in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Clear the current item when leaving the screen
    context.read<JobProvider>().clearCurrentItem();
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
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          final item = provider.currentItem;

          return Padding(
            padding: context.paddingHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item?.itemNo ?? widget.item.itemNo!,
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.vS,
                Text(
                  item?.detailedLocation ?? widget.item.detailedLocation!,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
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
                      ItemOverviewScreen(jobId: widget.item),
                      ItemFilesScreen(),
                      ItemReportScreen(item: widget.item),
                      ItemCyclesScreen(),
                      ItemMovementScreen(),
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
