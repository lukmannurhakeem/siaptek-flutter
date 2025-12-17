// category_repository.dart

import 'package:INSPECT/model/create_category_model.dart';
import 'package:INSPECT/model/get_category_model.dart';

abstract class CategoryRepository {
  Future<GetCategoryModel> fetchCategory();

  Future<CreateCategoryModel> fetchCategoryById(String id);

  Future<void> createCategory({
    String? categoryName,
    String? categoryCode,
    String? description,
    String? descriptionTemplate,
    String? parentId, // Added parentId
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  });

  Future<void> updateCategory({
    required String categoryId,
    String? categoryName,
    String? categoryCode,
    String? description,
    String? descriptionTemplate,
    String? parentId, // Added parentId
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  });
}
