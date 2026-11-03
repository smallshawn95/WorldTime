#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Please run this script on a Mac with Xcode installed."
  exit 1
fi

echo "Testing time zones, daylight saving transitions, and favorites..."
swift test

echo "Building the SwiftUI app for iOS Simulator..."
xcodebuild -project WorldTime.xcodeproj -scheme WorldTime \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build

if [[ -n "${DESTINATION:-}" ]]; then
  echo "Running the Xcode test target on the selected simulator..."
  xcodebuild -project WorldTime.xcodeproj -scheme WorldTime \
    -configuration Debug -destination "$DESTINATION" \
    -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO test
else
  echo "Core tests and simulator build finished."
  echo "To run hosted tests too, set DESTINATION to an available simulator, or press Command-U in Xcode."
fi
