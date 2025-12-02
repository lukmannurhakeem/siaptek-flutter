import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/cycle_model.dart';
import 'package:base_app/repositories/cycle/cycle_repository.dart';
import 'package:base_app/route/endpoint.dart';

class CycleImpl implements CycleRepository {
  final OfflineHttpService _api;

  CycleImpl(this._api);

  @override
  Future<CycleModel> fetchCycles({int? page, int? pageSize}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final response = await _api.get(
        Endpoint.getCycle, // Add this to your Endpoint class
        requiresAuth: true,
        queryParameters: queryParams,
      );

      return CycleModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch cycles: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> createCycle({
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int length,
    int? minLength,
    int? maxLength,
  }) async {
    try {
      final requestBody = {
        "reportTypeId": reportTypeId,
        if (categoryId != null) "categoryId": categoryId,
        if (customerId != null) "customerId": customerId,
        if (siteId != null) "siteId": siteId,
        "unit": unit,
        "length": length,
        if (minLength != null) "minLength": minLength,
        if (maxLength != null) "maxLength": maxLength,
      };

      print('Creating cycle with body: $requestBody'); // Debug log

      final response = await _api.post(Endpoint.createCycle, requiresAuth: true, data: requestBody);

      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {'message': 'Cycle saved locally. Will sync when online.', 'queued': true};
      }

      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to create cycle: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> updateCycle({
    required String cycleId,
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int length,
    int? minLength,
    int? maxLength,
  }) async {
    try {
      final requestBody = {
        "reportTypeId": reportTypeId,
        if (categoryId != null) "categoryId": categoryId,
        if (customerId != null) "customerId": customerId,
        if (siteId != null) "siteId": siteId,
        "unit": unit,
        "length": length,
        if (minLength != null) "minLength": minLength,
        if (maxLength != null) "maxLength": maxLength,
      };

      print('Updating cycle $cycleId with body: $requestBody'); // Debug log

      final response = await _api.put(
        '${Endpoint.createCycle}/$cycleId',
        requiresAuth: true,
        data: requestBody,
      );

      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {'message': 'Cycle update queued. Will sync when online.', 'queued': true};
      }

      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to update cycle: $e');
    }
  }

  @override
  Future<void> deleteCycle(String cycleId) async {
    try {
      final response = await _api.delete('${Endpoint.createCycle}/$cycleId', requiresAuth: true);

      if (response.statusCode == 202 && response.data['queued'] == true) {
        throw Exception('Cycle deletion queued. Will sync when online.');
      }
    } catch (e) {
      throw Exception('Failed to delete cycle: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCycleDetails(String cycleId) async {
    try {
      final response = await _api.get('${Endpoint.createCycle}/$cycleId', requiresAuth: true);
      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to get cycle details: $e');
    }
  }
}
