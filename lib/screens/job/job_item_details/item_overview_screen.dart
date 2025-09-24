import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemOverviewScreen extends StatefulWidget {
  final String? jobId;
  final String? siteId;

  const ItemOverviewScreen({super.key, this.jobId, this.siteId});

  @override
  State<ItemOverviewScreen> createState() => _ItemOverviewScreenState();
}

class _ItemOverviewScreenState extends State<ItemOverviewScreen> {
  Item? currentItem;
  bool isLoading = true;

  // Text editing controllers for form fields
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _archivedController = TextEditingController();
  final TextEditingController _rfidNoController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailedLocationController = TextEditingController();
  final TextEditingController _internalNotesController = TextEditingController();
  final TextEditingController _externalNotesController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _manufacturerAddressController = TextEditingController();
  final TextEditingController _manufactureDateController = TextEditingController();
  final TextEditingController _firstUseDateController = TextEditingController();
  final TextEditingController _outOfServiceController = TextEditingController();
  final TextEditingController _swlController = TextEditingController();
  final TextEditingController _photoReferenceController = TextEditingController();
  final TextEditingController _standardReferenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItemData();
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _itemNoController.dispose();
    _archivedController.dispose();
    _rfidNoController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _detailedLocationController.dispose();
    _internalNotesController.dispose();
    _externalNotesController.dispose();
    _manufacturerController.dispose();
    _manufacturerAddressController.dispose();
    _manufactureDateController.dispose();
    _firstUseDateController.dispose();
    _outOfServiceController.dispose();
    _swlController.dispose();
    _photoReferenceController.dispose();
    _standardReferenceController.dispose();
    super.dispose();
  }

  Future<void> _loadItemData() async {
    if (widget.jobId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final provider = context.read<JobProvider>();

      // If data is not already loaded, fetch it
      if (provider.jobRegisterModel == null) {
        await provider.fetchJobRegisterModel(context);
      }

      // Find the specific item by jobId
      final items = provider.jobRegisterModel?.items ?? [];
      currentItem = items.firstWhere(
        (item) => item.jobId == widget.jobId,
        orElse: () => items.isNotEmpty ? items.first : null as Item, // cast needed
      );

      if (currentItem != null) {
        _populateFields(currentItem!);
      }
    } catch (e) {
      print('Error loading item data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _populateFields(Item item) {
    _itemNoController.text = item.itemNo ?? '';
    _archivedController.text = item.archived?.toString() ?? '';
    _rfidNoController.text = item.rfidNo ?? '';
    _categoryController.text = item.categoryId ?? '';
    _locationController.text = item.locationId ?? '';
    _detailedLocationController.text = item.detailedLocation ?? '';
    _internalNotesController.text = item.internalNotes ?? '';
    _externalNotesController.text = item.externalNotes ?? '';
    _manufacturerController.text = item.manufacturer ?? '';
    _manufacturerAddressController.text = item.manufacturerAddress ?? '';
    _manufactureDateController.text = item.manufacturerDate?.formatShortDate ?? '';
    _firstUseDateController.text = item.firstUseDate?.formatShortDate ?? '';
    _outOfServiceController.text = item.status?.toString() ?? '';
    _swlController.text = item.swl ?? '';
    _photoReferenceController.text = item.photoReference ?? '';
    _standardReferenceController.text = item.standardReference ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Item Overview',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: context.colors.primary),
          backgroundColor: context.colors.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Overview - ${currentItem?.itemNo ?? 'Unknown'}',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(context, 'Item No', _itemNoController),
                context.vS,
                _buildRow(context, 'Archived', _archivedController),
                context.vS,
                _buildRow(context, 'RFID No', _rfidNoController),
                context.vS,
                _buildRow(context, 'Category', _categoryController),
                context.vS,
                _buildRow(context, 'Location', _locationController),
                context.vS,
                _buildRow(context, 'Detailed Location', _detailedLocationController),
                context.vS,
                _buildRow(context, 'Internal Notes', _internalNotesController, maxLines: 3),
                context.vS,
                _buildRow(context, 'External Notes', _externalNotesController, maxLines: 3),
                context.vS,
              ],
            ),
          ),
        ),
        context.hXl,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(context, 'Manufacturer', _manufacturerController),
                context.vS,
                _buildRow(
                  context,
                  'Manufacturer Address',
                  _manufacturerAddressController,
                  maxLines: 2,
                ),
                context.vS,
                _buildRow(context, 'Manufacture Date', _manufactureDateController),
                context.vS,
                _buildRow(context, 'First Use Date', _firstUseDateController),
                context.vS,
                _buildRow(context, 'Out of Service', _outOfServiceController),
                context.vS,
                _buildRow(context, 'SWL', _swlController),
                context.vS,
                _buildRow(context, 'Photo Reference', _photoReferenceController),
                context.vS,
                _buildRow(
                  context,
                  'Standard & Reference',
                  _standardReferenceController,
                  maxLines: 2,
                ),
                context.vS,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRow(context, 'Item No', _itemNoController),
          context.vS,
          _buildRow(context, 'Archived', _archivedController),
          context.vS,
          _buildRow(context, 'RFID No', _rfidNoController),
          context.vS,
          _buildRow(context, 'Category', _categoryController),
          context.vS,
          _buildRow(context, 'Location', _locationController),
          context.vS,
          _buildRow(context, 'Detailed Location', _detailedLocationController),
          context.vS,
          _buildRow(context, 'Internal Notes', _internalNotesController, maxLines: 3),
          context.vS,
          _buildRow(context, 'External Notes', _externalNotesController, maxLines: 3),
          context.vS,
          _buildRow(context, 'Manufacturer', _manufacturerController),
          context.vS,
          _buildRow(context, 'Manufacturer Address', _manufacturerAddressController, maxLines: 2),
          context.vS,
          _buildRow(context, 'Manufacture Date', _manufactureDateController),
          context.vS,
          _buildRow(context, 'First Use Date', _firstUseDateController),
          context.vS,
          _buildRow(context, 'Out of Service', _outOfServiceController),
          context.vS,
          _buildRow(context, 'SWL', _swlController),
          context.vS,
          _buildRow(context, 'Photo Reference', _photoReferenceController),
          context.vS,
          _buildRow(context, 'Standard & Reference', _standardReferenceController, maxLines: 2),
          context.vS,
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              title,
              style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
            ),
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: true, // Make read-only since this is overview
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
