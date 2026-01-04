import 'package:flutter/material.dart';
import 'package:ababil_flutter/data/repositories/http_repository.dart';
import 'package:ababil_flutter/domain/models/http_request.dart';
import 'package:ababil_flutter/domain/models/http_response.dart';
import 'package:ababil_flutter/domain/models/request_path.dart';
import 'package:ababil_flutter/domain/models/request_url.dart';
import 'package:ababil_flutter/domain/models/request_header.dart';
import 'package:ababil_flutter/domain/models/request_body.dart';
import 'package:ababil_flutter/domain/models/request_auth.dart';
import 'package:ababil_flutter/ui/viewmodels/collections_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HttpRepository _httpRepository;
  CollectionsViewModel? _collectionsViewModel;

  HomeViewModel({HttpRepository? httpRepository})
    : _httpRepository = httpRepository ?? HttpRepository();

  // State - HttpRequest is the single source of truth
  HttpRequest _currentRequest = HttpRequest(
    method: 'GET',
    url: RequestUrl(raw: 'https://jsonplaceholder.typicode.com/posts'),
  );
  HttpResponse? _response;
  bool _isLoading = false;
  String? _error;

  // Track current request being edited from collection using RequestPath
  RequestPath? _currentRequestPath;
  bool _isLoadingRequest = false; // Prevent sync during load

  // Getters - extract from HttpRequest
  String get url => _currentRequest.url?.raw?.split('?').first ?? '';
  String get selectedMethod => _currentRequest.method ?? 'GET';
  String get body => _currentRequest.body?.raw ?? '';

  // Headers - convert List to Map for easier access
  Map<String, RequestHeader> get headers {
    final headerMap = <String, RequestHeader>{};
    if (_currentRequest.header != null) {
      for (final header in _currentRequest.header!) {
        headerMap[header.key] = header;
      }
    }
    return headerMap;
  }

  // Params - extract from URL query
  Map<String, QueryParam> get params {
    final paramMap = <String, QueryParam>{};
    if (_currentRequest.url?.query != null) {
      for (final param in _currentRequest.url!.query!) {
        paramMap[param.key] = param;
      }
    }
    return paramMap;
  }

  // Convenience getters for UI (Map<String, String> format)
  Map<String, String> get headersMap => Map.fromEntries(
    headers.entries.map((e) => MapEntry(e.key, e.value.value)),
  );
  Map<String, String> get paramsMap => Map.fromEntries(
    params.entries.map((e) => MapEntry(e.key, e.value.value ?? '')),
  );

  // Convenience getters for disabled state
  Set<String> get disabledHeaders => headers.entries
      .where((e) => e.value.disabled == true)
      .map((e) => e.key)
      .toSet();
  Set<String> get disabledParams => params.entries
      .where((e) => e.value.disabled == true)
      .map((e) => e.key)
      .toSet();

  bool isHeaderEnabled(String key) => headers[key]?.disabled != true;
  bool isParamEnabled(String key) => params[key]?.disabled != true;
  RequestAuth? get auth => _currentRequest.auth;
  HttpResponse? get response => _response;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set collections view model for syncing
  void setCollectionsViewModel(CollectionsViewModel viewModel) {
    _collectionsViewModel = viewModel;
  }

  // Helper to update the current request
  void _updateRequest(HttpRequest Function(HttpRequest) updater) {
    _currentRequest = updater(_currentRequest);
    if (!_isLoadingRequest) {
      _syncToCollection();
    }
    notifyListeners();
  }

  // Setters with auto-sync (only sync if editing from collection and not loading)
  void setUrl(String value) {
    _updateRequest((req) {
      // Preserve existing query params
      final existingQuery = req.url?.query;
      return req.copyWith(
        url: RequestUrl(raw: value, query: existingQuery),
      );
    });
  }

  void setMethod(String method) {
    _updateRequest((req) => req.copyWith(method: method));
  }

  void setBody(String value) {
    _updateRequest((req) {
      final body = value.isNotEmpty
          ? RequestBody(mode: 'raw', raw: value)
          : null;
      return req.copyWith(body: body);
    });
  }

  void addHeader(String key, String value) {
    _updateRequest((req) {
      final newHeader = RequestHeader(key: key, value: value, disabled: false);
      final updatedHeaders = List<RequestHeader>.from(req.header ?? [])
        ..removeWhere((h) => h.key == key)
        ..add(newHeader);
      return req.copyWith(header: updatedHeaders);
    });
  }

  void removeHeader(String key) {
    _updateRequest((req) {
      final updatedHeaders = req.header?.where((h) => h.key != key).toList();
      return req.copyWith(
        header: updatedHeaders?.isEmpty ?? true ? null : updatedHeaders,
      );
    });
  }

  void toggleHeaderEnabled(String key) {
    _updateRequest((req) {
      final updatedHeaders = req.header?.map((h) {
        if (h.key == key) {
          return RequestHeader(
            key: h.key,
            value: h.value,
            disabled: !(h.disabled ?? false),
            description: h.description,
          );
        }
        return h;
      }).toList();
      return req.copyWith(header: updatedHeaders);
    });
  }

  void clearHeaders() {
    _updateRequest((req) => req.copyWith(header: null));
  }

  void addParam(String key, String value) {
    _updateRequest((req) {
      final newParam = QueryParam(key: key, value: value, disabled: false);
      final currentUrl = req.url ?? RequestUrl();
      final updatedQuery = List<QueryParam>.from(currentUrl.query ?? [])
        ..removeWhere((p) => p.key == key)
        ..add(newParam);
      return req.copyWith(
        url: RequestUrl(
          raw: currentUrl.raw,
          protocol: currentUrl.protocol,
          host: currentUrl.host,
          path: currentUrl.path,
          query: updatedQuery,
          variable: currentUrl.variable,
        ),
      );
    });
  }

  void removeParam(String key) {
    _updateRequest((req) {
      final currentUrl = req.url ?? RequestUrl();
      final updatedQuery = currentUrl.query
          ?.where((p) => p.key != key)
          .toList();
      return req.copyWith(
        url: RequestUrl(
          raw: currentUrl.raw,
          protocol: currentUrl.protocol,
          host: currentUrl.host,
          path: currentUrl.path,
          query: updatedQuery?.isEmpty ?? true ? null : updatedQuery,
          variable: currentUrl.variable,
        ),
      );
    });
  }

  void updateParam(String oldKey, String newKey, String newValue) {
    _updateRequest((req) {
      final currentUrl = req.url ?? RequestUrl();
      final oldParam = currentUrl.query?.firstWhere(
        (p) => p.key == oldKey,
        orElse: () => QueryParam(key: oldKey, value: '', disabled: false),
      );
      final wasDisabled = oldParam?.disabled ?? false;

      final updatedQuery = List<QueryParam>.from(currentUrl.query ?? [])
        ..removeWhere((p) => p.key == oldKey)
        ..add(
          QueryParam(
            key: newKey,
            value: newValue,
            disabled: wasDisabled,
            description: oldParam?.description,
          ),
        );
      return req.copyWith(
        url: RequestUrl(
          raw: currentUrl.raw,
          protocol: currentUrl.protocol,
          host: currentUrl.host,
          path: currentUrl.path,
          query: updatedQuery,
          variable: currentUrl.variable,
        ),
      );
    });
  }

  void toggleParamEnabled(String key) {
    _updateRequest((req) {
      final currentUrl = req.url ?? RequestUrl();
      final updatedQuery = currentUrl.query?.map((p) {
        if (p.key == key) {
          return QueryParam(
            key: p.key,
            value: p.value,
            disabled: !(p.disabled ?? false),
            description: p.description,
          );
        }
        return p;
      }).toList();
      return req.copyWith(
        url: RequestUrl(
          raw: currentUrl.raw,
          protocol: currentUrl.protocol,
          host: currentUrl.host,
          path: currentUrl.path,
          query: updatedQuery,
          variable: currentUrl.variable,
        ),
      );
    });
  }

  Future<void> sendRequest() async {
    if (url.isEmpty) {
      _error = 'Please enter a URL';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _response = null;
    notifyListeners();

    try {
      // Filter out disabled headers and params for the actual request
      final enabledHeaders = _currentRequest.header
          ?.where((h) => h.disabled != true)
          .toList();

      final enabledQueryParams = _currentRequest.url?.query
          ?.where((p) => p.disabled != true)
          .toList();

      // Build request with only enabled items
      final request = _currentRequest.copyWith(
        header: enabledHeaders?.isEmpty ?? true ? null : enabledHeaders,
        url: _currentRequest.url != null
            ? RequestUrl(
                raw: _currentRequest.url!.raw,
                protocol: _currentRequest.url!.protocol,
                host: _currentRequest.url!.host,
                path: _currentRequest.url!.path,
                query: enabledQueryParams?.isEmpty ?? true
                    ? null
                    : enabledQueryParams,
                variable: _currentRequest.url!.variable,
              )
            : null,
      );

      _response = await _httpRepository.sendRequest(request);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _response = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResponse() {
    _response = null;
    _error = null;
    notifyListeners();
  }

  void setAuth(RequestAuth? auth) {
    _updateRequest((req) => req.copyWith(auth: auth));
  }

  void loadFromPostmanRequest(
    HttpRequest postmanRequest, {
    RequestPath? requestPath,
  }) {
    // Prevent syncing during load
    _isLoadingRequest = true;

    // Track which request we're editing using RequestPath
    _currentRequestPath = requestPath;

    // Update the current request directly
    _currentRequest = postmanRequest;

    // Re-enable syncing after load is complete
    _isLoadingRequest = false;
    notifyListeners();
  }

  void clearCurrentRequest() {
    _currentRequestPath = null;
  }

  /// Get the current request path being edited
  RequestPath? get currentRequestPath => _currentRequestPath;

  /// Check if currently editing a request from collection
  bool get isEditingCollectionRequest => _currentRequestPath != null;

  // Sync current request state back to collection
  void _syncToCollection() {
    if (_collectionsViewModel == null || _currentRequestPath == null) {
      return;
    }

    try {
      // Ensure URL raw field includes query params if they exist
      final currentUrl = _currentRequest.url;
      if (currentUrl != null &&
          currentUrl.query != null &&
          currentUrl.query!.isNotEmpty) {
        final baseUrl = currentUrl.raw?.split('?').first ?? url;
        final queryString = currentUrl.query!
            .map(
              (p) =>
                  '${Uri.encodeComponent(p.key)}=${Uri.encodeComponent(p.value ?? '')}',
            )
            .join('&');
        final separator = baseUrl.contains('?') ? '&' : '?';
        final finalUrl = '$baseUrl$separator$queryString';

        _currentRequest = _currentRequest.copyWith(
          url: RequestUrl(
            raw: finalUrl,
            protocol: currentUrl.protocol,
            host: currentUrl.host,
            path: currentUrl.path,
            query: currentUrl.query,
            variable: currentUrl.variable,
          ),
        );
      }

      // Update in collection using RequestPath
      _collectionsViewModel!.updateRequestByPath(
        _currentRequestPath!,
        _currentRequest,
      );
    } catch (e) {
      debugPrint('Error syncing request to collection: $e');
    }
  }
}
