import 'request_variable.dart';

class RequestUrl {
  final String? raw;
  final String? protocol;
  final List<String>? host;
  final List<String>? path;
  final List<QueryParam>? query;
  final List<RequestVariable>? variable;

  RequestUrl({
    this.raw,
    this.protocol,
    this.host,
    this.path,
    this.query,
    this.variable,
  });

  factory RequestUrl.fromJson(Map<String, dynamic> json) {
    return RequestUrl(
      raw: json['raw'] as String?,
      protocol: json['protocol'] as String?,
      host: json['host'] != null
          ? List<String>.from(json['host'] as List)
          : null,
      path: json['path'] != null
          ? List<String>.from(json['path'] as List)
          : null,
      query: json['query'] != null
          ? (json['query'] as List)
                .map((e) => QueryParam.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      variable: json['variable'] != null
          ? (json['variable'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (raw != null) 'raw': raw,
      if (protocol != null) 'protocol': protocol,
      if (host != null) 'host': host,
      if (path != null) 'path': path,
      if (query != null) 'query': query!.map((e) => e.toJson()).toList(),
      if (variable != null)
        'variable': variable!.map((e) => e.toJson()).toList(),
    };
  }
}

class QueryParam {
  final String key;
  final String? value;
  final bool? disabled;
  final String? description;

  QueryParam({required this.key, this.value, this.disabled, this.description});

  factory QueryParam.fromJson(Map<String, dynamic> json) {
    return QueryParam(
      key: json['key'] as String,
      value: json['value'] as String?,
      disabled: json['disabled'] as bool?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      if (value != null) 'value': value,
      if (disabled != null) 'disabled': disabled,
      if (description != null) 'description': description,
    };
  }
}
