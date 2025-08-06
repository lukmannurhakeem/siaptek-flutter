class JobRegisterModel {
  final String id;
  final String item;
  final String description;
  final String category;
  final String location;
  final String status;
  final DateTime inspectedOn;
  final DateTime? expiryDate;
  final String archived;

  JobRegisterModel({
    required this.id,
    required this.item,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.inspectedOn,
    required this.expiryDate,
    required this.archived,
  });
}
