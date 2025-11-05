class InspectionPlanModel {
  final String id;
  final String eventType;
  final String jobId;
  final String? itemId;
  final String? reportTypeId;
  final String planTitle;
  final String description;
  final String priority;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final int? estimatedDuration;
  final String status;
  final String assignedTo;
  final String assignmentType;
  final ChecklistItems? checklistItems;
  final Map<String, dynamic>? attendees;
  final String? notes;
  final PlanTags? tags;
  final String? createdBy;
  final String? completedBy;
  final DateTime? completedAt;
  final bool isQueued;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InspectionPlanModel({
    required this.id,
    required this.eventType,
    required this.jobId,
    this.itemId,
    this.reportTypeId,
    required this.planTitle,
    required this.description,
    required this.priority,
    this.plannedStartDate,
    this.plannedEndDate,
    this.estimatedDuration,
    required this.status,
    required this.assignedTo,
    required this.assignmentType,
    this.checklistItems,
    this.attendees,
    this.notes,
    this.tags,
    this.createdBy,
    this.completedBy,
    this.completedAt,
    this.isQueued = false,
    this.createdAt,
    this.updatedAt,
  });

  factory InspectionPlanModel.fromJson(Map<String, dynamic> json) {
    return InspectionPlanModel(
      // Handle both 'id' and 'planId' from API
      id: json['planId'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? 'test',
      jobId: json['jobId'] ?? '',
      itemId: json['itemId'],
      reportTypeId: json['reportTypeId'],
      planTitle: json['planTitle'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'normal',
      plannedStartDate:
          json['plannedStartDate'] != null ? DateTime.parse(json['plannedStartDate']) : null,
      plannedEndDate:
          json['plannedEndDate'] != null ? DateTime.parse(json['plannedEndDate']) : null,
      estimatedDuration: json['estimatedDuration'],
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'] ?? '',
      assignmentType: json['assignmentType'] ?? 'personnel',
      checklistItems:
          json['checklistItems'] != null ? ChecklistItems.fromJson(json['checklistItems']) : null,
      attendees: json['attendees'] as Map<String, dynamic>?,
      notes: json['notes'],
      tags: json['tags'] != null ? PlanTags.fromJson(json['tags']) : null,
      createdBy: json['createdBy']?.toString(),
      completedBy: json['completedBy']?.toString(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isQueued: json['isQueued'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': id, // API expects planId
      'eventType': eventType,
      'jobId': jobId,
      'itemId': itemId,
      'reportTypeId': reportTypeId,
      'planTitle': planTitle,
      'description': description,
      'priority': priority,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'status': status,
      'assignedTo': assignedTo,
      'assignmentType': assignmentType,
      'checklistItems': checklistItems?.toJson(),
      'attendees': attendees,
      'notes': notes,
      'tags': tags?.toJson(),
      'createdBy': createdBy,
      'completedBy': completedBy,
      'completedAt': completedAt?.toIso8601String(),
      'isQueued': isQueued,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  InspectionPlanModel copyWith({
    String? id,
    String? eventType,
    String? jobId,
    String? itemId,
    String? reportTypeId,
    String? planTitle,
    String? description,
    String? priority,
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    int? estimatedDuration,
    String? status,
    String? assignedTo,
    String? assignmentType,
    ChecklistItems? checklistItems,
    Map<String, dynamic>? attendees,
    String? notes,
    PlanTags? tags,
    String? createdBy,
    String? completedBy,
    DateTime? completedAt,
    bool? isQueued,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionPlanModel(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      jobId: jobId ?? this.jobId,
      itemId: itemId ?? this.itemId,
      reportTypeId: reportTypeId ?? this.reportTypeId,
      planTitle: planTitle ?? this.planTitle,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      plannedStartDate: plannedStartDate ?? this.plannedStartDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignmentType: assignmentType ?? this.assignmentType,
      checklistItems: checklistItems ?? this.checklistItems,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
      isQueued: isQueued ?? this.isQueued,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChecklistItems {
  final List<String> tasks;

  ChecklistItems({required this.tasks});

  factory ChecklistItems.fromJson(Map<String, dynamic> json) {
    return ChecklistItems(
      tasks: (json['tasks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'tasks': tasks};
  }
}

class PlanTags {
  final List<String> categories;

  PlanTags({required this.categories});

  factory PlanTags.fromJson(Map<String, dynamic> json) {
    return PlanTags(
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'categories': categories};
  }
}
