import 'request_header.dart';
import 'request_url.dart';
import 'request_body.dart';
import 'request_auth.dart';

/// Main HTTP request model
class HttpRequest {
  final String? method;
  final List<RequestHeader>? header;
  final RequestBody? body;
  final RequestUrl? url;
  final String? description;
  final RequestAuth? auth;

  HttpRequest({
    this.method,
    this.header,
    this.body,
    this.url,
    this.description,
    this.auth,
  });

  /// Helper constructor for simple requests (backward compatibility)
  HttpRequest.simple({
    required String method,
    required String url,
    Map<String, String> headers = const {},
    String? body,
  }) : this(
         method: method,
         url: RequestUrl(raw: url),
         header: headers.entries
             .map((e) => RequestHeader(key: e.key, value: e.value))
             .toList(),
         body: body != null ? RequestBody(mode: 'raw', raw: body) : null,
       );

  factory HttpRequest.fromJson(Map<String, dynamic> json) {
    return HttpRequest(
      method: json['method'] as String?,
      header: json['header'] != null
          ? (json['header'] as List)
                .map((e) => RequestHeader.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      body: json['body'] != null
          ? RequestBody.fromJson(json['body'] as Map<String, dynamic>)
          : null,
      url: json['url'] != null
          ? RequestUrl.fromJson(json['url'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      auth: json['auth'] != null
          ? RequestAuth.fromJson(json['auth'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (method != null) 'method': method,
      if (header != null) 'header': header!.map((e) => e.toJson()).toList(),
      if (body != null) 'body': body!.toJson(),
      if (url != null) 'url': url!.toJson(),
      if (description != null) 'description': description,
      if (auth != null) 'auth': auth!.toJson(),
    };
  }

  HttpRequest copyWith({
    String? method,
    List<RequestHeader>? header,
    RequestBody? body,
    RequestUrl? url,
    String? description,
    RequestAuth? auth,
  }) {
    return HttpRequest(
      method: method ?? this.method,
      header: header ?? this.header,
      body: body ?? this.body,
      url: url ?? this.url,
      description: description ?? this.description,
      auth: auth ?? this.auth,
    );
  }
}
