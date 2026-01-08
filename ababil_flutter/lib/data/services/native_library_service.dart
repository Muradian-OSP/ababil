import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';

typedef FreeStringNative = Void Function(Pointer<Utf8>);
typedef FreeStringDart = void Function(Pointer<Utf8>);

/// Base class for services that use the native ababil_core library
class NativeLibraryService {
  static DynamicLibrary? _dylib;
  static FreeStringDart? _freeString;
  static bool _initialized = false;

  /// Initialize the native library
  static Future<void> initialize() async {
    if (_dylib != null) return;

    try {
      if (Platform.isAndroid) {
        _dylib = DynamicLibrary.open('libababil_core.so');
      } else if (Platform.isIOS) {
        _dylib = DynamicLibrary.process();
      } else if (Platform.isMacOS) {
        _dylib = DynamicLibrary.open('libababil_core.dylib');
        // await _initializeMacOS();
      } else if (Platform.isLinux) {
        _dylib = DynamicLibrary.open('libababil_core.so');
      } else if (Platform.isWindows) {
        _dylib = DynamicLibrary.open('ababil_core.dll');
      }

      if (_dylib != null) {
        _freeString = _dylib!
            .lookup<NativeFunction<FreeStringNative>>('free_string')
            .asFunction();
        _initialized = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('NativeLibraryService: Error loading library: $e');
      }
      if (kDebugMode) {
        print(
          'Make sure to build the Rust library first: cd ababil_core && cargo build --release',
        );
      }
    }
  }

  // static Future<void> _initializeMacOS() async {
  //   // Get the executable path to find the app bundle
  //   final executablePath = Platform.resolvedExecutable;
  //   final executableDir = File(executablePath).parent.path;

  //   // List of paths to try
  //   final List<String> pathsToTry = [];

  //   // 1. Try app bundle Frameworks (Contents/Frameworks inside .app)
  //   pathsToTry.add('$executableDir/../Frameworks/libababil_core.dylib');

  //   // 2. Try app bundle Resources (alternative location)
  //   pathsToTry.add('$executableDir/../Resources/libababil_core.dylib');

  //   // 3. Try development path (when running with flutter run)
  //   final currentDir = Directory.current.path;
  //   pathsToTry.add('$currentDir/macos/Runner/Frameworks/libababil_core.dylib');
  //   pathsToTry.add(
  //     '$currentDir/ababil_flutter/macos/Runner/Frameworks/libababil_core.dylib',
  //   );

  //   // 4. Try Documents directory approach
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     pathsToTry.add('${directory.path}/../Frameworks/libababil_core.dylib');
  //   } catch (e) {
  //     // Ignore if we can't get documents directory
  //   }

  //   // 5. Try relative to executable
  //   pathsToTry.add('libababil_core.dylib');

  //   // 6. Try absolute path from project root
  //   final homeDir = Platform.environment['HOME'] ?? '';
  //   if (homeDir.isNotEmpty) {
  //     pathsToTry.add(
  //       '$homeDir/Projects/open-source/ababil/ababil_flutter/macos/Runner/Frameworks/libababil_core.dylib',
  //     );
  //     pathsToTry.add(
  //       '$homeDir/Projects/open-source/ababil/ababil_core/target/release/libababil_core.dylib',
  //     );
  //   }

  //   // 7. Try simple paths
  //   pathsToTry.add(
  //     '${Directory.current.path}/ababil_core/target/release/libababil_core.dylib',
  //   );
  //   pathsToTry.add(
  //     '${Directory.current.path}/target/release/libababil_core.dylib',
  //   );
  //   pathsToTry.add('/usr/local/lib/libababil_core.dylib');

  //   for (final path in pathsToTry) {
  //     try {
  //       _dylib = DynamicLibrary.open(path);
  //       if (kDebugMode) {
  //         print(
  //           'NativeLibraryService: Successfully loaded library from: $path',
  //         );
  //       }
  //       break;
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print('NativeLibraryService: Error loading library from: $path: $e');
  //       }
  //     }
  //   }

  //   if (_dylib == null) {
  //     if (kDebugMode) {
  //       print(
  //         'NativeLibraryService: Could not load libababil_core.dylib from any of these paths:',
  //       );
  //       print('Tried paths: $pathsToTry');
  //       print('\nTo fix this:');
  //       print(
  //         '1. Build the Rust core: cd ababil_core && cargo build --release',
  //       );
  //       print(
  //         '2. Copy the library: cp ababil_core/target/release/libababil_core.dylib ababil_flutter/macos/Runner/Frameworks/',
  //       );
  //       print('3. Or run: ./build.sh');
  //     }
  //   }
  // }

  /// Get the loaded dynamic library
  static DynamicLibrary? get library => _dylib;

  /// Check if the library is initialized
  static bool get isInitialized => _initialized && _dylib != null;

  /// Free a string pointer returned from native code
  static void freeString(Pointer<Utf8> ptr) {
    if (_freeString != null && ptr.address != 0) {
      _freeString!(ptr);
    }
  }
}
