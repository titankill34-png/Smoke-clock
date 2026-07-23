#!/usr/bin/env bash
# Generates the Xcode project with XcodeGen and builds it unsigned.
# Used locally and by CI (peter/ci) so both paths stay identical.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: xcodegen not found. Install with 'brew install xcodegen'." >&2
  exit 1
fi

xcodegen generate

xcodebuild build \
  -project SmokeClock.xcodeproj \
  -scheme SmokeClock \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO
