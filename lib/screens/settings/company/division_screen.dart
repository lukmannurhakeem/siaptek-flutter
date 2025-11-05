import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyDivisionScreen extends StatefulWidget {
  const CompanyDivisionScreen({super.key});

  @override
  State<CompanyDivisionScreen> createState() => _CompanyDivisionScreenState();
}

class _CompanyDivisionScreenState extends State<CompanyDivisionScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchDivision();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading divisions...'),
              ],
            ),
          );
        }

        if (provider.hasError && !provider.hasData) {
          return _buildErrorState(context, provider);
        }

        if (!provider.hasData) {
          return _buildEmptyState(context);
        }

        return _buildDivisionsList(context, provider);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, SystemProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to load divisions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.fetchDivision(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
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
          right: 0,
          child: Image.asset(
            'assets/images/bg_4.png',
            fit: BoxFit.contain,
            alignment: Alignment.bottomRight,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Text('No divisions found', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Create your first division',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.companyCreateDivision);
            },
            tooltip: 'Create Division',
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionsList(BuildContext context, SystemProvider provider) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // --- Background image (fixed at bottom right) ---
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/bg_4.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // --- Foreground scrollable content ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Fixed "Create" button ---
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    child: CommonButton(
                      onPressed: () {
                        NavigationService().navigateTo(AppRoutes.companyCreateDivision);
                      },
                      iconSize: 15,
                      icon: Icons.add,
                      text: 'Create',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Scrollable card list ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () => provider.fetchDivision(),
                      child:
                          provider.divisions.isEmpty
                              ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 100),
                                  Center(child: Text('No divisions available')),
                                ],
                              )
                              : ListView.builder(
                                key: const ValueKey('divisions_list'),
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                itemCount: provider.divisions.length,
                                itemBuilder: (context, index) {
                                  final division = provider.divisions[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildDivisionCard(division, index),
                                  );
                                },
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionCard(GetCompanyDivision division, int index) {
    return Card(
      elevation: 4,
      child: ExpansionTile(
        leading: _buildLogo(division),
        title: Text(
          division.divisionname ?? 'Unknown Division',
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
        ),
        subtitle:
            division.divisioncode != null
                ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    division.divisioncode!,
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                )
                : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasContactInfo(division)) ...[
                  _buildSectionHeader('Contact Information', Icons.contact_phone),
                  const SizedBox(height: 12),
                  if (division.address != null)
                    _buildContactItem(Icons.location_on, 'Address', division.address!),
                  if (division.telephone != null)
                    _buildContactItem(Icons.phone, 'Phone', division.telephone!),
                  if (division.fax != null) _buildContactItem(Icons.fax, 'Fax', division.fax!),
                  if (division.email != null)
                    _buildContactItem(Icons.email, 'Email', division.email!),
                  if (division.website != null)
                    _buildContactItem(Icons.web, 'Website', division.website!),
                  const SizedBox(height: 20),
                ],
                _buildSectionHeader('System Information', Icons.settings),
                const SizedBox(height: 12),
                if (division.customerid != null)
                  _buildInfoItem('Customer ID', division.customerid!),
                if (division.culture != null && division.culture!.isNotEmpty)
                  _buildInfoItem('Culture', division.culture!),
                if (division.timezone != null) _buildInfoItem('Timezone', division.timezone!),
                if (division.divisionid != null)
                  _buildInfoItem('Division ID', division.divisionid!),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Edit',
                        backgroundColor: Theme.of(context).primaryColor,
                        icon: Icons.edit,
                        onPressed: () {
                          NavigationService().navigateTo(
                            AppRoutes.companyCreateDivision,
                            arguments: division,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<SystemProvider>(
                        builder: (context, provider, child) {
                          return CommonButton(
                            text: 'Delete',
                            backgroundColor: Colors.red[600] ?? Colors.red,
                            icon: Icons.delete,
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () => _showDeleteConfirmation(context, division),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  Widget _buildLogo(GetCompanyDivision division) {
    if (division.logo != null && division.logo!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(division.logo!),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading logo: $exception');
        },
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        division.divisionname?.substring(0, 1).toUpperCase() ?? 'D',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasContactInfo(GetCompanyDivision division) {
    return division.address != null ||
        division.telephone != null ||
        division.fax != null ||
        division.email != null ||
        division.website != null;
  }

  void _showDeleteConfirmation(BuildContext context, GetCompanyDivision division) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Text(
                'Confirm Delete',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this division?',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Division: ${division.divisionname ?? 'Unknown'}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    if (division.divisioncode != null)
                      Text(
                        'Code: ${division.divisioncode}',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: context.topology.textTheme.titleSmall?.copyWith(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<SystemProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed:
                      provider.isLoading ? null : () => _performDelete(dialogContext, division),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child:
                      provider.isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : const Text('Delete'),
                );
              },
            ),
          ],
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

    Navigator.of(dialogContext).pop();

    if (success) {
      CommonSnackbar.showSuccess(
        context,
        'Division "${division.divisionname ?? 'Unknown'}" deleted successfully',
      );
    } else {
      CommonSnackbar.showError(context, provider.errorMessage ?? 'Failed to delete division');
    }
  }
}
