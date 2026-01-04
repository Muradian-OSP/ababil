class RequestBody {
  final String? mode;
  final String? raw;
  final List<FormData>? urlencoded;
  final List<FormData>? formdata;
  final FileBody? file;
  final GraphQLBody? graphql;

  RequestBody({
    this.mode,
    this.raw,
    this.urlencoded,
    this.formdata,
    this.file,
    this.graphql,
  });

  factory RequestBody.fromJson(Map<String, dynamic> json) {
    return RequestBody(
      mode: json['mode'] as String?,
      raw: json['raw'] as String?,
      urlencoded: json['urlencoded'] != null
          ? (json['urlencoded'] as List)
                .map((e) => FormData.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      formdata: json['formdata'] != null
          ? (json['formdata'] as List)
                .map((e) => FormData.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      file: json['file'] != null
          ? FileBody.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      graphql: json['graphql'] != null
          ? GraphQLBody.fromJson(json['graphql'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mode != null) 'mode': mode,
      if (raw != null) 'raw': raw,
      if (urlencoded != null)
        'urlencoded': urlencoded!.map((e) => e.toJson()).toList(),
      if (formdata != null)
        'formdata': formdata!.map((e) => e.toJson()).toList(),
      if (file != null) 'file': file!.toJson(),
      if (graphql != null) 'graphql': graphql!.toJson(),
    };
  }
}

class FormData {
  final String key;
  final String? value;
  final String? type;
  final bool? disabled;
  final String? description;

  FormData({
    required this.key,
    this.value,
    this.type,
    this.disabled,
    this.description,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      key: json['key'] as String,
      value: json['value'] as String?,
      type: json['type'] as String?,
      disabled: json['disabled'] as bool?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      if (value != null) 'value': value,
      if (type != null) 'type': type,
      if (disabled != null) 'disabled': disabled,
      if (description != null) 'description': description,
    };
  }
}

class FileBody {
  final String? src;

  FileBody({this.src});

  factory FileBody.fromJson(Map<String, dynamic> json) {
    return FileBody(src: json['src'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {if (src != null) 'src': src};
  }
}

class GraphQLBody {
  final String? query;
  final String? variables;

  GraphQLBody({this.query, this.variables});

  factory GraphQLBody.fromJson(Map<String, dynamic> json) {
    return GraphQLBody(
      query: json['query'] as String?,
      variables: json['variables'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (query != null) 'query': query,
      if (variables != null) 'variables': variables,
    };
  }
}
