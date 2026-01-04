import 'dart:convert';
import 'http_request.dart';
import 'request_header.dart';
import 'request_auth.dart';
import 'variable.dart';

class Collection {
  final CollectionInfo info;
  final List<CollectionItem> item;
  final List<Variable>? variable;
  final List<CollectionEvent>? event;
  final RequestAuth? auth;

  Collection({
    required this.info,
    required this.item,
    this.variable,
    this.event,
    this.auth,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      info: CollectionInfo.fromJson(json['info'] as Map<String, dynamic>),
      item: (json['item'] as List)
          .map((e) => CollectionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      variable: json['variable'] != null
          ? (json['variable'] as List)
                .map((e) => Variable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      event: json['event'] != null
          ? (json['event'] as List)
                .map((e) => CollectionEvent.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      auth: json['auth'] != null
          ? RequestAuth.fromJson(json['auth'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'info': info.toJson(),
      'item': item.map((e) => e.toJson()).toList(),
      if (variable != null)
        'variable': variable!.map((e) => e.toJson()).toList(),
      if (event != null) 'event': event!.map((e) => e.toJson()).toList(),
      if (auth != null) 'auth': auth!.toJson(),
    };
  }

  static Collection fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Collection.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class CollectionInfo {
  final String name;
  final String? description;
  final String? schema;
  final String? postmanId;
  final String? exporterId;

  CollectionInfo({
    required this.name,
    this.description,
    this.schema,
    this.postmanId,
    this.exporterId,
  });

  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    return CollectionInfo(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema: json['schema'] as String?,
      postmanId: json['_postman_id'] as String?,
      exporterId: json['_exporter_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (schema != null) 'schema': schema,
      if (postmanId != null) '_postman_id': postmanId,
      if (exporterId != null) '_exporter_id': exporterId,
    };
  }
}

class CollectionItem {
  final String name;
  final List<CollectionItem>? item;
  final HttpRequest? request;
  final List<CollectionResponse>? response;
  final List<CollectionEvent>? event;
  final String? description;
  final List<Variable>? variable;

  CollectionItem({
    required this.name,
    this.item,
    this.request,
    this.response,
    this.event,
    this.description,
    this.variable,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      name: json['name'] as String,
      item: json['item'] != null
          ? (json['item'] as List)
                .map((e) => CollectionItem.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      request: json['request'] != null
          ? HttpRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      response: json['response'] != null
          ? (json['response'] as List)
                .map(
                  (e) => CollectionResponse.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      event: json['event'] != null
          ? (json['event'] as List)
                .map((e) => CollectionEvent.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      description: json['description'] as String?,
      variable: json['variable'] != null
          ? (json['variable'] as List)
                .map((e) => Variable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (item != null) 'item': item!.map((e) => e.toJson()).toList(),
      if (request != null) 'request': request!.toJson(),
      if (response != null)
        'response': response!.map((e) => e.toJson()).toList(),
      if (event != null) 'event': event!.map((e) => e.toJson()).toList(),
      if (description != null) 'description': description,
      if (variable != null)
        'variable': variable!.map((e) => e.toJson()).toList(),
    };
  }
}

class CollectionResponse {
  final String? name;
  final HttpRequest? originalRequest;
  final String? status;
  final int? code;
  final List<RequestHeader>? header;
  final String? body;

  CollectionResponse({
    this.name,
    this.originalRequest,
    this.status,
    this.code,
    this.header,
    this.body,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      name: json['name'] as String?,
      originalRequest: json['originalRequest'] != null
          ? HttpRequest.fromJson(
              json['originalRequest'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] as String?,
      code: json['code'] as int?,
      header: json['header'] != null
          ? (json['header'] as List)
                .map((e) => RequestHeader.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      body: json['body'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (originalRequest != null) 'originalRequest': originalRequest!.toJson(),
      if (status != null) 'status': status,
      if (code != null) 'code': code,
      if (header != null) 'header': header!.map((e) => e.toJson()).toList(),
      if (body != null) 'body': body,
    };
  }
}

class CollectionEvent {
  final String? listen;
  final CollectionScript? script;
  final String? disabled;

  CollectionEvent({this.listen, this.script, this.disabled});

  factory CollectionEvent.fromJson(Map<String, dynamic> json) {
    return CollectionEvent(
      listen: json['listen'] as String?,
      script: json['script'] != null
          ? CollectionScript.fromJson(json['script'] as Map<String, dynamic>)
          : null,
      disabled: json['disabled'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (listen != null) 'listen': listen,
      if (script != null) 'script': script!.toJson(),
      if (disabled != null) 'disabled': disabled,
    };
  }
}

class CollectionScript {
  final String? type;
  final List<String>? exec;

  CollectionScript({this.type, this.exec});

  factory CollectionScript.fromJson(Map<String, dynamic> json) {
    return CollectionScript(
      type: json['type'] as String?,
      exec: json['exec'] != null
          ? List<String>.from(json['exec'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (type != null) 'type': type, if (exec != null) 'exec': exec};
  }
}
