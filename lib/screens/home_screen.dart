import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/menu_item.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/screens/categories/categories_screen.dart';
import 'package:base_app/screens/customer/customer_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_screen.dart';
import 'package:base_app/screens/job/job_screen.dart';
import 'package:base_app/screens/personnel/personnel_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_screen.dart';
import 'package:base_app/screens/planner/planner_screen.dart';
import 'package:base_app/screens/planner/team_planner_screen.dart';
import 'package:base_app/screens/profile/profile_screen.dart';
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

  final List<MenuItem> _menuItems = [
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
        MenuItem(title: 'Add New', icon: Icons.add, index: 13, screen: TeamPlannerScreen()),
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
      screen: Center(child: Text("Settings Content")),
    ),
  ];

  MenuItem? get _currentMenuItem {
    for (final item in _menuItems) {
      if (item.index == _selectedIndex) return item;
      if (item.children != null) {
        for (final sub in item.children!) {
          if (sub.index == _selectedIndex) return sub;
        }
      }
    }
    return _menuItems[0];
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentMenuItem?.title ?? '',
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.onPrimary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.onPrimary),
        backgroundColor: context.colors.primary,
      ),
      drawer: Drawer(
        child: SafeArea(
          top: true,
          child: ListView(
            padding: context.paddingAll,
            children: [
              ..._buildMenuList(_menuItems),

              // Logout
              Consumer<AuthenticateProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    splashColor: context.colors.primary.withOpacity(0.5),
                    leading: Icon(Icons.logout, color: context.colors.primary),
                    title: Text(
                      'Logout',
                      style: context.topology.textTheme.bodyLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onTap: () {
                      provider.logout(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(top: true, child: SingleChildScrollView(child: _getBodyContent())),
    );
  }

  List<Widget> _buildMenuList(List<MenuItem> items) {
    return items.expand((item) {
      final bool isSelected = _selectedIndex == item.index;
      final bool isExpanded = _expandedMenus.contains(item.index);

      List<Widget> tiles = [
        ListTile(
          splashColor: context.colors.primary.withOpacity(0.5),
          leading: Icon(item.icon, color: context.colors.primary),
          title: Text(
            item.title,
            style: context.topology.textTheme.bodyLarge?.copyWith(color: context.colors.primary),
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
      ];

      if (item.children != null && isExpanded) {
        tiles.addAll(
          item.children!.map((subItem) {
            return Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: ListTile(
                leading: Icon(subItem.icon, color: context.colors.primary),
                title: Text(
                  subItem.title,
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                selected: _selectedIndex == subItem.index,
                selectedTileColor: context.colors.primary.withOpacity(0.1),
                onTap: () {
                  setState(() => _selectedIndex = subItem.index);
                  NavigationService().goBack();
                },
              ),
            );
          }),
        );
      }

      tiles.add(context.divider);
      return tiles;
    }).toList();
  }

  Widget _getBodyContent() {
    return _currentMenuItem?.screen ?? Center(child: Text("${_currentMenuItem?.title} Content"));
  }
}
