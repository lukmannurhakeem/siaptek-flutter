import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/local_storage.dart';
import 'package:INSPECT/core/service/local_storage_constant.dart';
import 'package:INSPECT/providers/authenticate_provider.dart';
import 'package:INSPECT/providers/customer_provider.dart';
import 'package:INSPECT/providers/notification_provider.dart';
import 'package:INSPECT/providers/site_provider.dart';
import 'package:INSPECT/screens/notification/notification_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String? _selectedCustomerId;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _statistics;
  List<dynamic>? _items;
  bool _isDashboardLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _loadUserData();
    _initializeData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final firstName = await LocalStorageService.getString(LocalStorageConstant.userFirstName) ?? '';
    final lastName = await LocalStorageService.getString(LocalStorageConstant.userLastName) ?? '';
    final email = await LocalStorageService.getString(LocalStorageConstant.userEmail) ?? '';

    if (mounted) {
      setState(() {
        _firstName = firstName;
        _lastName = lastName;
        _email = email;
      });
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final customerProvider = context.read<CustomerProvider>();
    await customerProvider.fetchCustomers(context);

    if (customerProvider.customers.isNotEmpty) {
      final firstCustomerId = customerProvider.customers.first.customerid;
      if (firstCustomerId != null) {
        await _loadDashboardData(firstCustomerId);
      }
    }
  }

  Future<void> _loadDashboardData(String customerId) async {
    if (_selectedCustomerId == customerId && _dashboardData != null) {
      return;
    }

    setState(() {
      _isDashboardLoading = true;
      _selectedCustomerId = customerId;
    });

    try {
      final customerProvider = context.read<CustomerProvider>();
      final repository = customerProvider.customerRepository;

      final dashboardResult = await repository.getDashboardCustomer(customerId);
      final statisticsResult = await repository.getDashboardStatistic(customerId);
      final itemsResult = await repository.getDashboardItems(customerId);

      if (mounted) {
        setState(() {
          _dashboardData = dashboardResult['data'];
          _statistics = statisticsResult['data'];
          _items = itemsResult['data'] as List<dynamic>?;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDashboardLoading = false;
        });
      }
    }
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                  vertical: isDesktop ? 24 : 16,
                ),
                child: _buildHeader(isDesktop, isTablet),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : (isTablet ? 24 : 16)),
                child:
                    _isDashboardLoading && _dashboardData == null
                        ? _buildLoadingState()
                        : _dashboardData == null
                        ? _buildEmptyState()
                        : FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildDashboardContent(isDesktop, isTablet),
                        ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          isDesktop
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUserInfo(),
                  const SizedBox(width: 24),
                  _buildHeaderActions(isDesktop),
                ],
              )
              : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildUserInfo(), _buildWebSocketStatus()],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildNotificationButton(),
                      const SizedBox(width: 12),
                      Expanded(child: _buildCustomerDropdown()),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_firstName $_lastName'.trim(),
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _email,
              style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions(bool isDesktop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWebSocketStatus(),
        const SizedBox(width: 16),
        _buildNotificationButton(),
        const SizedBox(width: 16),
        SizedBox(width: isDesktop ? 280 : 200, child: _buildCustomerDropdown()),
      ],
    );
  }

  Widget _buildWebSocketStatus() {
    return Consumer<AuthenticateProvider>(
      builder: (context, authProvider, child) {
        final isConnected = authProvider.isWebSocketConnected;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isConnected
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.grey.shade400, Colors.grey.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isConnected ? Colors.green : Colors.grey).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'Live' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotificationPanel(context),
                color: context.colors.primary,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 6)],
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerDropdown() {
    return Consumer2<CustomerProvider, SiteProvider>(
      builder: (context, customerProvider, siteProvider, _) {
        final customers = customerProvider.customers;
        final isFetching = customerProvider.isFetching;

        if (isFetching && customers.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading...',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: siteProvider.selectedCustomerId,
          decoration: InputDecoration(
            hintText: 'Select Customer',
            prefixIcon: Icon(Icons.business_rounded, color: context.colors.primary),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items:
              customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.customerid,
                  child: Text(
                    customer.customername ?? '-',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              siteProvider.setSelectedCustomer(value);
              _loadDashboardData(value);
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading dashboard...',
              style: context.topology.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_3.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomLeft,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'No customer found',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a customer to view dashboard data',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CustomerInfoCard(customer: _dashboardData?['customer']),
        const SizedBox(height: 24),
        _buildStatisticsGrid(isDesktop, isTablet),
        const SizedBox(height: 24),
        _buildDataGrid(isDesktop, isTablet),
      ],
    );
  }

  Widget _buildStatisticsGrid(bool isDesktop, bool isTablet) {
    final stats = [
      _StatData(
        title: 'Total Sites',
        value: '${_statistics?['totalSites'] ?? 0}',
        subtitle: 'Active: ${_statistics?['activeSites'] ?? 0}',
        icon: Icons.location_city_rounded,
        color: Colors.blue,
      ),
      _StatData(
        title: 'Total Items',
        value: '${_statistics?['totalItems'] ?? 0}',
        subtitle: 'Active: ${_statistics?['activeItems'] ?? 0}',
        icon: Icons.inventory_2_rounded,
        color: Colors.green,
      ),
      _StatData(
        title: 'Total Reports',
        value: '${_statistics?['totalReports'] ?? 0}',
        subtitle: 'Pending: ${_statistics?['pendingReports'] ?? 0}',
        icon: Icons.description_rounded,
        color: Colors.orange,
      ),
      _StatData(
        title: 'Total Jobs',
        value: '${_statistics?['totalJobs'] ?? 0}',
        subtitle: 'Active: ${_statistics?['activeJobs'] ?? 0}',
        icon: Icons.work_rounded,
        color: Colors.purple,
      ),
    ];

    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.5 : 2.5),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _StatCard(stat: stats[index]),
    );
  }

  Widget _buildDataGrid(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SitesCard(sites: _dashboardData?['sites'])),
          const SizedBox(width: 16),
          Expanded(child: _ItemsCard(items: _items)),
          const SizedBox(width: 16),
          Expanded(child: _ReportsCard(reports: _dashboardData?['reports'])),
        ],
      );
    }

    return Column(
      children: [
        _SitesCard(sites: _dashboardData?['sites']),
        const SizedBox(height: 16),
        _ItemsCard(items: _items),
        const SizedBox(height: 16),
        _ReportsCard(reports: _dashboardData?['reports']),
      ],
    );
  }
}

// Helper class for stat data
class _StatData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _StatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// Customer Info Card Widget
class _CustomerInfoCard extends StatelessWidget {
  final Map<String, dynamic>? customer;

  const _CustomerInfoCard({this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withOpacity(0.1),
                  context.colors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 2),
            ),
            child:
                customer?['logo'] != null && customer!['logo'].toString().isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        customer!['logo'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Icon(
                              Icons.business_rounded,
                              size: 36,
                              color: context.colors.primary,
                            ),
                      ),
                    )
                    : Icon(Icons.business_rounded, size: 36, color: context.colors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?['customerName'] ?? 'Unknown',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(icon: Icons.tag_rounded, label: customer?['customerId'] ?? '-'),
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.category_rounded, label: customer?['division'] ?? '-'),
                  ],
                ),
                if (customer?['address'] != null && customer!['address'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer!['address'],
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final _StatData stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat.title,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, size: 24, color: stat.color),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stat.color),
              ),
              const SizedBox(height: 4),
              Text(stat.subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

// Sites Card Widget
class _SitesCard extends StatelessWidget {
  final List<dynamic>? sites;

  const _SitesCard({this.sites});

  @override
  Widget build(BuildContext context) {
    final sitesList = sites ?? [];

    return _DataCard(
      title: 'Sites',
      icon: Icons.location_city_rounded,
      count: sitesList.length,
      color: Colors.blue,
      children:
          sitesList.isEmpty
              ? [const _EmptyMessage(message: 'No sites found')]
              : sitesList.take(5).map((site) => _SiteItem(site: site)).toList(),
    );
  }
}

// Items Card Widget
class _ItemsCard extends StatelessWidget {
  final List<dynamic>? items;

  const _ItemsCard({this.items});

  @override
  Widget build(BuildContext context) {
    final itemsList = items ?? [];

    return _DataCard(
      title: 'Items',
      icon: Icons.inventory_2_rounded,
      count: itemsList.length,
      color: Colors.green,
      children:
          itemsList.isEmpty
              ? [const _EmptyMessage(message: 'No items found')]
              : itemsList.take(5).map((item) => _ItemItem(item: item)).toList(),
    );
  }
}

// Reports Card Widget
class _ReportsCard extends StatelessWidget {
  final List<dynamic>? reports;

  const _ReportsCard({this.reports});

  @override
  Widget build(BuildContext context) {
    final reportsList = reports ?? [];

    return _DataCard(
      title: 'Recent Reports',
      icon: Icons.description_rounded,
      count: reportsList.length,
      color: Colors.orange,
      children:
          reportsList.isEmpty
              ? [const _EmptyMessage(message: 'No reports found')]
              : reportsList.take(5).map((report) => _ReportItem(report: report)).toList(),
    );
  }
}
// Add these widgets to complete the dashboard

// Site Item Widget
class _SiteItem extends StatelessWidget {
  final Map<String, dynamic> site;

  const _SiteItem({required this.site});

  @override
  Widget build(BuildContext context) {
    final isArchived = site['archived'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  site['siteName'] ?? 'Unknown Site',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isArchived
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: (isArchived ? Colors.red : Colors.green).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isArchived ? 'Archived' : 'Active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.qr_code_rounded, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                site['siteCode'] ?? '-',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (site['address'] != null && site['address'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      site['address'],
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Item Item Widget
class _ItemItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemItem({required this.item});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = item['status'];
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['itemNo'] ?? 'Unknown Item',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status ?? 'Unknown',
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['description'] ?? 'No description',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_rounded, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    item['categoryName'] ?? '-',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.numbers_rounded, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'SN: ${item['serialNumber'] ?? '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Report Item Widget
class _ReportItem extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportItem({required this.report});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  bool _isExpiringSoon(String? expiryDate) {
    if (expiryDate == null) return false;
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference >= 0 && difference <= 30;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = report['status'];
    final statusColor = _getStatusColor(status);
    final expiryDate = report['expiryDate'];
    final isExpiring = _isExpiringSoon(expiryDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiring ? Colors.orange.shade200 : Colors.grey.shade200,
          width: isExpiring ? 2 : 1,
        ),
        boxShadow:
            isExpiring
                ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report['reportTypeName'] ?? 'Unknown Report',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.inventory_2_rounded, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report['itemNo'] ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_rounded, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report['inspectedBy'] ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              Text(
                _formatDate(report['reportDate']),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (expiryDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient:
                      isExpiring
                          ? LinearGradient(colors: [Colors.orange.shade50, Colors.orange.shade100])
                          : null,
                  color: isExpiring ? null : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isExpiring ? Colors.orange.shade300 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpiring ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
                      size: 14,
                      color: isExpiring ? Colors.orange.shade700 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expires: ${_formatDate(expiryDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpiring ? Colors.orange.shade800 : Colors.grey.shade600,
                        fontWeight: isExpiring ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isExpiring) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SOON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Data Card Container Widget
class _DataCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final List<Widget> children;

  const _DataCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children.map(
            (child) => Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
          ),
        ],
      ),
    );
  }
}

// Empty Message Widget
class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
