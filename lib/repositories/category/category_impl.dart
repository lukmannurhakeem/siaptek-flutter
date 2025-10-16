import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/create_category_model.dart';
import 'package:base_app/model/get_category_model.dart';
import 'package:base_app/repositories/category/category_repository.dart';
import 'package:base_app/route/endpoint.dart';

class CategoryImpl implements CategoryRepository {
  final OfflineHttpService _api; // Changed from ApiClient

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
    final response = await _api.post(
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

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Category saved locally. Will sync when online.');
    }
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
    final response = await _api.post(
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

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Category update queued. Will sync when online.');
    }
  }

  @override
  Future<CreateCategoryModel> fetchCategoryById(String id) async {
    final response = await _api.get(Endpoint.categoryViewById(categoryId: id), requiresAuth: true);
    return CreateCategoryModel.fromJson(response.data);
  }
}
