import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/get_customer_model.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);
    final customers = provider.customers;

    if (customers.isEmpty) {
      return _buildEmptyState(context);
    }

    return context.isTablet
        ? _buildTabletLayout(context, customers)
        : _buildMobileLayout(context, customers);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                'You do not have list right now',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              Text(
                'Add your first customer',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
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
        // Floating Action Button
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.createCustomer);
            },
            tooltip: 'Add New',
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<Customer> customers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: context.screenHeight - (kToolbarHeight * 1.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: context.paddingHorizontal,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCustomer);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: context.paddingHorizontal,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: IntrinsicWidth(
                              stepWidth: double.infinity,
                              child: DataTable(
                                sortColumnIndex: sortColumnIndex,
                                showCheckboxColumn: false,
                                columnSpacing: 20,
                                dataRowMinHeight: 56,
                                dataRowMaxHeight: 56,
                                columns: _buildColumns(context),
                                rows: List.generate(customers.length, (index) {
                                  final data = customers[index];
                                  final isEven = index % 2 == 0;
                                  return _buildRow(context, data, isEven);
                                }),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Customer> customers) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: context.paddingHorizontal,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCustomer);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: context.paddingHorizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      showCheckboxColumn: false,
                      columnSpacing: 20,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 56,
                      columns: _buildColumns(context),
                      rows: List.generate(customers.length, (index) {
                        final data = customers[index];
                        final isEven = index % 2 == 0;
                        return _buildRow(context, data, isEven);
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Floating Action Button (optional - you already have a create button)
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.createCustomer);
              },
              tooltip: 'Add New',
              backgroundColor: context.colors.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Expanded(
          child: Text(
            'Name',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Customer Code',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Division',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Status',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
    ];
  }

  DataRow _buildRow(BuildContext context, Customer data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      cells: [
        DataCell(
          Text(
            data.customername ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.accountCode ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.division ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.archived == true ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
