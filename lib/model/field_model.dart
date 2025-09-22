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
    );
  }
}
