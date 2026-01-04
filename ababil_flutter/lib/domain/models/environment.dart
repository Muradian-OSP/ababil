import 'variable.dart';

class Environment {
  final String? id;
  final String name;
  final List<Variable>? values;
  final String? postmanVariableScope;
  final String? postmanExportedAt;
  final String? postmanExportedUsing;

  Environment({
    this.id,
    required this.name,
    this.values,
    this.postmanVariableScope,
    this.postmanExportedAt,
    this.postmanExportedUsing,
  });

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'] as String?,
      name: json['name'] as String,
      values: json['values'] != null
          ? (json['values'] as List)
                .map((e) => Variable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      postmanVariableScope: json['_postman_variable_scope'] as String?,
      postmanExportedAt: json['_postman_exported_at'] as String?,
      postmanExportedUsing: json['_postman_exported_using'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (values != null) 'values': values!.map((e) => e.toJson()).toList(),
      if (postmanVariableScope != null)
        '_postman_variable_scope': postmanVariableScope,
      if (postmanExportedAt != null) '_postman_exported_at': postmanExportedAt,
      if (postmanExportedUsing != null)
        '_postman_exported_using': postmanExportedUsing,
    };
  }
}
