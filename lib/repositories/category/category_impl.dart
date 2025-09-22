import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/create_category_model.dart';
import 'package:base_app/model/get_category_model.dart';
import 'package:base_app/repositories/category/category_repository.dart';
import 'package:base_app/route/endpoint.dart';

class CategoryImpl implements CategoryRepository {
  final ApiClient _api;

  CategoryImpl(this._api);

  @override
  Future<GetCategoryModel> fetchCategory() async {
    final response = await _api.get(Endpoint.categoryView, requiresAuth: true);
    return GetCategoryModel.fromJson(response.data);
  }

  @override
  Future<void> createCategory({
    String? categoryName,
    String? categoryCode,
    String? description,
    String? descriptionTemplate,
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems = false,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  }) async {
    await _api.post(
      Endpoint.categoryCreate,
      requiresAuth: true,
      data: {
        'categoryName': categoryName,
        'categoryCode': categoryCode,
        'description': description,
        'descriptionTemplate': descriptionTemplate,
        'replacementPeriod': replacementPeriod,
        'instructions': instructions,
        'notes': notes,
        'canHaveChildItems': canHaveChildItems,
        'regulationId': regulationId,
        'checklistId': checklistId,
        'plannedMaintenanceId': plannedMaintenanceId,
      },
    );
  }

  @override
  Future<void> updateCategory({
    required String categoryId,
    String? categoryName,
    String? categoryCode,
    String? description,
    String? descriptionTemplate,
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems = false,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  }) async {
    await _api.post(
      Endpoint.categoryCreate,
      requiresAuth: true,
      data: {
        'parentId': categoryId,
        'categoryName': categoryName,
        'categoryCode': categoryCode,
        'description': description,
        'descriptionTemplate': descriptionTemplate,
        'replacementPeriod': replacementPeriod,
        'instructions': instructions,
        'notes': notes,
        'canHaveChildItems': canHaveChildItems,
        'regulationId': regulationId,
        'checklistId': checklistId,
        'plannedMaintenanceId': plannedMaintenanceId,
      },
    );
  }

  @override
  Future<CreateCategoryModel> fetchCategoryById(String id) async {
    final response = await _api.get(Endpoint.categoryViewById(categoryId: id), requiresAuth: true);
    return CreateCategoryModel.fromJson(response.data);
  }
}
