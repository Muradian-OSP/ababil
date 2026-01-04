# Ababil

A Postman alternative built with Rust core and Flutter UI, using FFI for communication between the two.

## Project Structure

- `ababil_core/` - Rust core library providing HTTP client functionality via FFI
- `ababil_flutter/` - Flutter UI application

## Prerequisites

- Rust (latest stable version)
- Flutter SDK (3.0.0 or higher)
- Cargo (comes with Rust)

## Building the Project

### 1. Build the Rust Core

```bash
cd ababil_core
cargo build --release
```

This will generate the native library:
- **macOS**: `target/release/libababil_core.dylib`
- **Linux**: `target/release/libababil_core.so`
- **Windows**: `target/release/ababil_core.dll`

### 2. Copy the Native Library to Flutter

For macOS development, copy the dylib to a location where Flutter can find it:

```bash
# From the project root
cp ababil_core/target/release/libababil_core.dylib ababil_flutter/macos/Runner/Frameworks/
```

Or for easier development, you can create a symlink or modify the library path in `http_client.dart`.

### 3. Build and Run Flutter App

```bash
cd ababil_flutter
flutter pub get
flutter run
```

## Features

- ✅ HTTP methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- ✅ Custom headers support
- ✅ Request body support
- ✅ Response display with status code, headers, and body
- ✅ Request duration tracking
- ✅ Clean, Postman-like UI

## Future Plans

- Electron UI implementation
- Request history
- Collections and environments
- Authentication support
- GraphQL support
- WebSocket support

## Development

### Rust Core

The Rust core uses:
- `reqwest` for HTTP requests
- `tokio` for async runtime
- `serde` for JSON serialization
- FFI bindings for C interop

### Flutter UI

The Flutter UI uses:
- `ffi` package for FFI bindings
- Material Design 3
- Split-pane layout (request/response)

## License

[Add your license here]

