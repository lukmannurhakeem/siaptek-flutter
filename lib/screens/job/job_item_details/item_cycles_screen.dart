import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/model/cycle_model.dart';
import 'package:INSPECT/providers/cycle_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCyclesScreen extends StatefulWidget {
  const ItemCyclesScreen({super.key});

  @override
  State<ItemCyclesScreen> createState() => _ItemCyclesScreenState();
}

class _ItemCyclesScreenState extends State<ItemCyclesScreen> {
  CycleData? _selectedCycle;
  List<CycleData> _selectedCycles = [];

  int _currentPage = 1;
  int _itemsPerPage = 50;
  String _filterCycleLength = '';
  String _filterCategoryName = '';
  String _filterSetAtItem = 'All';
  String _filterCustomerName = '';
  String _filterSiteName = '';
  String _filterDateType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().fetchCycles(context);
    });
  }

  List<CycleData> _getFilteredCycles(CycleProvider cycleProvider) {
    if (cycleProvider.cycleModel?.data == null) return [];

    var filteredList = cycleProvider.cycleModel!.data!;

    if (_filterCycleLength.isNotEmpty) {
      filteredList =
          filteredList.where((cycle) {
            final cycleLength = '${cycle.minLength ?? cycle.length} ${cycle.unit}';
            return cycleLength.toLowerCase().contains(_filterCycleLength.toLowerCase());
          }).toList();
    }

    if (_filterCategoryName.isNotEmpty) {
      filteredList =
          filteredList.where((cycle) {
            return (cycle.categoryName ?? '').toLowerCase().contains(
              _filterCategoryName.toLowerCase(),
            );
          }).toList();
    }

    if (_filterSetAtItem != 'All') {
      final isSetAtItem = _filterSetAtItem == 'Yes';
      filteredList =
          filteredList.where((cycle) {
            final hasCustomerSite = (cycle.customerSite ?? '').isNotEmpty;
            return hasCustomerSite == isSetAtItem;
          }).toList();
    }

    if (_filterCustomerName.isNotEmpty) {
      filteredList =
          filteredList.where((cycle) {
            return (cycle.customerSite ?? '').toLowerCase().contains(
              _filterCustomerName.toLowerCase(),
            );
          }).toList();
    }

    if (_filterDateType.isNotEmpty) {
      filteredList =
          filteredList.where((cycle) {
            return (cycle.dataType ?? '').toLowerCase().contains(_filterDateType.toLowerCase());
          }).toList();
    }

    return filteredList;
  }

  String _getCycleDisplayText(CycleData cycle) {
    final length = cycle.minLength ?? cycle.length ?? 0;
    final unit = cycle.unit ?? '';
    final dataType = cycle.dataType ?? 'Unknown Type';
    final category = cycle.categoryName ?? '';

    String text = '$length $unit - $dataType';
    if (category.isNotEmpty) {
      text += ' ($category)';
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CycleProvider>(
            builder: (context, cycleProvider, child) {
              if (cycleProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: context.colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Loading cycles...',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (cycleProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Cycles',
                        style: context.topology.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cycleProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CommonButton(
                        text: 'Retry',
                        onPressed: () => cycleProvider.fetchCycles(context),
                      ),
                    ],
                  ),
                );
              }

              return context.isTablet
                  ? _buildTabletLayout(context, cycleProvider)
                  : _buildMobileLayout(context, cycleProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, CycleProvider cycleProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectCycleSection(context, cycleProvider),
          const SizedBox(height: 24),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildSelectedCyclesTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CycleProvider cycleProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectCycleSection(context, cycleProvider),
          const SizedBox(height: 24),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildMobileSelectedCyclesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCycleSection(BuildContext context, CycleProvider cycleProvider) {
    final availableCycles = cycleProvider.cycleModel?.data ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_circle_outline, color: context.colors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Add Cycle to Item',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Select Cycle',
            style: context.topology.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _selectedCycle != null
                        ? context.colors.primary.withOpacity(0.5)
                        : context.colors.primary.withOpacity(0.2),
                width: _selectedCycle != null ? 1.5 : 1,
              ),
            ),
            child: DropdownButtonFormField<CycleData>(
              value: _selectedCycle,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText:
                    availableCycles.isEmpty
                        ? 'No cycles available'
                        : 'Choose a cycle from the list',
                hintStyle: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary.withOpacity(0.4),
                ),
              ),
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: context.colors.primary),
              items:
                  availableCycles.isEmpty
                      ? []
                      : availableCycles.map((CycleData cycle) {
                        return DropdownMenuItem<CycleData>(
                          value: cycle,
                          child: Text(
                            _getCycleDisplayText(cycle),
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
              onChanged:
                  availableCycles.isEmpty
                      ? null
                      : (CycleData? newValue) {
                        setState(() {
                          _selectedCycle = newValue;
                        });
                      },
            ),
          ),

          if (_selectedCycle != null) ...[
            const SizedBox(height: 20),
            _buildSelectedCycleDetailsCard(context),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedCycle == null ? null : _addCycleToList,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                disabledBackgroundColor: context.colors.primary.withOpacity(0.3),
                foregroundColor: Colors.white,
                elevation: _selectedCycle != null ? 2 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_selectedCycle == null ? Icons.touch_app : Icons.add_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCycle == null ? 'Select a cycle first' : 'Add to Item',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSelectedCycleDetailsCard(BuildContext context) {
    if (_selectedCycle == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withOpacity(0.08),
            context.colors.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Selected Cycle Details',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            context: context,
            icon: Icons.schedule,
            label: 'Cycle Length',
            value:
                '${_selectedCycle!.minLength ?? _selectedCycle!.length ?? 0} ${_selectedCycle!.unit ?? ""}',
            isHighlight: true,
          ),

          if (_selectedCycle!.maxLength != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              context: context,
              icon: Icons.timelapse,
              label: 'Maximum Length',
              value: '${_selectedCycle!.maxLength} ${_selectedCycle!.unit ?? ""}',
            ),
          ],

          const SizedBox(height: 16),
          _buildDetailRow(
            context: context,
            icon: Icons.category_outlined,
            label: 'Data Type',
            value: _selectedCycle!.dataType ?? 'Not specified',
          ),

          const SizedBox(height: 16),
          _buildDetailRow(
            context: context,
            icon: Icons.label_outline,
            label: 'Category',
            value:
                (_selectedCycle!.categoryName?.isNotEmpty ?? false)
                    ? _selectedCycle!.categoryName!
                    : 'No category assigned',
            isSecondary: (_selectedCycle!.categoryName?.isEmpty ?? true),
          ),

          const SizedBox(height: 16),
          _buildDetailRow(
            context: context,
            icon: Icons.business_outlined,
            label: 'Customer/Site',
            value:
                (_selectedCycle!.customerSite?.isNotEmpty ?? false)
                    ? _selectedCycle!.customerSite!
                    : 'Not assigned to specific site',
            isSecondary: (_selectedCycle!.customerSite?.isEmpty ?? true),
          ),

          if (_selectedCycle!.cycleId != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              context: context,
              icon: Icons.tag,
              label: 'Cycle ID',
              value: _selectedCycle!.cycleId!,
              isSmall: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
    bool isSecondary = false,
    bool isSmall = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isHighlight ? context.colors.primary.withOpacity(0.08) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.primary.withOpacity(isHighlight ? 0.2 : 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isHighlight
                      ? context.colors.primary.withOpacity(0.15)
                      : context.colors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: context.colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (isSmall
                          ? context.topology.textTheme.bodySmall
                          : context.topology.textTheme.bodySmall)
                      ?.copyWith(
                        color: context.colors.primary.withOpacity(0.6),
                        fontSize: isSmall ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: (isSmall
                          ? context.topology.textTheme.bodySmall
                          : context.topology.textTheme.bodyMedium)
                      ?.copyWith(
                        color:
                            isSecondary
                                ? context.colors.primary.withOpacity(0.5)
                                : context.colors.primary,
                        fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                        fontSize: isSmall ? 11 : 14,
                        fontStyle: isSecondary ? FontStyle.italic : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
    bool isSecondary = false,
    bool isSmall = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color:
                isHighlight
                    ? context.colors.primary.withOpacity(0.15)
                    : context.colors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: context.colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: (isSmall
                        ? context.topology.textTheme.bodySmall
                        : context.topology.textTheme.bodyMedium)
                    ?.copyWith(
                      color: context.colors.primary.withOpacity(0.6),
                      fontSize: isSmall ? 11 : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: (isSmall
                        ? context.topology.textTheme.bodySmall
                        : context.topology.textTheme.bodyMedium)
                    ?.copyWith(
                      color:
                          isSecondary
                              ? context.colors.primary.withOpacity(0.5)
                              : context.colors.primary,
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                      fontSize: isSmall ? 11 : null,
                      fontStyle: isSecondary ? FontStyle.italic : null,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedCyclesTable(BuildContext context) {
    final filteredCycles =
        _getFilteredCycles(context.read<CycleProvider>())
            .where((cycle) => _selectedCycles.any((selected) => selected.cycleId == cycle.cycleId))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.playlist_add_check, color: context.colors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Selected Cycles',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedCycles.length}',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedCycles.isNotEmpty) ...[_buildFiltersRow(context), const SizedBox(height: 16)],
        Expanded(
          child:
              _selectedCycles.isEmpty
                  ? _buildEmptyState(context)
                  : filteredCycles.isEmpty
                  ? _buildNoResultsState(context)
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: context.colors.primary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTableHeader(context),
                        Expanded(child: _buildTableBody(context, filteredCycles)),
                        _buildPaginationFooter(context, filteredCycles),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available,
              size: 64,
              color: context.colors.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Cycles Added Yet',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Select a cycle from the dropdown above to add it to this item',
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.primary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 20, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 8),
                Text(
                  'Add cycles to manage inspection schedules',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.filter_alt_off, size: 64, color: Colors.orange.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Cycles Match Your Filters',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try adjusting your filter criteria to see more results',
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _filterCycleLength = '';
                _filterCategoryName = '';
                _filterSetAtItem = 'All';
                _filterCustomerName = '';
                _filterDateType = '';
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.primary,
              side: BorderSide(color: context.colors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterColumn(context, 'Cycle Length', _filterCycleLength, (value) {
            setState(() => _filterCycleLength = value);
          }),
          const SizedBox(width: 16),
          _buildFilterColumn(context, 'Category Name', _filterCategoryName, (value) {
            setState(() => _filterCategoryName = value);
          }),
          const SizedBox(width: 16),
          _buildSetAtItemFilter(context),
          const SizedBox(width: 16),
          _buildFilterColumn(context, 'Customer Name', _filterCustomerName, (value) {
            setState(() => _filterCustomerName = value);
          }),
          const SizedBox(width: 16),
          _buildDateTypeFilter(context),
        ],
      ),
    );
  }

  Widget _buildFilterColumn(
    BuildContext context,
    String title,
    String value,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 4),
          SizedBox(height: 32, child: CommonTextField(onChanged: onChanged)),
        ],
      ),
    );
  }

  Widget _buildSetAtItemFilter(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set at Item',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: DropdownButtonFormField<String>(
              value: _filterSetAtItem,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
              items:
                  ['All', 'Yes', 'No'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _filterSetAtItem = newValue ?? 'All';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTypeFilter(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Date Type',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_upward, size: 12, color: context.colors.primary),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: TextField(
              onChanged: (value) {
                setState(() => _filterDateType = value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                suffixIcon: Icon(Icons.filter_list, size: 16),
              ),
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: context.colors.primary.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          _buildHeaderCell(context, 'Cycle Length', flex: 2),
          _buildHeaderCell(context, 'Category Name', flex: 2),
          _buildHeaderCell(context, 'Set at Item', flex: 2),
          _buildHeaderCell(context, 'Customer/Site', flex: 2),
          _buildHeaderCell(context, 'Date Type', flex: 3),
          _buildHeaderCell(context, 'Actions', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: context.topology.textTheme.bodyMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableBody(BuildContext context, List<CycleData> cycles) {
    return ListView.builder(
      itemCount: cycles.length,
      itemBuilder: (context, index) {
        final cycle = cycles[index];
        final hasCustomerSite = (cycle.customerSite ?? '').isNotEmpty;
        final isEven = index % 2 == 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEven ? Colors.transparent : context.colors.primary.withOpacity(0.02),
            border: Border(bottom: BorderSide(color: context.colors.primary.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              _buildDataCell(
                context,
                '${cycle.minLength ?? cycle.length ?? 0} ${cycle.unit ?? ""}',
                flex: 2,
                isBold: true,
              ),
              _buildDataCell(context, cycle.categoryName ?? '-', flex: 2),
              _buildDataCell(
                context,
                hasCustomerSite ? 'Yes' : 'No',
                flex: 2,
                color: hasCustomerSite ? Colors.green : Colors.grey,
              ),
              _buildDataCell(context, cycle.customerSite ?? '-', flex: 2),
              _buildDataCell(context, cycle.dataType ?? '-', flex: 3),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () => _removeCycleFromList(cycle),
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  color: Colors.red,
                  tooltip: 'Remove from item',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataCell(
    BuildContext context,
    String text, {
    int flex = 1,
    bool isBold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: context.topology.textTheme.bodySmall?.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? context.colors.primary,
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(BuildContext context, List<CycleData> cycles) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(top: BorderSide(color: context.colors.primary.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Page',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 32,
                child: CommonTextField(
                  controller: TextEditingController(text: _currentPage.toString()),
                ),
              ),
              const SizedBox(width: 8),
              Text('of 1', style: context.topology.textTheme.bodySmall),
            ],
          ),
          Row(
            children: [
              DropdownButton<int>(
                value: _itemsPerPage,
                items:
                    [10, 25, 50, 100].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _itemsPerPage = newValue ?? 50;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'cycles per page',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          Text(
            '1 - ${cycles.length} of ${cycles.length} cycles',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSelectedCyclesList(BuildContext context) {
    final filteredCycles =
        _getFilteredCycles(context.read<CycleProvider>())
            .where((cycle) => _selectedCycles.any((selected) => selected.cycleId == cycle.cycleId))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.playlist_add_check, color: context.colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Selected Cycles',
              style: context.topology.textTheme.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_selectedCycles.length}',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              _selectedCycles.isEmpty
                  ? _buildEmptyState(context)
                  : filteredCycles.isEmpty
                  ? _buildNoResultsState(context)
                  : ListView.builder(
                    itemCount: filteredCycles.length,
                    itemBuilder: (context, index) {
                      final cycle = filteredCycles[index];
                      final hasCustomerSite = (cycle.customerSite ?? '').isNotEmpty;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: context.colors.primary.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: context.colors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.schedule,
                                            color: context.colors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${cycle.minLength ?? cycle.length ?? 0} ${cycle.unit ?? ""}',
                                            style: context.topology.textTheme.titleMedium?.copyWith(
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeCycleFromList(cycle),
                                    icon: const Icon(Icons.delete_outline),
                                    iconSize: 24,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: context.colors.primary.withOpacity(0.1)),
                              const SizedBox(height: 12),
                              _buildMobileDetailRow(
                                context,
                                Icons.category_outlined,
                                'Date Type',
                                cycle.dataType ?? 'Not specified',
                              ),
                              const SizedBox(height: 8),
                              _buildMobileDetailRow(
                                context,
                                Icons.label_outline,
                                'Category',
                                cycle.categoryName ?? 'No category',
                              ),
                              const SizedBox(height: 8),
                              _buildMobileDetailRow(
                                context,
                                Icons.check_circle_outline,
                                'Set at Item',
                                hasCustomerSite ? 'Yes' : 'No',
                                valueColor: hasCustomerSite ? Colors.green : Colors.grey,
                              ),
                              if (hasCustomerSite) ...[
                                const SizedBox(height: 8),
                                _buildMobileDetailRow(
                                  context,
                                  Icons.business_outlined,
                                  'Customer/Site',
                                  cycle.customerSite!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: valueColor ?? context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _addCycleToList() {
    if (_selectedCycle == null) return;

    if (_selectedCycles.any((cycle) => cycle.cycleId == _selectedCycle!.cycleId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This cycle is already added to the item',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _selectedCycles.add(_selectedCycle!);
      _selectedCycle = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cycle added successfully',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _removeCycleFromList(CycleData cycle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Remove Cycle', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Are you sure you want to remove this cycle from the item?',
              style: context.topology.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: context.colors.primary)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCycles.removeWhere((c) => c.cycleId == cycle.cycleId);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cycle removed successfully',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}
