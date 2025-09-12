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

# Build in release mode
echo "Compiling with Swift Package Manager..."
swift build -c release

# Create release directory
mkdir -p "${RELEASE_DIR}"

# Copy the executable to release directory
cp "${BUILD_DIR}/release/ProgressIndicator" "${RELEASE_DIR}/"

# Make it executable
chmod +x "${RELEASE_DIR}/ProgressIndicator"

echo "✅ Build complete!"
echo "Executable location: ${RELEASE_DIR}/ProgressIndicator"
echo ""
echo "To install system-wide:"
echo "  sudo cp ${RELEASE_DIR}/ProgressIndicator /usr/local/bin/"
echo ""
echo "To test:"
echo "  echo 'Hello, World!' > /tmp/test.log"
echo "  ${RELEASE_DIR}/ProgressIndicator --watchfile=/tmp/test.log"
