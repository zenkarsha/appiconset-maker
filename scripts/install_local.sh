#!/bin/zsh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/Appiconset Maker/Appiconset Maker.xcodeproj"
SCHEME="Appiconset Maker"
APP_NAME="Appiconset Maker.app"
PROCESS_NAME="Appiconset Maker"
INSTALL_PATH="/Applications/$APP_NAME"
DERIVED_DATA_PATH="$(mktemp -d "${TMPDIR:-/tmp}/appiconset-maker-build.XXXXXX")"
BUILD_APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release/$APP_NAME"

cleanup() {
  rm -rf "$DERIVED_DATA_PATH"
}

trap cleanup EXIT

echo "Using derived data at:"
echo "  $DERIVED_DATA_PATH"

echo "Building $SCHEME (Release)..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [[ ! -d "$BUILD_APP_PATH" ]]; then
  echo "Build succeeded but app was not found at:"
  echo "  $BUILD_APP_PATH"
  exit 1
fi

echo "Stopping running app if needed..."
pkill -x "$PROCESS_NAME" || true

echo "Installing to /Applications..."
ditto "$BUILD_APP_PATH" "$INSTALL_PATH"

echo "Installed:"
echo "  $INSTALL_PATH"
