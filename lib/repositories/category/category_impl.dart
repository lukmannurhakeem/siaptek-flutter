// category_impl.dart

import 'package:INSPECT/core/service/offline_http_service.dart';
import 'package:INSPECT/model/create_category_model.dart';
import 'package:INSPECT/model/get_category_model.dart';
import 'package:INSPECT/repositories/category/category_repository.dart';
import 'package:INSPECT/route/endpoint.dart';

class CategoryImpl implements CategoryRepository {
  final OfflineHttpService _api;

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
    String? parentId, // Added parentId parameter
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems = false,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  }) async {
    // Build the data map
    final data = {
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
    };

    // Only add parentId if it's not null and not empty
    if (parentId != null && parentId.isNotEmpty) {
      data['parentId'] = parentId;
    }

    final response = await _api.post(Endpoint.categoryCreate, requiresAuth: true, data: data);

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
    String? parentId, // Added parentId parameter
    int? replacementPeriod,
    String? instructions,
    String? notes,
    bool canHaveChildItems = false,
    String? regulationId,
    String? checklistId,
    String? plannedMaintenanceId,
  }) async {
    // Build the data map
    final data = {
      'categoryId': categoryId, // Use categoryId for update, not parentId
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
    };

    // Only add parentId if it's not null and not empty
    if (parentId != null && parentId.isNotEmpty) {
      data['parentId'] = parentId;
    }

    final response = await _api.post(
      Endpoint.categoryCreate, // You might want to use a different endpoint for update
      requiresAuth: true,
      data: data,
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
