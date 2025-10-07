import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/menu_item.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/screens/categories/categories_screen.dart';
import 'package:base_app/screens/customer/customer_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_screen.dart';
import 'package:base_app/screens/job/job_add_new_screen.dart';
import 'package:base_app/screens/job/job_screen.dart';
import 'package:base_app/screens/personnel/personnel_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_screen.dart';
import 'package:base_app/screens/planner/planner_screen.dart';
import 'package:base_app/screens/planner/team_planner_screen.dart';
import 'package:base_app/screens/profile/profile_screen.dart';
import 'package:base_app/screens/settings/access/acccess_view_screen.dart';
import 'package:base_app/screens/settings/company/division_screen.dart';
import 'package:base_app/screens/settings/report_setup/report_types_screen.dart';
import 'package:base_app/screens/site/site_screen.dart';
import 'package:base_app/widget/welcome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool showWelcomeDialog;
  final String? userName;

  const HomeScreen({super.key, this.showWelcomeDialog = false, this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Track expanded menu items (by index)
  final Set<int> _expandedMenus = {};

  // Get all menu items
  List<MenuItem> get _allMenuItems => [
    MenuItem(title: 'Dashboard', icon: Icons.home, index: 0, screen: DashboardScreen()),
    MenuItem(
      title: 'Planner',
      icon: Icons.calendar_month,
      index: 1,
      children: [
        MenuItem(
          title: 'Individual Planner',
          icon: Icons.person,
          index: 10,
          screen: PlannerScreen(),
        ),
        MenuItem(title: 'Team Planner', icon: Icons.groups, index: 11, screen: TeamPlannerScreen()),
      ],
    ),
    MenuItem(
      title: 'Jobs',
      icon: Icons.work,
      index: 2,
      children: [
        MenuItem(title: 'View All', icon: Icons.view_array, index: 12, screen: JobScreen()),
        MenuItem(title: 'Add New', icon: Icons.add, index: 13, screen: JobAddNewScreen()),
      ],
    ),
    MenuItem(
      title: 'Personnel',
      icon: Icons.card_membership_rounded,
      index: 3,
      children: [
        MenuItem(
          title: 'Personnel Records',
          icon: Icons.view_array,
          index: 14,
          screen: PersonnelScreen(),
        ),
        MenuItem(title: 'Teams', icon: Icons.add, index: 15, screen: PersonnelTeamScreen()),
      ],
    ),
    MenuItem(
      title: 'Customer',
      icon: Icons.dashboard_customize_rounded,
      index: 4,
      screen: Center(child: CustomerScreen()),
    ),
    MenuItem(title: 'Sites', icon: Icons.apartment, index: 5, screen: Center(child: SiteScreen())),
    MenuItem(
      title: 'Categories',
      icon: Icons.category,
      index: 6,
      screen: Center(child: CategoriesScreen()),
    ),
    MenuItem(
      title: 'Profile',
      icon: Icons.person,
      index: 7,
      screen: Center(child: ProfileScreen()),
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      index: 8,
      children: [
        MenuItem(
          title: 'Report Setup',
          icon: Icons.report,
          index: 17,
          children: [
            MenuItem(
              title: 'Report Type',
              icon: Icons.view_array,
              index: 24,
              screen: ReportTypeScreen(),
            ),
          ],
        ),
        MenuItem(
          title: 'Company',
          icon: Icons.meeting_room,
          index: 18,
          children: [
            MenuItem(
              title: 'Divisions',
              icon: Icons.view_array,
              index: 22,
              screen: CompanyDivisionScreen(),
            ),
          ],
        ),
        MenuItem(
          title: 'Access',
          icon: Icons.accessibility,
          index: 19,
          children: [
            MenuItem(
              title: 'Logins',
              icon: Icons.view_array,
              index: 20,
              screen: AccessViewScreen(),
            ),
          ],
        ),
      ],
    ),
  ];

  // Filter menu items based on user role
  List<MenuItem> _getFilteredMenuItems(String userGroup) {
    final isAdmin = userGroup.toLowerCase() == 'admin';
    print('Henlo : ${userGroup.toLowerCase()}');

    // Non-admin users only see Dashboard, Planner, and Jobs
    // if (!isAdmin) {
    //   return _allMenuItems.take(3).toList();
    // }

    // Admin users see all menu items
    return _allMenuItems;
  }

  MenuItem? _getCurrentMenuItem(List<MenuItem> menuItems) {
    MenuItem? findItem(List<MenuItem> items, int index) {
      for (final item in items) {
        if (item.index == index) return item;
        if (item.children != null) {
          final found = findItem(item.children!, index);
          if (found != null) return found;
        }
      }
      return null;
    }

    return findItem(menuItems, _selectedIndex) ?? menuItems.first;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showWelcomeDialog) {
        WelcomeDialog.show(context, userName: widget.userName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticateProvider>(
      builder: (context, authProvider, child) {
        final userGroup = authProvider.userGroup;
        final isAdmin = userGroup.toLowerCase() == 'admin';
        final menuItems = _getFilteredMenuItems(userGroup);
        final currentMenuItem = _getCurrentMenuItem(menuItems);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              currentMenuItem?.title ?? '',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: context.colors.primary),
            backgroundColor: context.colors.onPrimary,
          ),
          drawer: Drawer(
            child: SafeArea(
              top: true,
              child: ListView(
                padding: context.paddingAll,
                children: [
                  // User info header
                  if (authProvider.user != null)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${authProvider.user?.user?.firstName ?? ''} ${authProvider.user?.user?.lastName ?? ''}'
                                .trim(),
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authProvider.user?.user?.email ?? '',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  isAdmin
                                      ? context.colors.primary.withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isAdmin ? context.colors.primary : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isAdmin ? 'Admin' : 'User',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  context.divider,

                  // Menu items
                  ..._buildMenuList(menuItems),

                  // Logout
                  ListTile(
                    splashColor: context.colors.primary.withOpacity(0.5),
                    leading: Icon(Icons.logout, color: context.colors.primary),
                    title: Text(
                      'Logout',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onTap: () {
                      authProvider.logout(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(child: _getBodyContent(currentMenuItem)),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuList(List<MenuItem> items, {int indent = 0}) {
    return items.expand((item) {
      final bool isSelected = _selectedIndex == item.index;
      final bool isExpanded = _expandedMenus.contains(item.index);

      List<Widget> tiles = [
        Padding(
          padding: EdgeInsets.only(left: (indent * 16).toDouble()),
          child: ListTile(
            splashColor: context.colors.primary.withOpacity(0.5),
            leading: Icon(item.icon, color: context.colors.primary),
            title: Text(
              item.title,
              style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
            ),
            selected: isSelected,
            selectedTileColor: context.colors.primary.withOpacity(0.1),
            trailing:
                item.children != null
                    ? Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: context.colors.primary,
                    )
                    : null,
            onTap: () {
              if (item.children != null) {
                setState(() {
                  if (isExpanded) {
                    _expandedMenus.remove(item.index);
                  } else {
                    _expandedMenus.add(item.index);
                  }
                });
              } else {
                setState(() => _selectedIndex = item.index);
                NavigationService().goBack();
              }
            },
          ),
        ),
      ];

      if (item.children != null && isExpanded) {
        tiles.addAll(_buildMenuList(item.children!, indent: indent + 1));
      }

      if (indent == 0) {
        tiles.add(context.divider);
      }

      return tiles;
    }).toList();
  }

  Widget _getBodyContent(MenuItem? currentMenuItem) {
    return currentMenuItem?.screen ?? Center(child: Text("${currentMenuItem?.title} Content"));
  }
}
