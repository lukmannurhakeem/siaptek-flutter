import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:base_app/route/endpoint.dart';

class PersonnelImpl implements PersonnelRepository {
  final ApiClient _api;

  PersonnelImpl(this._api);

  @override
  Future<PersonnelModel> fetchPersonnel() async {
    final response = await _api.get(Endpoint.personnelView, requiresAuth: true);
    return PersonnelModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> personnelData) async {
    final response = await _api.post(
      Endpoint.personnelCreate,
      data: personnelData,
      requiresAuth: true,
    );
    return response.data;
  }
}
