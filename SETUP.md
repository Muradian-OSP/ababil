# Setup Guide

## Quick Start

### 1. Build the Rust Core

```bash
cd ababil_core
cargo build --release
```

This creates the native library:
- **macOS**: `target/release/libababil_core.dylib`
- **Linux**: `target/release/libababil_core.so`
- **Windows**: `target/release/ababil_core.dll`

### 2. Set Up Flutter Dependencies

```bash
cd ../ababil_flutter
flutter pub get
```

### 3. Copy Native Library (macOS)

For macOS development, you need to copy the library to where Flutter can find it:

```bash
# From project root
cp ababil_core/target/release/libababil_core.dylib ababil_flutter/macos/Runner/Frameworks/
```

Or use the build script:

```bash
./build.sh
```

### 4. Run Flutter App

```bash
cd ababil_flutter
flutter run -d macos  # or -d ios, -d android, etc.
```

## Development Workflow

1. Make changes to Rust code in `ababil_core/src/lib.rs`
2. Rebuild: `cd ababil_core && cargo build --release`
3. Copy the library again (if on macOS)
4. Hot reload in Flutter (or restart if needed)

## Troubleshooting

### Library Not Found Error

If you see "Native library not loaded" error:

1. Make sure you've built the Rust core: `cargo build --release`
2. For macOS, ensure the dylib is in `ababil_flutter/macos/Runner/Frameworks/`
3. For Linux, ensure `libababil_core.so` is in your library path
4. For Windows, ensure `ababil_core.dll` is accessible

### FFI Type Errors

If you modify the FFI interface in Rust, you'll need to:
1. Update the corresponding Dart types in `lib/core/http_client.dart`
2. Ensure function signatures match between Rust and Dart

## Testing

Test the HTTP client with a simple request:
1. Open the app
2. Enter a URL (e.g., `https://api.github.com`)
3. Select a method (GET, POST, etc.)
4. Click "Send"
5. View the response in the right panel

