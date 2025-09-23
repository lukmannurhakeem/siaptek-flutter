import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
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
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: context.paddingAll,
              child: Column(
                children: [
                  CommonTextField(
                    controller: _searchController,
                    hintText: 'Search by name, job title, or employee number...',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                    suffixIcon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  context.vM,
                  Expanded(
                    child: Consumer<PersonnelProvider>(
                      builder: (context, personnelProvider, child) {
                        // Show loading indicator
                        if (personnelProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Show error message
                        if (personnelProvider.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: context.colors.error),
                                const SizedBox(height: 16),
                                Text(
                                  personnelProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: context.topology.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.error,
                                  ),
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

                        // Get personnel list (filtered or full list, showing only active personnel)
                        final personnelList =
                            _searchController.text.isEmpty
                                ? personnelProvider.activePersonnel
                                : _filteredPersonnel.where((p) => !p.personnel.isArchived).toList();

                        // Show empty state
                        if (personnelList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchController.text.isEmpty
                                      ? Icons.person_outline
                                      : Icons.search_off,
                                  size: 64,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No personnel found'
                                      : 'No results for "${_searchController.text}"',
                                  textAlign: TextAlign.center,
                                  style: context.topology.textTheme.bodyLarge?.copyWith(
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
                                ],
                              ],
                            ),
                          );
                        }

                        // Show personnel count
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                '${personnelList.length} personnel found',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => personnelProvider.refreshPersonnel(),
                                child: GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: context.isTablet ? 6 : 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: context.isTablet ? 2.0 : 1.0,
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(
                  AppRoutes.createPersonnel,
                  arguments: null, // No ID means create new personnel
                );
              },
              tooltip: 'Add New Personnel',
              backgroundColor: context.colors.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
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
                    // if (personnelData.company.jobTitle.isNotEmpty) ...[
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     personnelData.company.jobTitle,
                    //     textAlign: TextAlign.center,
                    //     style: context.topology.textTheme.bodySmall?.copyWith(
                    //       color: context.colors.primary,
                    //       fontSize: 11,
                    //     ),
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ],
                    // if (personnelData.company.employeeNumber.isNotEmpty) ...[
                    //   const SizedBox(height: 2),
                    //   Text(
                    //     '#${personnelData.company.employeeNumber}',
                    //     textAlign: TextAlign.center,
                    //     style: context.topology.textTheme.bodySmall?.copyWith(
                    //       color: context.colors.primary,
                    //       fontSize: 10,
                    //     ),
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ],
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
