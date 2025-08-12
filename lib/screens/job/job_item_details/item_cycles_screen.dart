import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class CycleItem {
  final String cycleLength;
  final String categoryName;
  final bool setAtItem;
  final String customerName;
  final String siteName;
  final String dateType;

  CycleItem({
    required this.cycleLength,
    required this.categoryName,
    required this.setAtItem,
    required this.customerName,
    required this.siteName,
    required this.dateType,
  });
}

class ItemCyclesScreen extends StatefulWidget {
  const ItemCyclesScreen({super.key});

  @override
  State<ItemCyclesScreen> createState() => _ItemCyclesScreenState();
}

class _ItemCyclesScreenState extends State<ItemCyclesScreen> {
  final TextEditingController _lengthController = TextEditingController();
  String _selectedDateType = '';
  String _selectedUnit = '';

  List<String> _dateTypes = [
    'Exam (Preservation Report)',
    'Exam (Report of Thorough Examination)',
    'Maintenance',
    'Calibration',
    'Service',
  ];

  List<String> _units = ['Months', 'Weeks', 'Days', 'Years'];

  List<CycleItem> _cycles = [
    CycleItem(
      cycleLength: '24 Months',
      categoryName: '',
      setAtItem: false,
      customerName: '',
      siteName: '',
      dateType: 'Exam (Preservation Report)',
    ),
    CycleItem(
      cycleLength: '6 Months',
      categoryName: '',
      setAtItem: false,
      customerName: '',
      siteName: '',
      dateType: 'Exam (Report of Thorough Examination)',
    ),
  ];

  int _currentPage = 1;
  int _itemsPerPage = 50;
  String _filterCycleLength = '';
  String _filterCategoryName = '';
  String _filterSetAtItem = 'All';
  String _filterCustomerName = '';
  String _filterSiteName = '';
  String _filterDateType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddCycleSection(context),
          const SizedBox(height: 24),
          _buildCyclesTable(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddCycleSection(context),
        const SizedBox(height: 24),
        _buildMobileCyclesList(context),
      ],
    );
  }

  Widget _buildAddCycleSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          _buildFormRow(context, 'Date Type', _buildDateTypeDropdown(context)),
          const SizedBox(height: 16),
          _buildFormRow(context, 'Length', _buildLengthField(context)),
          const SizedBox(height: 16),
          _buildFormRow(context, 'Unit', _buildUnitDropdown(context)),
          const SizedBox(height: 24),
          CommonButton(onPressed: _saveCycle, text: 'Save'),
        ],
      ),
    );
  }

  Widget _buildFormRow(BuildContext context, String label, Widget field) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildDateTypeDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedDateType.isEmpty ? null : _selectedDateType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text(
        'Select Date Type',
        style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
      style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
      items:
          _dateTypes.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDateType = newValue ?? '';
        });
      },
    );
  }

  Widget _buildLengthField(BuildContext context) {
    return CommonTextField(
      controller: _lengthController,
      keyboardType: TextInputType.number,
      hintText: '0',
    );
  }

  Widget _buildUnitDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedUnit.isEmpty ? null : _selectedUnit,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text(
        'Select Unit',
        style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
      style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
      items:
          _units.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedUnit = newValue ?? '';
        });
      },
    );
  }

  Widget _buildCyclesTable(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycles',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          _buildFiltersRow(context),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildTableHeader(context),
                  Expanded(child: _buildTableBody(context)),
                  _buildPaginationFooter(context),
                ],
              ),
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
          _buildFilterColumn('Cycle Length', _filterCycleLength, (value) {
            setState(() => _filterCycleLength = value);
          }),
          const SizedBox(width: 16),
          _buildFilterColumn('Category Name', _filterCategoryName, (value) {
            setState(() => _filterCategoryName = value);
          }),
          const SizedBox(width: 16),
          _buildSetAtItemFilter(),
          const SizedBox(width: 16),
          _buildFilterColumn('Customer Name', _filterCustomerName, (value) {
            setState(() => _filterCustomerName = value);
          }),
          const SizedBox(width: 16),
          _buildFilterColumn('Site Name', _filterSiteName, (value) {
            setState(() => _filterSiteName = value);
          }),
          const SizedBox(width: 16),
          _buildDateTypeFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterColumn(String title, String value, Function(String) onChanged) {
    return Container(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 4),
          Container(height: 32, child: CommonTextField(onChanged: onChanged)),
        ],
      ),
    );
  }

  Widget _buildSetAtItemFilter() {
    return Container(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set at Item',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 4),
          Container(
            height: 32,
            child: DropdownButtonFormField<String>(
              value: _filterSetAtItem,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              hint: Text(
                'Select Item',
                style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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

  Widget _buildDateTypeFilter() {
    return Container(
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
          Container(
            height: 32,
            child: TextField(
              onChanged: (value) {
                setState(() => _filterDateType = value);
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                suffixIcon: const Icon(Icons.filter_list, size: 16),
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
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.primary.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Cycle Length', flex: 2),
          _buildHeaderCell('Category Name', flex: 2),
          _buildHeaderCell('Set at Item', flex: 2),
          _buildHeaderCell('Customer Name', flex: 2),
          _buildHeaderCell('Site Name', flex: 2),
          _buildHeaderCell('Date Type', flex: 3),
          _buildHeaderCell('Actions', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
      ),
    );
  }

  Widget _buildTableBody(BuildContext context) {
    return ListView.builder(
      itemCount: _cycles.length,
      itemBuilder: (context, index) {
        final cycle = _cycles[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colors.primary.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              _buildDataCell(cycle.cycleLength, flex: 2),
              _buildDataCell(cycle.categoryName.isEmpty ? '-' : cycle.categoryName, flex: 2),
              _buildDataCell(cycle.setAtItem ? 'Yes' : 'No', flex: 2),
              _buildDataCell(cycle.customerName.isEmpty ? '-' : cycle.customerName, flex: 2),
              _buildDataCell(cycle.siteName.isEmpty ? '-' : cycle.siteName, flex: 2),
              _buildDataCell(cycle.dateType, flex: 3),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _editCycle(index),
                      icon: const Icon(Icons.edit),
                      iconSize: 16,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteCycle(index),
                      icon: const Icon(Icons.delete),
                      iconSize: 16,
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: context.topology.textTheme.bodySmall));
  }

  Widget _buildPaginationFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.primary.withOpacity(0.3))),
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
              Container(
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
            '1 - ${_cycles.length} of ${_cycles.length} cycles',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCyclesList(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycles (${_cycles.length})',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _cycles.length,
              itemBuilder: (context, index) {
                final cycle = _cycles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cycle.cycleLength,
                              style: context.topology.textTheme.titleMedium?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _editCycle(index),
                                  icon: const Icon(Icons.edit),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: () => _deleteCycle(index),
                                  icon: const Icon(Icons.delete),
                                  iconSize: 20,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date Type: ${cycle.dateType}',
                          style: context.topology.textTheme.bodyMedium?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        Text(
                          'Set at Item: ${cycle.setAtItem ? 'Yes' : 'No'}',
                          style: context.topology.textTheme.bodyMedium?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveCycle() {
    if (_lengthController.text.isEmpty || _selectedDateType.isEmpty || _selectedUnit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newCycle = CycleItem(
      cycleLength: '${_lengthController.text} $_selectedUnit',
      categoryName: '',
      setAtItem: false,
      customerName: '',
      siteName: '',
      dateType: _selectedDateType,
    );

    setState(() {
      _cycles.add(newCycle);
      _lengthController.clear();
      _selectedDateType = '';
      _selectedUnit = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cycle saved successfully'), backgroundColor: Colors.green),
    );
  }

  void _editCycle(int index) {
    // Implement edit functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit cycle at index $index')));
  }

  void _deleteCycle(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Cycle'),
            content: const Text('Are you sure you want to delete this cycle?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  setState(() {
                    _cycles.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cycle deleted successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }
}
