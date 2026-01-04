import 'dart:convert';
import 'collection.dart';
import 'environment.dart';
import 'http_request.dart';

/// Utility class for converting between our models and Postman JSON format
/// This maintains compatibility with Postman while using our unified models
class PostmanConverter {
  /// Convert Postman JSON string to our Collection model
  static Collection? collectionFromPostmanJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Collection.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Convert our Collection model to Postman JSON string
  static String? collectionToPostmanJson(Collection collection) {
    try {
      return jsonEncode(collection.toJson());
    } catch (e) {
      return null;
    }
  }

  /// Convert Postman JSON string to our Environment model
  static Environment? environmentFromPostmanJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Environment.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Convert our Environment model to Postman JSON string
  static String? environmentToPostmanJson(Environment environment) {
    try {
      return jsonEncode(environment.toJson());
    } catch (e) {
      return null;
    }
  }

  /// Convert Postman JSON to our HttpRequest model
  static HttpRequest? requestFromPostmanJson(Map<String, dynamic> json) {
    try {
      return HttpRequest.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Convert our HttpRequest model to Postman JSON
  static Map<String, dynamic> requestToPostmanJson(HttpRequest request) {
    return request.toJson();
  }
}
