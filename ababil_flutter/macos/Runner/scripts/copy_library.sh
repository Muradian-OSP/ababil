#!/bin/bash

# Script to copy the Rust library to the app bundle Frameworks directory
# This should be run after building the Rust core

RUST_LIB="../../../../ababil_core/target/release/libababil_core.dylib"
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ -f "$RUST_LIB" ]; then
    mkdir -p "$FRAMEWORKS_DIR"
    cp "$RUST_LIB" "$FRAMEWORKS_DIR/"
    echo "Copied libababil_core.dylib to $FRAMEWORKS_DIR"
else
    echo "Warning: $RUST_LIB not found. Make sure to build the Rust core first."
fi

