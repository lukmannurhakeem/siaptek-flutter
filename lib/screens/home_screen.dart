import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/menu_item.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/screens/dashboard/dashboard_screen.dart';
import 'package:base_app/screens/planner_screen.dart';
import 'package:base_app/widget/welcome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool showWelcomeDialog;
  final String? userName;

  const HomeScreen({
    super.key,
    this.showWelcomeDialog = false,
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define all menu items
  final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.home,
      index: 0,
      screen: DashboardScreen(),
    ),
    MenuItem(
      title: 'Planner',
      icon: Icons.calendar_month,
      index: 1,
      screen: PlannerScreen(),
    ),
    MenuItem(
      title: 'Jobs',
      icon: Icons.work,
      index: 2,
      screen: Center(child: Text("Jobs Content")),
    ),
    MenuItem(
      title: 'Personnel',
      icon: Icons.card_membership_rounded,
      index: 3,
      screen: Center(child: Text("Personnel Content")),
    ),
    MenuItem(
      title: 'Customer',
      icon: Icons.dashboard_customize_rounded,
      index: 4,
      screen: Center(child: Text("Customer Content")),
    ),
    MenuItem(
      title: 'Sites',
      icon: Icons.apartment,
      index: 5,
      screen: Center(child: Text("Sites Content")),
    ),
    MenuItem(
      title: 'Categories',
      icon: Icons.category,
      index: 6,
      screen: Center(child: Text("Categories Content")),
    ),
    MenuItem(
      title: 'Profile',
      icon: Icons.person,
      index: 7,
      screen: Center(child: Text("Profile Content")),
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      index: 8,
      screen: Center(child: Text("Settings Content")),
    ),
  ];

  // Get current menu item
  MenuItem get _currentMenuItem => _menuItems.firstWhere(
        (item) => item.index == _selectedIndex,
        orElse: () => _menuItems[0],
      );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showWelcomeDialog) {
        WelcomeDialog.show(
          context,
          userName: widget.userName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentMenuItem.title,
          style: context.topology.textTheme.titleLarge?.copyWith(
            color: context.colors.onPrimary,
          ),
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
              // Generate menu items dynamically
              ..._menuItems
                  .map((menuItem) => [
                        ListTile(
                          splashColor: context.colors.primary.withOpacity(0.5),
                          leading: Icon(
                            menuItem.icon,
                            color: context.colors.primary,
                          ),
                          title: Text(
                            menuItem.title,
                            style: context.topology.textTheme.bodyLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          selected: _selectedIndex == menuItem.index,
                          selectedTileColor: context.colors.primary.withOpacity(0.1),
                          onTap: () {
                            setState(() => _selectedIndex = menuItem.index);
                            NavigationService().goBack();
                          },
                        ),
                        context.divider,
                      ])
                  .expand((x) => x)
                  .toList(),

              // Logout item (special case)
              Consumer<AuthenticateProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    splashColor: context.colors.primary.withOpacity(0.5),
                    leading: Icon(
                      Icons.logout,
                      color: context.colors.primary,
                    ),
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
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: _getBodyContent(),
        ),
      ),
    );
  }

  Widget _getBodyContent() {
    return _currentMenuItem.screen ?? Center(child: Text("${_currentMenuItem.title} Content"));
  }
}
