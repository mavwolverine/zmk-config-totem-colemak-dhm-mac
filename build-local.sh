#!/bin/bash
# Local build script for ZMK firmware

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building ZMK firmware locally..."

# Clean and create build directory
rm -rf "$SCRIPT_DIR/build"
mkdir -p "$SCRIPT_DIR/build"
mkdir -p "$SCRIPT_DIR/.workspace/modules"
mkdir -p "$SCRIPT_DIR/.workspace/tools"
mkdir -p "$SCRIPT_DIR/.workspace/zephyr"
mkdir -p "$SCRIPT_DIR/.workspace/bootloader"
mkdir -p "$SCRIPT_DIR/.workspace/zmk"

# Run the build using ZMK's official Docker image
docker run --rm \
  -v "$SCRIPT_DIR/config:/workspace/config:ro" \
  -v "$SCRIPT_DIR/build:/workspace/build" \
  -v "$SCRIPT_DIR/.workspace/modules:/workspace/modules" \
  -v "$SCRIPT_DIR/.workspace/tools:/workspace/tools" \
  -v "$SCRIPT_DIR/.workspace/zephyr:/workspace/zephyr" \
  -v "$SCRIPT_DIR/.workspace/bootloader:/workspace/bootloader" \
  -v "$SCRIPT_DIR/.workspace/zmk:/workspace/zmk" \
  zmkfirmware/zmk-build-arm:stable \
  /bin/bash -c "
    cd /workspace
    west init -l config
    west update
    west zephyr-export
    
    # Build left side
    west build -s zmk/app -b xiao_ble -d build/left -- -DSHIELD=totem_left -DZMK_CONFIG=/workspace/config
    cp build/left/zephyr/zmk.uf2 build/totem_left.uf2
    
    # Build right side
    west build -s zmk/app -b xiao_ble -d build/right -- -DSHIELD=totem_right -DZMK_CONFIG=/workspace/config
    cp build/right/zephyr/zmk.uf2 build/totem_right.uf2
  "

if [ -f "$SCRIPT_DIR/build/totem_left.uf2" ] && [ -f "$SCRIPT_DIR/build/totem_right.uf2" ]; then
  echo "✓ Build complete!"
  echo "  Left:  build/totem_left.uf2"
  echo "  Right: build/totem_right.uf2"
else
  echo "✗ Build failed - check output above for errors"
  exit 1
fi
