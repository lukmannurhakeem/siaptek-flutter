import 'package:base_app/model/personnel_model.dart';

abstract class PersonnelRepository {
  Future<PersonnelModel> fetchPersonnel();
}
