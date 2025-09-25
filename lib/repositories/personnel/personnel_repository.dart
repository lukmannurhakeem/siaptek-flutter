import 'package:base_app/model/personnel_model.dart';

abstract class PersonnelRepository {
  Future<PersonnelModel> fetchPersonnel();

  Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> personnelData);
}
