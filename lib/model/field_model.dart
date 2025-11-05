// field_model.dart - REPLACE your existing FieldModel with this enhanced version

class FieldModel {
  final String id;
  final String labelText;
  final String name;
  final String fieldType;
  final String defaultValue;
  final bool isReadOnly;
  final String section;
  final bool required;
  final bool isArchived;
  final Map<String, String> permissions;

  // Additional properties for different field types
  final List<String>? dropdownOptions;
  final String? fileExtension;
  final String? conditionalSource;
  final String? conditionalOperator;
  final String? conditionalValue;
  final double? minValue;
  final double? maxValue;
  final double? stepValue;
  final int? decimalPlaces;

  FieldModel({
    required this.id,
    required this.labelText,
    required this.name,
    required this.fieldType,
    this.defaultValue = '',
    this.isReadOnly = false,
    this.section = '',
    this.required = false,
    this.isArchived = false,
    this.permissions = const {'create': 'Any', 'view': 'Any'},
    this.dropdownOptions,
    this.fileExtension,
    this.conditionalSource,
    this.conditionalOperator,
    this.conditionalValue,
    this.minValue,
    this.maxValue,
    this.stepValue,
    this.decimalPlaces,
  });

  FieldModel copyWith({
    String? id,
    String? labelText,
    String? name,
    String? fieldType,
    String? defaultValue,
    bool? isReadOnly,
    String? section,
    bool? required,
    bool? isArchived,
    Map<String, String>? permissions,
    List<String>? dropdownOptions,
    String? fileExtension,
    String? conditionalSource,
    String? conditionalOperator,
    String? conditionalValue,
    double? minValue,
    double? maxValue,
    double? stepValue,
    int? decimalPlaces,
  }) {
    return FieldModel(
      id: id ?? this.id,
      labelText: labelText ?? this.labelText,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      defaultValue: defaultValue ?? this.defaultValue,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      section: section ?? this.section,
      required: required ?? this.required,
      isArchived: isArchived ?? this.isArchived,
      permissions: permissions ?? this.permissions,
      dropdownOptions: dropdownOptions ?? this.dropdownOptions,
      fileExtension: fileExtension ?? this.fileExtension,
      conditionalSource: conditionalSource ?? this.conditionalSource,
      conditionalOperator: conditionalOperator ?? this.conditionalOperator,
      conditionalValue: conditionalValue ?? this.conditionalValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      stepValue: stepValue ?? this.stepValue,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    );
  }

  // Helper method to convert to JSON (useful for API calls)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labelText': labelText,
      'name': name,
      'fieldType': fieldType,
      'defaultValue': defaultValue,
      'isReadOnly': isReadOnly,
      'section': section,
      'required': required,
      'isArchived': isArchived,
      'permissions': permissions,
      if (dropdownOptions != null) 'dropdownOptions': dropdownOptions,
      if (fileExtension != null) 'fileExtension': fileExtension,
      if (conditionalSource != null) 'conditionalSource': conditionalSource,
      if (conditionalOperator != null) 'conditionalOperator': conditionalOperator,
      if (conditionalValue != null) 'conditionalValue': conditionalValue,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (stepValue != null) 'stepValue': stepValue,
      if (decimalPlaces != null) 'decimalPlaces': decimalPlaces,
    };
  }

  // Helper method to create from JSON (useful for API responses)
  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as String,
      labelText: json['labelText'] as String,
      name: json['name'] as String,
      fieldType: json['fieldType'] as String,
      defaultValue: json['defaultValue'] as String? ?? '',
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      section: json['section'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      permissions:
          json['permissions'] != null
              ? Map<String, String>.from(json['permissions'])
              : const {'create': 'Any', 'view': 'Any'},
      dropdownOptions:
          json['dropdownOptions'] != null ? List<String>.from(json['dropdownOptions']) : null,
      fileExtension: json['fileExtension'] as String?,
      conditionalSource: json['conditionalSource'] as String?,
      conditionalOperator: json['conditionalOperator'] as String?,
      conditionalValue: json['conditionalValue'] as String?,
      minValue: json['minValue'] != null ? (json['minValue'] as num).toDouble() : null,
      maxValue: json['maxValue'] != null ? (json['maxValue'] as num).toDouble() : null,
      stepValue: json['stepValue'] != null ? (json['stepValue'] as num).toDouble() : null,
      decimalPlaces: json['decimalPlaces'] as int?,
    );
  }
}
