#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd "$script_dir/.." && pwd -P)"
cd "$repo_root"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command was not found: $1" >&2
    exit 1
  fi
}

for command_name in flutter ditto hdiutil shasum; do
  require_command "$command_name"
done

version_line="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n 1)"
if [[ -z "$version_line" ]]; then
  echo "Could not read the version from pubspec.yaml." >&2
  exit 1
fi
version="${version_line%%+*}"
if [[ -z "$version" ]]; then
  echo "The pubspec version is empty." >&2
  exit 1
fi

if [[ -n "${MACOS_NOTARY_PROFILE:-}" &&
      -z "${MACOS_SIGNING_IDENTITY:-}" ]]; then
  echo "MACOS_NOTARY_PROFILE requires MACOS_SIGNING_IDENTITY." >&2
  exit 1
fi

if [[ -n "${MACOS_SIGNING_IDENTITY:-}" ]]; then
  require_command codesign
  require_command xcrun
fi

artifact_directory="$repo_root/artifacts"
release_app="$repo_root/build/macos/Build/Products/Release/rest_eye.app"
dmg_path="$artifact_directory/RestEye-${version}-macos.dmg"
staging_directory="$(mktemp -d "${TMPDIR:-/tmp}/resteye-macos-dmg.XXXXXX")"

cleanup() {
  rm -rf "$staging_directory"
}
trap cleanup EXIT

echo "Building RestEye macOS release $version..."
flutter pub get
flutter build macos --release

if [[ ! -d "$release_app" ]]; then
  echo "Flutter completed without producing the macOS app: $release_app" >&2
  exit 1
fi

mkdir -p "$artifact_directory"
staged_app="$staging_directory/RestEye.app"
ditto "$release_app" "$staged_app"
ln -s /Applications "$staging_directory/Applications"

if [[ -n "${MACOS_SIGNING_IDENTITY:-}" ]]; then
  echo "Signing RestEye.app with Developer ID..."
  codesign --deep --force --verbose --options runtime --timestamp \
    --preserve-metadata=entitlements \
    --sign "$MACOS_SIGNING_IDENTITY" "$staged_app"
  codesign --verify --deep --strict --verbose=2 "$staged_app"
else
  echo "Warning: creating a local DMG without Developer ID signing; set MACOS_SIGNING_IDENTITY for release signing." >&2
fi

echo "Creating $dmg_path..."
hdiutil create \
  -volname "RestEye $version" \
  -srcfolder "$staging_directory" \
  -ov \
  -format UDZO \
  "$dmg_path"

if [[ -n "${MACOS_NOTARY_PROFILE:-}" ]]; then
  echo "Submitting the DMG for Apple notarization..."
  xcrun notarytool submit "$dmg_path" \
    --keychain-profile "$MACOS_NOTARY_PROFILE" \
    --wait
  xcrun stapler staple "$dmg_path"
  xcrun stapler validate "$dmg_path"
else
  echo "Notice: DMG was not notarized; set MACOS_NOTARY_PROFILE for release notarization."
fi

echo "Release DMG: $dmg_path"
shasum -a 256 "$dmg_path"
