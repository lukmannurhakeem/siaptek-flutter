// category_provider.dart
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/create_category_model.dart';
import 'package:base_app/model/field_model.dart';
import 'package:base_app/model/get_category_model.dart';
import 'package:base_app/repositories/category/category_repository.dart';
import 'package:flutter/material.dart';

// Move this class to a separate file (e.g., models/category_item.dart) to avoid duplicates
class CategoryItem {
  String id;
  String name;
  String? parentId;
  List<CategoryItem> children;
  bool isExpanded;
  bool canHaveChildItems;
  String? categoryCode;
  String? description;
  int level; // Add level tracking for proper indentation

  CategoryItem({
    required this.id,
    required this.name,
    this.parentId,
    List<CategoryItem>? children,
    this.isExpanded = false,
    this.canHaveChildItems = false,
    this.categoryCode,
    this.description,
    this.level = 0,
  }) : children = children != null ? List.from(children) : <CategoryItem>[];

  // Helper method to check if this category has any descendants
  bool get hasDescendants {
    if (children.isNotEmpty) return true;
    return children.any((child) => child.hasDescendants);
  }
}

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository = ServiceLocator().categoryRepository;

  // -----------------------------
  // ✅ Fields Logic (your previous code remains)
  // -----------------------------
  List<FieldModel> _fields = [
    FieldModel(id: '1', labelText: 'Item No', name: 'ItemNo', fieldType: 'ItemNo', required: true),
    FieldModel(
      id: '2',
      labelText: 'Archived',
      name: 'ItemIsArchived',
      fieldType: 'ItemIsArchived',
      required: true,
      isArchived: true,
    ),
    FieldModel(
      id: '3',
      labelText: 'Description',
      name: 'ItemDescription',
      fieldType: 'ItemDescription',
    ),
    FieldModel(id: '4', labelText: 'RFID No', name: 'RFIDNo', fieldType: 'RFIDNo'),
    FieldModel(id: '5', labelText: 'Latest Photo', name: 'LatestPhoto', fieldType: 'LatestPhoto'),
    FieldModel(
      id: '6',
      labelText: 'Customer',
      name: 'Customer',
      fieldType: 'Customer',
      required: true,
    ),
    FieldModel(id: '7', labelText: 'Site', name: 'SiteID', fieldType: 'SiteID', required: true),
    FieldModel(
      id: '8',
      labelText: 'Category',
      name: 'ItemCategory',
      fieldType: 'ItemCategory',
      required: true,
    ),
    FieldModel(
      id: '9',
      labelText: 'Location',
      name: 'ItemLocation',
      fieldType: 'ItemLocation',
      required: true,
    ),
    FieldModel(
      id: '10',
      labelText: 'Detailed Location',
      name: 'DetailedLocation',
      fieldType: 'Text',
    ),
  ];

  bool _showArchived = false;
  bool _canHaveChild = false;
  bool _isWithdrawn = false;

  List<FieldModel> get fields =>
      _showArchived ? _fields : _fields.where((field) => !field.isArchived).toList();

  bool get showArchived => _showArchived;

  bool get showCanHaveChild => _canHaveChild;

  bool get showIsWithdrawn => _isWithdrawn;

  void toggleShowArchived() {
    _showArchived = !_showArchived;
    notifyListeners();
  }

  void toggleCanHaveChild() {
    _canHaveChild = !_canHaveChild;
    notifyListeners();
  }

  void toggleIsWithdrawn() {
    _isWithdrawn = !_isWithdrawn;
    notifyListeners();
  }

  void addField(FieldModel field) {
    final newField = field.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    _fields.add(newField);
    notifyListeners();
  }

  void removeField(String id) {
    _fields.removeWhere((field) => field.id == id);
    notifyListeners();
  }

  void updateField(String id, FieldModel updatedField) {
    final index = _fields.indexWhere((field) => field.id == id);
    if (index != -1) {
      _fields[index] = updatedField.copyWith(id: id);
      notifyListeners();
    }
  }

  List<String> get availableFieldTypes => [
    'Text',
    'Multi-Line Textbox',
    'Numeric',
    'Decimal',
    'Date',
    'Dropdown',
    'Override Dropdown',
    'Conditional Dropdown',
    'Site Dropdown',
    'Boolean',
    'Checklist Item',
    'Colour Picker',
    'File',
    'Signature',
    'Label',
    'Section',
    'ItemNo',
    'ItemDescription',
    'Customer',
    'SiteID',
    'ItemCategory',
    'ItemLocation',
    'RFIDNo',
    'LatestPhoto',
  ];

  // -----------------------------
  // ✅ Categories Logic - FIXED for Multi-level Hierarchy
  // -----------------------------
  GetCategoryModel? _categories;
  bool _isLoading = false;
  String? _errorMessage;

  GetCategoryModel? get categories => _categories;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Local hierarchy & filtering
  List<CategoryItem> _allCategories = [];
  List<CategoryItem> _filteredCategories = [];
  List<CategoryItem> _flattenedCategories = []; // For ListView display

  List<CategoryItem> get filteredCategories => _filteredCategories;

  // -----------------------------
  // ✅ NEW: Category by ID Logic
  // -----------------------------
  CreateCategoryModel? _categoryById;
  bool _isLoadingById = false;
  String? _errorMessageById;

  CreateCategoryModel? get categoryById => _categoryById;

  bool get isLoadingById => _isLoadingById;

  String? get errorMessageById => _errorMessageById;

  Future<void> fetchCategoryById(String categoryId) async {
    _isLoadingById = true;
    _errorMessageById = null;
    notifyListeners();

    try {
      final response = await _categoryRepository.fetchCategoryById(categoryId);
      _categoryById = response;

      // If we successfully fetched the category, populate the form fields
      if (_categoryById != null) {
        _populateFormFromCategory(_categoryById);
        _canHaveChild = _categoryById?.data?.canHaveChildItems ?? false;
        _isWithdrawn = _categoryById?.data?.isWithdrawn ?? false;
      }
    } catch (e) {
      _errorMessageById = e.toString();
      _categoryById = null;
    } finally {
      _isLoadingById = false;
      notifyListeners();
    }
  }

  void _populateFormFromCategory(dynamic categoryResponse) {
    // Handle both nested data structure and direct structure
    final categoryData =
        categoryResponse is Map<String, dynamic>
            ? (categoryResponse['data'] ?? categoryResponse)
            : categoryResponse;

    if (categoryData != null) {
      // Set the checkbox states - adjust property names based on your actual API response
      // _canHaveChild = categoryData['canHaveChildItems'] ?? false;
      // _isWithdrawn = categoryData['isWithdrawn'] ?? false;
    }

    // Note: The text controllers will be populated in the UI layer
    // when the provider notifies listeners
    notifyListeners();
  }

  // Method to get form data for UI population
  Map<String, String> getFormData() {
    if (_categoryById?.data == null) return {};

    final data = _categoryById!.data;
    return {
      'categoryName': data?.categoryName?.toString() ?? '',
      'categoryCode': data?.categoryCode?.toString() ?? '',
      'description': data?.description?.toString() ?? '',
      'descriptionTemplate': data?.descriptionTemplate?.toString() ?? '',
      'instructions': data?.instructions?.toString() ?? '',
      'notes': data?.notes?.toString() ?? '',
      'replacementPeriod': data?.replacementPeriod?.toString() ?? '',
      // Add parent category if available
      // 'parentCategory': data?.parentCategoryName?.toString() ?? '',
    };
  }

  void clearCategoryById() {
    _categoryById = null;
    _errorMessageById = null;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.fetchCategory();
      if (_categories?.data != null) {
        _allCategories = _buildCategoryHierarchy(_categories!.data!);
        _filteredCategories = List.from(_allCategories);
        _updateFlattenedList();
      } else {
        _errorMessage = 'No categories found';
        _allCategories = [];
        _filteredCategories = [];
        _flattenedCategories = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _categories = null;
      _allCategories = [];
      _filteredCategories = [];
      _flattenedCategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------
  // ✅ NEW: Create/Update Category Function
  // -----------------------------
  bool _isCreating = false;
  String? _createErrorMessage;

  bool get isCreating => _isCreating;

  String? get createErrorMessage => _createErrorMessage;

  Future<bool> createCategory({
    String? categoryId, // Add categoryId for update functionality
    required String categoryName,
    required String categoryCode,
    required String description,
    required String descriptionTemplate,
    String? parentId,
    int? replacementPeriod,
    String instructions = '',
    String notes = '',
    bool canHaveChildItems = false,
    String regulationId = '',
    String checklistId = '',
    String plannedMaintenanceId = '',
  }) async {
    _isCreating = true;
    _createErrorMessage = null;
    notifyListeners();

    try {
      if (categoryId != null) {
        // Update existing category (you'll need to implement updateCategory in repository)
        await _categoryRepository.updateCategory(
          categoryId: categoryId,
          categoryName: categoryName,
          categoryCode: categoryCode,
          description: description,
          descriptionTemplate: descriptionTemplate,
          replacementPeriod: replacementPeriod ?? 0,
          instructions: instructions,
          notes: notes,
          canHaveChildItems: canHaveChildItems,
          regulationId: regulationId,
          checklistId: checklistId,
          plannedMaintenanceId: plannedMaintenanceId,
        );
      } else {
        // Create new category
        await _categoryRepository.createCategory(
          categoryName: categoryName,
          categoryCode: categoryCode,
          description: description,
          descriptionTemplate: descriptionTemplate,
          replacementPeriod: replacementPeriod ?? 0,
          instructions: instructions,
          notes: notes,
          canHaveChildItems: canHaveChildItems,
          regulationId: regulationId,
          checklistId: checklistId,
          plannedMaintenanceId: plannedMaintenanceId,
        );
      }

      // Refresh categories after successful creation/update
      await fetchCategories();

      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _createErrorMessage = e.toString();
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  void clearCreateError() {
    _createErrorMessage = null;
    notifyListeners();
  }

  List<CategoryItem> _buildCategoryHierarchy(List<Datum> apiData) {
    Map<String, CategoryItem> categoryMap = {};
    List<CategoryItem> rootCategories = [];

    // First pass: Create all CategoryItem objects
    for (var datum in apiData) {
      if (datum.categoryId != null) {
        categoryMap[datum.categoryId!] = CategoryItem(
          id: datum.categoryId!,
          name: datum.categoryName ?? 'Unknown Category',
          parentId: datum.parentId?.toString(),
          canHaveChildItems: datum.canHaveChildItems ?? false,
          categoryCode: datum.categoryCode,
          description: datum.description,
        );
      }
    }

    // Second pass: Build the hierarchy and set levels
    for (var categoryItem in categoryMap.values) {
      if (categoryItem.parentId == null || categoryItem.parentId!.isEmpty) {
        categoryItem.level = 0;
        rootCategories.add(categoryItem);
      } else {
        CategoryItem? parent = categoryMap[categoryItem.parentId];
        if (parent != null) {
          categoryItem.level = parent.level + 1;
          parent.children.add(categoryItem);
        } else {
          // If parent not found, treat as root
          categoryItem.level = 0;
          rootCategories.add(categoryItem);
        }
      }
    }

    // Sort children at each level for consistent display
    _sortChildrenRecursively(rootCategories);
    return rootCategories;
  }

  void _sortChildrenRecursively(List<CategoryItem> categories) {
    for (var category in categories) {
      if (category.children.isNotEmpty) {
        category.children.sort((a, b) => a.name.compareTo(b.name));
        _sortChildrenRecursively(category.children);
      }
    }
  }

  // -----------------------------
  // ✅ Flattened List for ListView Display
  // -----------------------------
  void _updateFlattenedList() {
    _flattenedCategories = _flattenCategories(_filteredCategories);
  }

  List<CategoryItem> _flattenCategories(List<CategoryItem> categories) {
    List<CategoryItem> flattened = [];

    for (var category in categories) {
      flattened.add(category);

      if (category.isExpanded && category.children.isNotEmpty) {
        flattened.addAll(_flattenCategories(category.children));
      }
    }

    return flattened;
  }

  // -----------------------------
  // ✅ Search logic - IMPROVED
  // -----------------------------
  void searchCategories(String query) {
    if (query.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredCategories =
          _allCategories
              .map((cat) => _filterCategoryWithChildren(cat, lowerQuery))
              .where((cat) => cat != null)
              .cast<CategoryItem>()
              .toList();
    }
    _updateFlattenedList();
    notifyListeners();
  }

  CategoryItem? _filterCategoryWithChildren(CategoryItem category, String query) {
    bool categoryMatches =
        category.name.toLowerCase().contains(query) ||
        (category.categoryCode?.toLowerCase().contains(query) ?? false);

    List<CategoryItem> filteredChildren = [];
    for (var child in category.children) {
      var filteredChild = _filterCategoryWithChildren(child, query);
      if (filteredChild != null) {
        filteredChildren.add(filteredChild);
      }
    }

    if (categoryMatches || filteredChildren.isNotEmpty) {
      var newCategory = CategoryItem(
        id: category.id,
        name: category.name,
        parentId: category.parentId,
        canHaveChildItems: category.canHaveChildItems,
        categoryCode: category.categoryCode,
        description: category.description,
        level: category.level,
        isExpanded: filteredChildren.isNotEmpty || category.isExpanded,
        children: filteredChildren,
      );
      return newCategory;
    }

    return null;
  }

  // -----------------------------
  // ✅ Expand / Collapse - IMPROVED
  // -----------------------------
  void toggleExpansion(CategoryItem item) {
    _toggleExpansionRecursive(_allCategories, item.id);
    _filteredCategories = List.from(_allCategories);
    _updateFlattenedList();
    notifyListeners();
  }

  void _toggleExpansionRecursive(List<CategoryItem> categories, String targetId) {
    for (var category in categories) {
      if (category.id == targetId) {
        category.isExpanded = !category.isExpanded;
        return;
      }
      if (category.children.isNotEmpty) {
        _toggleExpansionRecursive(category.children, targetId);
      }
    }
  }

  // -----------------------------
  // ✅ Helpers
  // -----------------------------
  Future<void> refresh() async {
    await fetchCategories();
  }

  int get totalItemCount => _flattenedCategories.length;

  // Get category by ID from flattened list for ListView
  CategoryItem? getCategoryByIndex(int index) {
    if (index >= 0 && index < _flattenedCategories.length) {
      return _flattenedCategories[index];
    }
    return null;
  }

  // Reset all form-related state (useful when navigating away from form)
  void resetFormState() {
    _categoryById = null;
    _createErrorMessage = null;
    _errorMessageById = null;
    _canHaveChild = false;
    _isWithdrawn = false;
    notifyListeners();
  }
}
