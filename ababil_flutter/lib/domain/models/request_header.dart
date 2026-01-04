class RequestHeader {
  final String key;
  final String value;
  final bool? disabled;
  final String? description;

  RequestHeader({
    required this.key,
    required this.value,
    this.disabled,
    this.description,
  });

  factory RequestHeader.fromJson(Map<String, dynamic> json) {
    return RequestHeader(
      key: json['key'] as String,
      value: json['value'] as String,
      disabled: json['disabled'] as bool?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      if (disabled != null) 'disabled': disabled,
      if (description != null) 'description': description,
    };
  }
}
