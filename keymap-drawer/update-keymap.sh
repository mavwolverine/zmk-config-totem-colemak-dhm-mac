#!/bin/bash
# Script to regenerate keymap SVG from ZMK keymap file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Activate virtual environment
source "$SCRIPT_DIR/.venv/bin/activate"

# Parse ZMK keymap
echo "Parsing keymap..."
keymap parse -c 10 -z "$PROJECT_ROOT/config/totem.keymap" > "$SCRIPT_DIR/keymap-parsed.yaml"

# Add shifted key representations
sed -i '' \
  -e "s|- /|- {t: /, s: '?'}|g" \
  -e "s|- ','|- {t: ',', s: <}|g" \
  -e "s|- \\.|- {t: ., s: '>'}|g" \
  -e "s|, ;]|, {t: ;, s: ':'}]|g" \
  -e "s|- '-'|- {t: '-', s: _}|g" \
  "$SCRIPT_DIR/keymap-parsed.yaml"

# Generate SVG
echo "Generating SVG..."
keymap -c "$SCRIPT_DIR/config.yaml" draw "$SCRIPT_DIR/keymap-parsed.yaml" -o "$PROJECT_ROOT/keymap.svg"

echo "✓ Keymap SVG updated successfully!"
echo "  Output: $PROJECT_ROOT/keymap.svg"
