import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/get_company_division.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dialog.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_snackbar.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DivisionSearchColumn { name, code, email, phone, timezone }

class CompanyDivisionScreen extends StatefulWidget {
  const CompanyDivisionScreen({super.key});

  @override
  State<CompanyDivisionScreen> createState() => _CompanyDivisionScreenState();
}

class _CompanyDivisionScreenState extends State<CompanyDivisionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DivisionSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchDivision();
      _animationController.forward();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<dynamic> _getColumnValues(List<GetCompanyDivision> divisions, DivisionSearchColumn column) {
    if (divisions.isEmpty) return [];

    switch (column) {
      case DivisionSearchColumn.name:
        return divisions
            .map((e) => e.divisionname ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case DivisionSearchColumn.code:
        return divisions
            .map((e) => e.divisioncode ?? '')
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case DivisionSearchColumn.email:
        return divisions
            .map((e) => e.email ?? '')
            .where((email) => email.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case DivisionSearchColumn.phone:
        return divisions
            .map((e) => e.telephone ?? '')
            .where((phone) => phone.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case DivisionSearchColumn.timezone:
        return divisions.map((e) => e.timezone ?? '').where((tz) => tz.isNotEmpty).toSet().toList()
          ..sort();
    }
  }

  List<GetCompanyDivision> _getFilteredDivisions(List<GetCompanyDivision> divisions) {
    if (divisions.isEmpty) return [];

    var filteredList = divisions;

    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((division) {
            final name = (division.divisionname ?? '').toLowerCase();
            final code = (division.divisioncode ?? '').toLowerCase();
            final email = (division.email ?? '').toLowerCase();
            final phone = (division.telephone ?? '').toLowerCase();
            final address = (division.address ?? '').toLowerCase();

            return name.contains(searchText) ||
                code.contains(searchText) ||
                email.contains(searchText) ||
                phone.contains(searchText) ||
                address.contains(searchText);
          }).toList();
    }

    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case DivisionSearchColumn.name:
          filteredList = filteredList.where((div) => div.divisionname == selectedValue).toList();
          break;
        case DivisionSearchColumn.code:
          filteredList = filteredList.where((div) => div.divisioncode == selectedValue).toList();
          break;
        case DivisionSearchColumn.email:
          filteredList = filteredList.where((div) => div.email == selectedValue).toList();
          break;
        case DivisionSearchColumn.phone:
          filteredList = filteredList.where((div) => div.telephone == selectedValue).toList();
          break;
        case DivisionSearchColumn.timezone:
          filteredList = filteredList.where((div) => div.timezone == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(DivisionSearchColumn column) {
    switch (column) {
      case DivisionSearchColumn.name:
        return 'Division Name';
      case DivisionSearchColumn.code:
        return 'Division Code';
      case DivisionSearchColumn.email:
        return 'Email';
      case DivisionSearchColumn.phone:
        return 'Phone';
      case DivisionSearchColumn.timezone:
        return 'Timezone';
    }
  }

  void _showFilterDialog(BuildContext context, List<GetCompanyDivision> divisions) {
    DivisionSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(divisions, tempColumn!) : <dynamic>[];

          return SizedBox(
            height: context.screenHeight / 3.5,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Filter By',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonDropdown<DivisionSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<DivisionSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...DivisionSearchColumn.values.map((column) {
                            return DropdownMenuItem<DivisionSearchColumn>(
                              value: column,
                              child: Text(
                                _getColumnLabel(column),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempColumn = value;
                            tempValue = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Value',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child:
                          tempColumn == null
                              ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.colors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Select a column first',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary.withOpacity(0.5),
                                  ),
                                ),
                              )
                              : CommonDropdown<dynamic>(
                                value: tempValue,
                                items: [
                                  DropdownMenuItem<dynamic>(
                                    value: null,
                                    child: Text(
                                      'All',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  ...columnValues.map((value) {
                                    return DropdownMenuItem<dynamic>(
                                      value: value,
                                      child: Text(
                                        value.toString(),
                                        style: context.topology.textTheme.bodySmall?.copyWith(
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setDialogState(() {
                                    tempValue = value;
                                  });
                                },
                              ),
                    ),
                  ],
                ),
                context.vL,
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Clear',
                        onPressed: () {
                          setState(() {
                            selectedColumn = null;
                            selectedValue = null;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                    context.hS,
                    Expanded(
                      child: CommonButton(
                        text: 'Apply',
                        onPressed: () {
                          setState(() {
                            selectedColumn = tempColumn;
                            selectedValue = tempValue;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasData) {
          return _buildLoadingState();
        }

        if (provider.hasError && !provider.hasData) {
          return _buildErrorState(context, provider);
        }

        final allDivisions = provider.divisions;
        final filteredDivisions = _getFilteredDivisions(allDivisions);

        if (allDivisions.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildMainLayout(context, filteredDivisions, allDivisions);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            'Loading divisions...',
            style: context.topology.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Background image at bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_2.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              height: context.screenHeight * 0.70,
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                context.vXxl,
                Text(
                  'No divisions yet',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create your first division to get started',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    NavigationService().navigateTo(AppRoutes.companyCreateDivision);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Division'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SystemProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Background image at bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_2.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              height: context.screenHeight * 0.70,
            ),
          ),
          // Foreground content
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Failed to load divisions',
                    style: context.topology.textTheme.titleLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      provider.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style: context.topology.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchDivision(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Replace the placeholder _buildMainLayout method in Part 1

  Widget _buildMainLayout(
    BuildContext context,
    List<GetCompanyDivision> filteredDivisions,
    List<GetCompanyDivision> allDivisions,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSection(isDesktop, isTablet),
                const SizedBox(height: 24),
                _buildSearchBar(allDivisions, isDesktop),
                const SizedBox(height: 16),
                _buildFilterChips(isDesktop),
                const SizedBox(height: 16),
                _buildResultsCount(filteredDivisions),
                const SizedBox(height: 16),
                Expanded(child: _buildDivisionsList(filteredDivisions, isDesktop, isTablet)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          filteredDivisions.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.companyCreateDivision);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(isDesktop ? 'Create Division' : 'Create'),
                backgroundColor: context.colors.primary,
                elevation: 4,
              )
              : null,
    );
  }

  Widget _buildHeaderSection(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Divisions',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your organization divisions',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            ElevatedButton.icon(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.companyCreateDivision);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Division'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<GetCompanyDivision> allDivisions, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CommonTextField(
        controller: _searchController,
        hintText:
            isDesktop
                ? 'Search by division name, code, email, phone, or address...'
                : 'Search divisions...',
        style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        prefixIcon: Icon(Icons.search_rounded, color: context.colors.primary.withOpacity(0.6)),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear_rounded, color: context.colors.primary),
                onPressed: () {
                  _searchController.clear();
                },
                tooltip: 'Clear search',
              ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    (selectedColumn != null && selectedValue != null)
                        ? context.colors.primary.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color:
                      (selectedColumn != null && selectedValue != null)
                          ? context.colors.primary
                          : context.colors.primary.withOpacity(0.5),
                ),
                onPressed: () => _showFilterDialog(context, allDivisions),
                tooltip: 'Filter divisions',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDesktop) {
    if (selectedColumn == null || selectedValue == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withOpacity(0.1),
                context.colors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt_rounded, size: 16, color: context.colors.primary),
              const SizedBox(width: 6),
              Text(
                '${_getColumnLabel(selectedColumn!)}: $selectedValue',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColumn = null;
                    selectedValue = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 14, color: context.colors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCount(List<GetCompanyDivision> filteredDivisions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business_rounded, size: 16, color: context.colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${filteredDivisions.length} ${filteredDivisions.length == 1 ? 'division' : 'divisions'}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Consumer<SystemProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(Icons.refresh_rounded, color: context.colors.primary),
                onPressed: provider.isLoading ? null : () => provider.fetchDivision(),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionsList(
    List<GetCompanyDivision> filteredDivisions,
    bool isDesktop,
    bool isTablet,
  ) {
    if (filteredDivisions.isEmpty) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<SystemProvider>(context, listen: false).fetchDivision();
      },
      child: isDesktop ? _buildGridLayout(filteredDivisions) : _buildListLayout(filteredDivisions),
    );
  }

  Widget _buildGridLayout(List<GetCompanyDivision> filteredDivisions) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: filteredDivisions.length,
      itemBuilder: (context, index) {
        return _buildDivisionCard(filteredDivisions[index], index);
      },
    );
  }

  Widget _buildListLayout(List<GetCompanyDivision> filteredDivisions) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: filteredDivisions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDivisionCard(filteredDivisions[index], index),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              'No divisions found',
              style: context.topology.textTheme.titleLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or filter criteria',
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  selectedColumn = null;
                  selectedValue = null;
                });
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replace the _buildDivisionCard method with this enhanced version

  Widget _buildDivisionCard(GetCompanyDivision division, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: context.colors.primary.withOpacity(0.05),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: _buildDivisionLogo(division),
            title: Text(
              division.divisionname ?? 'Unknown Division',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                division.divisioncode != null
                    ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colors.primary.withOpacity(0.15),
                                  context.colors.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.colors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tag_rounded, size: 14, color: context.colors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  division.divisioncode!,
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    : null,
            trailing: AnimatedBuilder(
              animation: const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Icon(Icons.expand_more_rounded, color: context.colors.primary);
              },
            ),
            onExpansionChanged: (isExpanded) {
              // Trigger rebuild with animation
              setState(() {});
            },
            children: [
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildDivisionDetails(division),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Also update _buildDivisionDetails to wrap sections in AnimatedSize for smoother transitions
  Widget _buildDivisionDetails(GetCompanyDivision division) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasContactInfo(division)) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Contact Information', Icons.contact_phone_rounded),
                const SizedBox(height: 12),
                Container(
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
                    children: [
                      if (division.address != null)
                        _buildDetailRow(Icons.location_on_rounded, 'Address', division.address!),
                      if (division.telephone != null)
                        _buildDetailRow(Icons.phone_rounded, 'Phone', division.telephone!),
                      if (division.fax != null)
                        _buildDetailRow(Icons.fax_rounded, 'Fax', division.fax!),
                      if (division.email != null)
                        _buildDetailRow(Icons.email_rounded, 'Email', division.email!),
                      if (division.website != null)
                        _buildDetailRow(Icons.web_rounded, 'Website', division.website!),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('System Information', Icons.settings_rounded),
              const SizedBox(height: 12),
              Container(
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
                  children: [
                    if (division.customerid != null)
                      _buildInfoRow('Customer ID', division.customerid!),
                    if (division.culture != null && division.culture!.isNotEmpty)
                      _buildInfoRow('Culture', division.culture!),
                    if (division.timezone != null) _buildInfoRow('Timezone', division.timezone!),
                    if (division.divisionid != null)
                      _buildInfoRow('Division ID', division.divisionid!),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _buildActionButtons(division),
        ),
      ],
    );
  }

  Widget _buildDivisionLogo(GetCompanyDivision division) {
    if (division.logo != null && division.logo!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            division.logo!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultLogo(division);
            },
          ),
        ),
      );
    }
    return _buildDefaultLogo(division);
  }

  Widget _buildDefaultLogo(GetCompanyDivision division) {
    return Container(
      width: 56,
      height: 56,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          division.divisionname?.substring(0, 1).toUpperCase() ?? 'D',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.colors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.topology.textTheme.titleSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: context.topology.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.topology.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GetCompanyDivision division) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.companyCreateDivision, arguments: division);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<SystemProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed:
                    provider.isLoading ? null : () => _showDeleteConfirmation(context, division),
                icon:
                    provider.isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : const Icon(Icons.delete_rounded, size: 18),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Replace the placeholder _showDeleteConfirmation and _performDelete methods in Part 1

  void _showDeleteConfirmation(BuildContext context, GetCompanyDivision division) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade50, Colors.orange.shade100],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.warning_rounded, color: Colors.orange.shade700, size: 48),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Delete Division?',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Are you sure you want to delete this division? This action cannot be undone.',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Division Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.white]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildDivisionLogo(division),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  division.divisionname ?? 'Unknown',
                                  style: context.topology.textTheme.titleSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (division.divisioncode != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: context.colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Code: ${division.divisioncode}',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Warning Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action is permanent and cannot be reversed',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<SystemProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () => _performDelete(dialogContext, division),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child:
                                provider.isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.delete_rounded, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Delete',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performDelete(BuildContext dialogContext, GetCompanyDivision division) async {
    if (division.divisionid == null) {
      Navigator.of(dialogContext).pop();
      CommonSnackbar.showError(context, 'Cannot delete: Division ID is missing');
      return;
    }

    final provider = context.read<SystemProvider>();
    final success = await provider.deleteDivision(division);

    if (!mounted) return;

    Navigator.of(dialogContext).pop();

    if (success) {
      // Show success message with custom snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Division Deleted',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"${division.divisionname ?? 'Unknown'}" was successfully deleted',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delete Failed',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.errorMessage ?? 'Failed to delete division',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  bool _hasContactInfo(GetCompanyDivision division) {
    return division.address != null ||
        division.telephone != null ||
        division.fax != null ||
        division.email != null ||
        division.website != null;
  }
}
