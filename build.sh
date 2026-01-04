#!/bin/bash

# Build script for Ababil
# This script builds the Rust core and prepares it for Flutter

set -e

echo "Building Ababil Core (Rust)..."
cd ababil_core
cargo build --release
cd ..

echo ""
echo "Build complete!"
echo ""
echo "Native library location:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  macOS: ababil_core/target/release/libababil_core.dylib"
    echo ""
    echo "Copying library to Flutter locations..."
    
    # Copy to source Frameworks directory
    mkdir -p ababil_flutter/macos/Runner/Frameworks
    cp ababil_core/target/release/libababil_core.dylib ababil_flutter/macos/Runner/Frameworks/
    echo "  ✓ Library copied to ababil_flutter/macos/Runner/Frameworks/"
    
    # Copy to app bundle if it exists
    if [ -d "ababil_flutter/build/macos/Build/Products/Debug/ababil_flutter.app" ]; then
        mkdir -p ababil_flutter/build/macos/Build/Products/Debug/ababil_flutter.app/Contents/Frameworks
        cp ababil_core/target/release/libababil_core.dylib ababil_flutter/build/macos/Build/Products/Debug/ababil_flutter.app/Contents/Frameworks/
        echo "  ✓ Library copied to app bundle Frameworks"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  Linux: ababil_core/target/release/libababil_core.so"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "  Windows: ababil_core/target/release/ababil_core.dll"
fi

