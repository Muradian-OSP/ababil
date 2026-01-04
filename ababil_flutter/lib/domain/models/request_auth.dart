import 'request_variable.dart';

class RequestAuth {
  final String? type;
  final List<RequestVariable>? bearer;
  final List<RequestVariable>? basic;
  final List<RequestVariable>? digest;
  final List<RequestVariable>? awsv4;
  final List<RequestVariable>? hawk;
  final dynamic noauth;
  final List<RequestVariable>? oauth1;
  final List<RequestVariable>? oauth2;
  final List<RequestVariable>? ntlm;

  RequestAuth({
    this.type,
    this.bearer,
    this.basic,
    this.digest,
    this.awsv4,
    this.hawk,
    this.noauth,
    this.oauth1,
    this.oauth2,
    this.ntlm,
  });

  factory RequestAuth.fromJson(Map<String, dynamic> json) {
    return RequestAuth(
      type: json['type'] as String?,
      bearer: json['bearer'] != null
          ? (json['bearer'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      basic: json['basic'] != null
          ? (json['basic'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      digest: json['digest'] != null
          ? (json['digest'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      awsv4: json['awsv4'] != null
          ? (json['awsv4'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      hawk: json['hawk'] != null
          ? (json['hawk'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      noauth: json['noauth'],
      oauth1: json['oauth1'] != null
          ? (json['oauth1'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      oauth2: json['oauth2'] != null
          ? (json['oauth2'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      ntlm: json['ntlm'] != null
          ? (json['ntlm'] as List)
                .map((e) => RequestVariable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (bearer != null) 'bearer': bearer!.map((e) => e.toJson()).toList(),
      if (basic != null) 'basic': basic!.map((e) => e.toJson()).toList(),
      if (digest != null) 'digest': digest!.map((e) => e.toJson()).toList(),
      if (awsv4 != null) 'awsv4': awsv4!.map((e) => e.toJson()).toList(),
      if (hawk != null) 'hawk': hawk!.map((e) => e.toJson()).toList(),
      if (noauth != null) 'noauth': noauth,
      if (oauth1 != null) 'oauth1': oauth1!.map((e) => e.toJson()).toList(),
      if (oauth2 != null) 'oauth2': oauth2!.map((e) => e.toJson()).toList(),
      if (ntlm != null) 'ntlm': ntlm!.map((e) => e.toJson()).toList(),
    };
  }
}
