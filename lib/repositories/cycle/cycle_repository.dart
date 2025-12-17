import 'package:INSPECT/model/cycle_model.dart';

abstract class CycleRepository {
  Future<CycleModel> fetchCycles({int? page, int? pageSize});

  Future<Map<String, dynamic>?> createCycle({
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int length,
    int? minLength,
    int? maxLength,
  });

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
  });

  Future<void> deleteCycle(String cycleId);

  Future<Map<String, dynamic>?> getCycleDetails(String cycleId);
}
