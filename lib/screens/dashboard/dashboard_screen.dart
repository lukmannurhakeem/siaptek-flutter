import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/local_storage_constant.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _firstName = '';
  String _lastName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firstName = await LocalStorageService.getString(LocalStorageConstant.userFirstName) ?? '';
    final lastName = await LocalStorageService.getString(LocalStorageConstant.userLastName) ?? '';
    final email = await LocalStorageService.getString(LocalStorageConstant.userEmail) ?? '';

    setState(() {
      _firstName = firstName;
      _lastName = lastName;
      _email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info, notification, and location filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- USER INFO ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    child: Text(
                      _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_firstName $_lastName'.trim(),
                        style: context.topology.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      Text(
                        _email,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // --- NOTIFICATION + CUSTOMER DROPDOWN ---
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Notification Icon
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // Handle notification tap
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),

                  // Customer Dropdown
                  SizedBox(
                    width: 200,
                    child: Consumer2<CustomerProvider, SiteProvider>(
                      builder: (context, customerProvider, siteProvider, _) {
                        final customers = customerProvider.customers;

                        return DropdownButtonFormField<String>(
                          value: siteProvider.selectedCustomerId,
                          decoration: InputDecoration(
                            hintText: 'Select Customer',
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            hintStyle: context.topology.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          items:
                              customers.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.customerid,
                                  child: Text(
                                    customer.customername ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            siteProvider.setSelectedCustomer(value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 24),

          // Top Row - Statistics Cards (Always in one row)
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardWidth = (availableWidth - (3 * 16)) / 4; // 4 cards with 3 gaps of 16px
              final minCardWidth = 250.0;

              // If calculated width is too small, use horizontal scroll
              if (cardWidth < minCardWidth) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatCard(
                        title: 'Workorders By Status',
                        child: _WorkordersByStatusChart(),
                        width: minCardWidth,
                      ),
                      SizedBox(width: 16),
                      _StatCard(
                        title: 'Maintenance Type',
                        child: _MaintenanceTypePieChart(),
                        width: minCardWidth,
                      ),
                      SizedBox(width: 16),
                      _StatCard(
                        title: 'On-Time Completion Rate',
                        child: _CompletionRateChart(),
                        width: minCardWidth,
                      ),
                      SizedBox(width: 16),
                      _StatCard(
                        title: 'Last 30 Days Downtime',
                        child: _DowntimeDisplay(),
                        width: minCardWidth,
                      ),
                    ],
                  ),
                );
              }

              // Otherwise, fill the available width
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Workorders By Status',
                      child: _WorkordersByStatusChart(),
                      width: cardWidth,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Maintenance Type',
                      child: _MaintenanceTypePieChart(),
                      width: cardWidth,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'On-Time Completion Rate',
                      child: _CompletionRateChart(),
                      width: cardWidth,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Last 30 Days Downtime',
                      child: _DowntimeDisplay(),
                      width: cardWidth,
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 24),

          // Bottom Row - Work Orders and Issues
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 900;

              if (isWideScreen) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _OpenWorkordersCard()),
                    SizedBox(width: 16),
                    Expanded(child: _OpenIssuesCard()),
                    SizedBox(width: 16),
                    Expanded(child: _TechnicianWorkloadCard()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _OpenWorkordersCard(),
                    SizedBox(height: 16),
                    _OpenIssuesCard(),
                    SizedBox(height: 16),
                    _TechnicianWorkloadCard(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? width;

  const _StatCard({required this.title, required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 240,
      constraints: BoxConstraints(minWidth: 250),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WorkordersByStatusChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _BarColumn(label: 'Open', value: 85, color: Colors.green, height: 80),
        _BarColumn(label: 'In Progress', value: 120, color: Colors.blue, height: 110),
        _BarColumn(label: 'On-Hold', value: 105, color: Colors.orange, height: 95),
        _BarColumn(label: 'Past Due', value: 135, color: Colors.red, height: 125),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double height;

  const _BarColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MaintenanceTypePieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: 0.7,
                strokeWidth: 20,
                backgroundColor: Colors.green.shade400,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: Colors.blue, label: 'Preventive'),
            SizedBox(height: 8),
            _LegendItem(color: Colors.green.shade400, label: 'Corrective'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }
}

class _CompletionRateChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 120,
        width: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 15,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Text(
              '75%',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _DowntimeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '4.5 hours',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text('across 3 assets', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _OpenWorkordersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Open Workorders',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.help_outline, size: 16, color: Colors.blue.shade300),
            ],
          ),
          SizedBox(height: 16),
          _WorkorderItem(
            priority: 'High',
            priorityColor: Colors.red,
            title: 'Risk of overheating, causing system failure',
            asset: 'Conveyor Belts',
            location: 'Loading Bay',
            avatars: 3,
            dueDate: 'Due in 2 days',
            isAssigned: true,
          ),
          Divider(height: 32),
          _WorkorderItem(
            priority: 'High',
            priorityColor: Colors.red,
            title: 'Leak detected in hydraulic system, reducing efficiency',
            asset: 'Hydraulic Press',
            location: 'Assembly Line',
            avatars: 2,
            dueDate: 'Due in 3 days',
            isAssigned: true,
          ),
        ],
      ),
    );
  }
}

class _OpenIssuesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Open Issues',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.help_outline, size: 16, color: context.colors.primary),
            ],
          ),
          SizedBox(height: 16),
          _IssueItem(
            title: 'Software malfunction leading to inconsistent performance',
            asset: 'Control Panel',
            location: 'Control Room',
            reporter: 'Jamie L.',
            timeAgo: '4 days ago',
            comments: 3,
            isAssigned: true,
          ),
          Divider(height: 32),
          _IssueItem(
            title: 'Frequent voltage fluctuations causing unexpected shutdowns',
            asset: 'Power Distribution Panel',
            location: 'Electrical Room',
            reporter: 'Alex M.',
            timeAgo: '1 day ago',
            comments: 2,
            isAssigned: true,
          ),
        ],
      ),
    );
  }
}

class _TechnicianWorkloadCard extends StatelessWidget {
  final List<Map<String, dynamic>> technicians = [
    {'name': 'Ryan Carter', 'workorders': 12, 'progress': 0.8},
    {'name': 'Jacob Myers', 'workorders': 7, 'progress': 0.6},
    {'name': 'Nathan Brooks', 'workorders': 10, 'progress': 0.7},
    {'name': 'Tyler Dawson', 'workorders': 12, 'progress': 0.85},
    {'name': 'Brandon Ellis', 'workorders': 4, 'progress': 0.9},
    {'name': 'Lucas Hayes', 'workorders': 2, 'progress': 0.3},
    {'name': 'Jordan Parker', 'workorders': 4, 'progress': 0.5},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Technician Workload',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.help_outline, size: 16, color: context.colors.primary),
            ],
          ),
          SizedBox(height: 16),
          ...technicians.map(
            (tech) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _TechnicianWorkloadItem(
                name: tech['name'],
                workorders: tech['workorders'],
                progress: tech['progress'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkorderItem extends StatelessWidget {
  final String priority;
  final Color priorityColor;
  final String title;
  final String asset;
  final String location;
  final int avatars;
  final String dueDate;
  final bool isAssigned;

  const _WorkorderItem({
    required this.priority,
    required this.priorityColor,
    required this.title,
    required this.asset,
    required this.location,
    required this.avatars,
    required this.dueDate,
    required this.isAssigned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                priority,
                style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            if (isAssigned)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Assigned',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey.shade300),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _AvatarStack(count: avatars),
            Spacer(),
            Text(dueDate, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }
}

class _IssueItem extends StatelessWidget {
  final String title;
  final String asset;
  final String location;
  final String reporter;
  final String timeAgo;
  final int comments;
  final bool isAssigned;

  const _IssueItem({
    required this.title,
    required this.asset,
    required this.location,
    required this.reporter,
    required this.timeAgo,
    required this.comments,
    required this.isAssigned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Spacer(),
            if (isAssigned)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Assigned',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey.shade300),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.person_outline, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(reporter, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            SizedBox(width: 16),
            Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Spacer(),
            Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text('$comments', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }
}

class _TechnicianWorkloadItem extends StatelessWidget {
  final String name;
  final int workorders;
  final double progress;

  const _TechnicianWorkloadItem({
    required this.name,
    required this.workorders,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade100,
          child: Text(name[0], style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Text(
          '$workorders WOs',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final int count;

  const _AvatarStack({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: count * 20.0 + 10,
      height: 30,
      child: Stack(
        children: List.generate(count, (index) {
          return Positioned(
            left: index * 20.0,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.primaries[index % Colors.primaries.length],
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          );
        }),
      ),
    );
  }
}
