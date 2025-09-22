import 'package:base_app/model/create_category_model.dart';
import 'package:base_app/model/get_category_model.dart';

abstract class CategoryRepository {
  Future<GetCategoryModel> fetchCategory();

  Future<CreateCategoryModel> fetchCategoryById(String id);

  Future<void> createCategory({
    String? categoryName,
    String? categoryCode,
    String? description,
    String? descriptionTemplate,
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
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  });
}
