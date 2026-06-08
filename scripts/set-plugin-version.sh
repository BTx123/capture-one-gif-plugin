#!/usr/bin/env bash
set -euo pipefail

VERSION_PLIST="${VERSION_PLIST:-COGifPlugin/Info.plist}"

if [[ "${GITHUB_REF:-}" == refs/tags/* ]]; then
  if [[ "${GITHUB_REF_NAME:-}" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    PLUGIN_VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  else
    echo "Release tags must match vX.Y.Z, got: ${GITHUB_REF_NAME:-<unset>}"
    exit 1
  fi
else
  PLUGIN_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$VERSION_PLIST")"
fi

PLUGIN_BUILD="${GITHUB_RUN_NUMBER:?GITHUB_RUN_NUMBER is required}"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $PLUGIN_VERSION" "$VERSION_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $PLUGIN_BUILD" "$VERSION_PLIST"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "PLUGIN_VERSION=$PLUGIN_VERSION"
    echo "PLUGIN_BUILD=$PLUGIN_BUILD"
  } >> "$GITHUB_ENV"
fi

/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$VERSION_PLIST"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$VERSION_PLIST"
