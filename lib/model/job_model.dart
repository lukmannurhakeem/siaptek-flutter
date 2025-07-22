class JobModel {
  final String registerNum;
  final String customerName;
  final String siteName;
  final Status statusCode;
  final DateTime startDate;
  final DateTime endDate;

  JobModel(
    this.registerNum,
    this.customerName,
    this.siteName,
    this.statusCode,
    this.startDate,
    this.endDate,
  );
}

enum Status { started, cancelled, pending }
