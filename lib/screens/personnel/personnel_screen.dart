import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/personnel_model.dart';
import 'package:INSPECT/providers/personnel_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PersonnelData> _filteredPersonnel = [];

  @override
  void initState() {
    super.initState();

    // Fetch personnel data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonnelProvider>().fetchPersonnel();
    });

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<PersonnelProvider>();
    setState(() {
      _filteredPersonnel = provider.searchPersonnel(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonnelProvider>(
      builder: (context, personnelProvider, child) {
        // Show loading indicator
        if (personnelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (personnelProvider.errorMessage != null) {
          return _buildErrorState(context, personnelProvider);
        }

        // Get personnel list (filtered or full list, showing only active personnel)
        final personnelList =
            _searchController.text.isEmpty
                ? personnelProvider.activePersonnel
                : _filteredPersonnel.where((p) => !p.personnel.isArchived).toList();

        // Show empty state
        if (personnelList.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show personnel data
        return _buildPersonnelList(context, personnelList);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, PersonnelProvider personnelProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: context.colors.error),
          const SizedBox(height: 16),
          Text(
            personnelProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.error),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => personnelProvider.refreshPersonnel(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
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
        Container(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                _searchController.text.isEmpty
                    ? 'No personnel found'
                    : 'No results for "${_searchController.text}"',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Add your first personnel member',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vL,
                ElevatedButton.icon(
                  onPressed: () {
                    NavigationService().navigateTo(AppRoutes.createPersonnel);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Personnel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonnelList(BuildContext context, List<PersonnelData> personnelList) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Padding(
        padding: context.paddingAll,
        child: Column(
          children: [
            // Create New button at the top
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createPersonnel, arguments: null);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New'),
                style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            CommonTextField(
              controller: _searchController,
              hintText: 'Search by name, job title, or employee number...',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: context.colors.primary),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  Icon(Icons.search, color: context.colors.primary),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            context.vM,
            // Result count
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${personnelList.length} personnel found',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            // Personnel grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<PersonnelProvider>().refreshPersonnel(),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isTablet ? 6 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: context.isTablet ? 3 / 2 : 1.0,
                  ),
                  itemCount: personnelList.length,
                  itemBuilder: (context, index) {
                    final personnelData = personnelList[index];
                    return _personnelCard(context, personnelData);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personnelCard(BuildContext context, PersonnelData personnelData) {
    return GestureDetector(
      onTap: () {
        NavigationService().navigateTo(
          AppRoutes.personnelDetails,
          arguments: {'personnelId': personnelData.personnel.personnelID},
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.person, size: 40, color: context.colors.primary),
              ),
              const SizedBox(height: 12),
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      personnelData.displayName,
                      textAlign: TextAlign.center,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (personnelData.company.jobTitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        personnelData.company.jobTitle,
                        textAlign: TextAlign.center,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
