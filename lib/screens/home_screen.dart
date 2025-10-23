import 'package:base_app/core/extension/theme_extension.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Set<int> _expandedMenus = {};
  bool _isSidebarExpanded = true;

  late AnimationController _animationController;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showWelcomeDialog) {
        WelcomeDialog.show(context, userName: widget.userName);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<MenuItem> _getFilteredMenuItems(String userGroup) {
    final isAdmin = userGroup.toLowerCase() == 'admin';
    print('Henlo : ${userGroup.toLowerCase()}');
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

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      if (_isSidebarExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
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
          appBar:
              (currentMenuItem?.title == 'Dashboard')
                  ? null
                  : AppBar(
                    automaticallyImplyLeading: false,
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
          body: Row(
            children: [
              // Animated Sidebar
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isSidebarExpanded ? 280 : 80,
                color: context.colors.onPrimary,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Logo Section
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        child:
                            _isSidebarExpanded
                                ? Image.asset(
                                  'assets/images/logo.jpg', // Replace with your logo path
                                  height: 60,
                                  fit: BoxFit.contain,
                                )
                                : Image.asset(
                                  'assets/images/logo_small.jpg', // Replace with your icon/small logo path
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                      ),
                      Divider(height: 1),

                      // Toggle Button
                      Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(
                            _isSidebarExpanded ? Icons.menu_open : Icons.menu,
                            color: context.colors.primary,
                          ),
                          onPressed: _toggleSidebar,
                        ),
                      ),
                      Divider(height: 1),

                      // User Info Header (only visible when expanded)
                      if (authProvider.user != null && _isSidebarExpanded)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${authProvider.user?.user?.firstName ?? ''} ${authProvider.user?.user?.lastName ?? ''}'
                                    .trim(),
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                authProvider.user?.user?.email ?? '',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      if (_isSidebarExpanded) Divider(height: 1),

                      // Menu Items
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          children: _buildMenuList(menuItems),
                        ),
                      ),

                      Divider(height: 1),

                      // Logout
                      Container(
                        height: 56,
                        child: Tooltip(
                          message: 'Logout',
                          child: ListTile(
                            splashColor: context.colors.primary.withOpacity(0.5),
                            leading: Icon(Icons.logout, color: context.colors.primary),
                            title:
                                _isSidebarExpanded
                                    ? Text(
                                      'Logout',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    )
                                    : null,
                            dense: true,
                            onTap: () {
                              authProvider.logout(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: SafeArea(
                  top: true,
                  child: SingleChildScrollView(child: _getBodyContent(currentMenuItem)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuList(List<MenuItem> items, {int indent = 0}) {
    return items.expand((item) {
      final bool isSelected = _selectedIndex == item.index;
      final bool isExpanded = _expandedMenus.contains(item.index);
      final bool hasChildren = item.children != null;

      List<Widget> tiles = [
        Padding(
          padding: EdgeInsets.only(left: _isSidebarExpanded ? (indent * 16).toDouble() : 0),
          child:
              hasChildren && !_isSidebarExpanded
                  ? _buildCollapsedMenuWithPopup(item, isExpanded)
                  : Tooltip(
                    message: _isSidebarExpanded ? '' : item.title,
                    child: ListTile(
                      splashColor: context.colors.primary.withOpacity(0.5),
                      leading: Icon(item.icon, color: context.colors.primary),
                      title:
                          _isSidebarExpanded
                              ? Text(
                                item.title,
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                              : null,
                      selected: isSelected,
                      selectedTileColor: context.colors.primary.withOpacity(0.1),
                      trailing:
                          _isSidebarExpanded && hasChildren
                              ? Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: context.colors.primary,
                              )
                              : null,
                      dense: true,
                      onTap: () {
                        setState(() {
                          if (hasChildren && _isSidebarExpanded) {
                            // Toggle expansion for parent items when sidebar is expanded
                            if (isExpanded) {
                              _expandedMenus.remove(item.index);
                            } else {
                              _expandedMenus.add(item.index);
                            }
                          } else if (!hasChildren) {
                            // Navigate for leaf items
                            _selectedIndex = item.index;
                          }
                        });
                      },
                    ),
                  ),
        ),
      ];

      if (hasChildren && isExpanded && _isSidebarExpanded) {
        tiles.addAll(_buildMenuList(item.children!, indent: indent + 1));
      }

      return tiles;
    }).toList();
  }

  Widget _buildCollapsedMenuWithPopup(MenuItem item, bool isExpanded) {
    return PopupMenuButton<MenuItem>(
      onSelected: (selectedItem) {
        setState(() {
          _selectedIndex = selectedItem.index;
        });
      },
      itemBuilder: (BuildContext context) {
        return _buildPopupMenuItems(item.children ?? []);
      },
      child: Tooltip(
        message: item.title,
        child: ListTile(
          splashColor: context.colors.primary.withOpacity(0.5),
          leading: Icon(item.icon, color: context.colors.primary),
          dense: true,
        ),
      ),
    );
  }

  List<PopupMenuEntry<MenuItem>> _buildPopupMenuItems(List<MenuItem> items) {
    return items.map((item) {
      if (item.children != null && item.children!.isNotEmpty) {
        return PopupMenuItem<MenuItem>(
          child: PopupMenuButton<MenuItem>(
            onSelected: (selectedItem) {
              setState(() {
                _selectedIndex = selectedItem.index;
              });
            },
            itemBuilder: (BuildContext context) {
              return _buildPopupMenuItems(item.children!);
            },
            child: Row(
              children: [
                Icon(item.icon, color: context.colors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  item.title,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_right, color: context.colors.primary, size: 16),
              ],
            ),
          ),
        );
      } else {
        return PopupMenuItem<MenuItem>(
          value: item,
          child: Row(
            children: [
              Icon(item.icon, color: context.colors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                item.title,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _getBodyContent(MenuItem? currentMenuItem) {
    return currentMenuItem?.screen ?? Center(child: Text("${currentMenuItem?.title} Content"));
  }
}
