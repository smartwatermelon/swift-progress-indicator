#!/bin/bash
#
# build.sh - Build ProgressIndicator for macOS
#
# This script builds the ProgressIndicator executable for distribution
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/.build"
RELEASE_DIR="${SCRIPT_DIR}/release"

echo "Building ProgressIndicator..."

# Clean previous builds
if [[ -d "${BUILD_DIR}" ]]; then
  echo "Cleaning previous build..."
  rm -rf "${BUILD_DIR}"
fi

# Build universal binary for both Intel and Apple Silicon
echo "Building universal binary for x86_64 and arm64..."

# Build for Intel (x86_64)
echo "Building for x86_64..."
swift build -c release --arch x86_64

# Build for Apple Silicon (arm64)
echo "Building for arm64..."
swift build -c release --arch arm64

# Create release directory
mkdir -p "${RELEASE_DIR}"

# Create universal binary using lipo
echo "Creating universal binary..."
lipo -create \
  "${BUILD_DIR}/x86_64-apple-macosx/release/ProgressIndicator" \
  "${BUILD_DIR}/arm64-apple-macosx/release/ProgressIndicator" \
  -output "${RELEASE_DIR}/ProgressIndicator"

# Make it executable
chmod +x "${RELEASE_DIR}/ProgressIndicator"

# Verify universal binary was created correctly
echo "Verifying universal binary..."
if command -v lipo >/dev/null; then
  lipo -info "${RELEASE_DIR}/ProgressIndicator"
else
  echo "lipo command not available - unable to verify architectures"
fi

echo "✅ Build complete!"
echo "Executable location: ${RELEASE_DIR}/ProgressIndicator"
echo ""
echo "To install system-wide:"
echo "  sudo cp ${RELEASE_DIR}/ProgressIndicator /usr/local/bin/"
echo ""
echo "To test:"
echo "  echo 'Hello, World!' > /tmp/test.log"
echo "  ${RELEASE_DIR}/ProgressIndicator --watchfile=/tmp/test.log"
