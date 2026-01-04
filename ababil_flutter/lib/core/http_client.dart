import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';

typedef MakeHttpRequestNative =
    Pointer<Utf8> Function(
      Pointer<Utf8> method,
      Pointer<Utf8> url,
      Pointer<Utf8> headers,
      Pointer<Utf8> body,
    );

typedef MakeHttpRequestDart =
    Pointer<Utf8> Function(
      Pointer<Utf8> method,
      Pointer<Utf8> url,
      Pointer<Utf8> headers,
      Pointer<Utf8> body,
    );

typedef FreeStringNative = Void Function(Pointer<Utf8>);
typedef FreeStringDart = void Function(Pointer<Utf8>);

class HttpClient {
  static DynamicLibrary? _dylib;
  static MakeHttpRequestDart? _makeHttpRequest;
  static FreeStringDart? _freeString;

  static Future<void> initialize() async {
    if (_dylib != null) return;

    try {
      if (Platform.isAndroid) {
        _dylib = DynamicLibrary.open('libababil_core.so');
      } else if (Platform.isIOS) {
        _dylib = DynamicLibrary.process();
      } else if (Platform.isMacOS) {
        // For macOS, try multiple locations
        final List<String> pathsToTry = [];

        // Get the executable path to find the app bundle
        final executablePath = Platform.resolvedExecutable;
        final executableDir = File(executablePath).parent.path;

        // 1. Try app bundle Frameworks (Contents/Frameworks inside .app)
        // This is the standard location for frameworks in macOS apps
        pathsToTry.add('$executableDir/../Frameworks/libababil_core.dylib');

        // 2. Try app bundle Resources (alternative location)
        pathsToTry.add('$executableDir/../Resources/libababil_core.dylib');

        // 3. Try development path (when running with flutter run)
        final currentDir = Directory.current.path;
        pathsToTry.add(
          '$currentDir/macos/Runner/Frameworks/libababil_core.dylib',
        );
        pathsToTry.add(
          '$currentDir/ababil_flutter/macos/Runner/Frameworks/libababil_core.dylib',
        );

        // 4. Try Documents directory approach
        try {
          final directory = await getApplicationDocumentsDirectory();
          pathsToTry.add(
            '${directory.path}/../Frameworks/libababil_core.dylib',
          );
        } catch (e) {
          // Ignore if we can't get documents directory
        }

        // 5. Try relative to executable
        pathsToTry.add('libababil_core.dylib');

        // 6. Try absolute path from project root
        final homeDir = Platform.environment['HOME'] ?? '';
        if (homeDir.isNotEmpty) {
          pathsToTry.add(
            '$homeDir/Projects/open-source/ababil/ababil_flutter/macos/Runner/Frameworks/libababil_core.dylib',
          );
          pathsToTry.add(
            '$homeDir/Projects/open-source/ababil/ababil_core/target/release/libababil_core.dylib',
          );
        }

        Object? lastException;
        for (final path in pathsToTry) {
          try {
            _dylib = DynamicLibrary.open(path);
            print('Successfully loaded library from: $path');
            break;
          } catch (e) {
            lastException = e;
            // Only print debug info if all paths fail
          }
        }

        if (_dylib == null) {
          print(
            'ERROR: Could not load libababil_core.dylib from any of these paths:',
          );
          for (final path in pathsToTry) {
            final file = File(path);
            final exists = file.existsSync();
            print(
              '  ${exists ? "✓" : "✗"} $path ${exists ? "(exists)" : "(not found)"}',
            );
          }
          if (lastException != null) {
            print('Last error: $lastException');
          }
          print('\nTo fix this:');
          print(
            '1. Build the Rust core: cd ababil_core && cargo build --release',
          );
          print(
            '2. Copy the library: cp ababil_core/target/release/libababil_core.dylib ababil_flutter/macos/Runner/Frameworks/',
          );
          print('3. Or run: ./build.sh');
        }
      } else if (Platform.isLinux) {
        _dylib = DynamicLibrary.open('libababil_core.so');
      } else if (Platform.isWindows) {
        _dylib = DynamicLibrary.open('ababil_core.dll');
      }

      if (_dylib != null) {
        _makeHttpRequest = _dylib!
            .lookupFunction<MakeHttpRequestNative, MakeHttpRequestDart>(
              'make_http_request',
            );
        _freeString = _dylib!.lookupFunction<FreeStringNative, FreeStringDart>(
          'free_string',
        );
      }
    } catch (e) {
      print('Error loading native library: $e');
      print(
        'Make sure to build the Rust library first: cd ababil_core && cargo build --release',
      );
    }
  }

  static Future<HttpResponse> makeRequest({
    required String method,
    required String url,
    Map<String, String> headers = const {},
    String? body,
  }) async {
    await initialize();

    if (_makeHttpRequest == null || _freeString == null) {
      return HttpResponse(
        statusCode: 0,
        headers: {},
        body:
            'Error: Native library not loaded. Please build the Rust core first.',
        durationMs: 0,
      );
    }

    try {
      final methodPtr = method.toNativeUtf8();
      final urlPtr = url.toNativeUtf8();
      final headersJson = jsonEncode(
        headers.entries.map((e) => [e.key, e.value]).toList(),
      );
      final headersPtr = headersJson.toNativeUtf8();
      final bodyPtr = body?.toNativeUtf8() ?? Pointer<Utf8>.fromAddress(0);

      final responsePtr = _makeHttpRequest!(
        methodPtr,
        urlPtr,
        headersPtr,
        bodyPtr,
      );

      if (responsePtr.address == 0) {
        return HttpResponse(
          statusCode: 0,
          headers: {},
          body: 'Error: Null response from native library',
          durationMs: 0,
        );
      }

      final responseJson = responsePtr.toDartString();
      _freeString!(responsePtr);

      malloc.free(methodPtr);
      malloc.free(urlPtr);
      malloc.free(headersPtr);
      if (bodyPtr.address != 0) {
        malloc.free(bodyPtr);
      }

      return _parseResponse(responseJson);
    } catch (e) {
      return HttpResponse(
        statusCode: 0,
        headers: {},
        body: 'Error: $e',
        durationMs: 0,
      );
    }
  }

  static HttpResponse _parseResponse(String json) {
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final headers = <String, String>{};

      if (decoded['headers'] != null) {
        final headersList = decoded['headers'] as List;
        for (var header in headersList) {
          if (header is List && header.length == 2) {
            headers[header[0].toString()] = header[1].toString();
          }
        }
      }

      return HttpResponse(
        statusCode: decoded['status_code'] as int? ?? 0,
        headers: headers,
        body: decoded['body'] as String? ?? '',
        durationMs: decoded['duration_ms'] as int? ?? 0,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: 0,
        headers: {},
        body: 'Error parsing response: $e\nRaw response: $json',
        durationMs: 0,
      );
    }
  }
}

class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final int durationMs;

  HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.durationMs,
  });
}
