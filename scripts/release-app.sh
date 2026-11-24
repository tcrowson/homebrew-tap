#!/bin/bash
# Builds, signs (Developer ID), notarizes, staples and publishes one Mac app to this tap.
#
# Usage (from an app's Makefile):
#   release-app.sh --project Foo.xcodeproj --scheme Foo --app "Foo.app" --cask foo [--check]
#
# The built zip is attached to a GitHub release on the public tap repo (tag <cask>-<version>), so app
# repositories can stay private. Casks/<cask>.rb must already exist; its version and sha256 are rewritten.
# --check only verifies the prerequisites (certificate, notary profile, gh login, cask file) and exits.
#
# One-time setup: a "Developer ID Application" certificate in the login keychain, and
#   xcrun notarytool store-credentials notary --apple-id <apple id> --team-id <team id>
set -euo pipefail

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
NOTARY_PROFILE="${NOTARY_PROFILE:-notary}"
TAP_REPO="${TAP_REPO:-tcrowson/homebrew-tap}"
TAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PROJECT="" SCHEME="" APP="" CASK="" CHECK_ONLY=0
while [ $# -gt 0 ]; do
    case "$1" in
        --project) PROJECT="$2"; shift 2 ;;
        --scheme) SCHEME="$2"; shift 2 ;;
        --app) APP="$2"; shift 2 ;;
        --cask) CASK="$2"; shift 2 ;;
        --check) CHECK_ONLY=1; shift ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
[ -n "$PROJECT" ] && [ -n "$SCHEME" ] && [ -n "$APP" ] && [ -n "$CASK" ] || {
    echo "usage: release-app.sh --project P.xcodeproj --scheme S --app \"Name.app\" --cask token [--check]" >&2; exit 2; }

CASK_FILE="$TAP_DIR/Casks/$CASK.rb"
OUT="build/release"
step() { printf '\n==> %s\n' "$1"; }
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }

# --- Prerequisites ------------------------------------------------------------------------------
step "Checking prerequisites"
problems=0
IDENTITY="$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application: .*\)"/\1/p' | head -1)"
if [ -z "$IDENTITY" ]; then
    echo "  missing: Developer ID Application certificate (Xcode > Settings > Accounts > Manage Certificates > + )"
    problems=1
else
    TEAM_ID="$(printf '%s' "$IDENTITY" | sed -n 's/.*(\([A-Z0-9]*\))$/\1/p')"
    echo "  certificate: $IDENTITY"
fi
if xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    echo "  notary profile: $NOTARY_PROFILE"
else
    echo "  missing: notary profile '$NOTARY_PROFILE' (xcrun notarytool store-credentials $NOTARY_PROFILE --apple-id ... --team-id ...)"
    problems=1
fi
if gh auth status >/dev/null 2>&1; then echo "  gh: logged in"; else echo "  missing: gh login (gh auth login)"; problems=1; fi
if [ -f "$CASK_FILE" ]; then echo "  cask: $CASK_FILE"; else echo "  missing: $CASK_FILE"; problems=1; fi
[ "$problems" -eq 0 ] || fail "prerequisites missing (above)"
[ "$CHECK_ONLY" -eq 1 ] && { echo "All prerequisites present."; exit 0; }

# --- Build and export ---------------------------------------------------------------------------
step "Archiving $SCHEME (Release)"
rm -rf "$OUT" && mkdir -p "$OUT"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -archivePath "$OUT/$SCHEME.xcarchive" DEVELOPMENT_TEAM="$TEAM_ID" archive -quiet

step "Exporting with Developer ID"
cat > "$OUT/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>method</key><string>developer-id</string>
    <key>teamID</key><string>$TEAM_ID</string>
    <key>signingStyle</key><string>automatic</string>
</dict></plist>
EOF
xcodebuild -exportArchive -archivePath "$OUT/$SCHEME.xcarchive" -exportPath "$OUT/export" \
    -exportOptionsPlist "$OUT/ExportOptions.plist" -allowProvisioningUpdates -quiet
APP_PATH="$OUT/export/$APP"
[ -d "$APP_PATH" ] || fail "export did not produce $APP_PATH"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
TAG="$CASK-$VERSION"
ZIP="$OUT/$TAG.zip"
if gh release view "$TAG" --repo "$TAP_REPO" >/dev/null 2>&1; then
    fail "release $TAG already exists on $TAP_REPO: bump MARKETING_VERSION first"
fi
codesign --verify --deep --strict "$APP_PATH"
echo "  $APP $VERSION signed by: $(codesign -dvv "$APP_PATH" 2>&1 | sed -n 's/^Authority=//p' | head -1)"

# --- Notarize and staple ------------------------------------------------------------------------
step "Notarizing (usually a few minutes)"
ditto -c -k --keepParent "$APP_PATH" "$OUT/notarize.zip"
RESULT="$(xcrun notarytool submit "$OUT/notarize.zip" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json)"
STATUS="$(printf '%s' "$RESULT" | /usr/bin/plutil -extract status raw -o - - 2>/dev/null || true)"
if [ "$STATUS" != "Accepted" ]; then
    SUBMISSION="$(printf '%s' "$RESULT" | /usr/bin/plutil -extract id raw -o - - 2>/dev/null || true)"
    [ -n "$SUBMISSION" ] && xcrun notarytool log "$SUBMISSION" --keychain-profile "$NOTARY_PROFILE" || true
    fail "notarization status: ${STATUS:-unknown}"
fi
xcrun stapler staple "$APP_PATH"
spctl --assess --type execute -vv "$APP_PATH"

ditto -c -k --keepParent "$APP_PATH" "$ZIP"
SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
echo "  $ZIP  sha256 $SHA"

# --- Publish ------------------------------------------------------------------------------------
step "Publishing"
echo "  This creates release $TAG on $TAP_REPO, then commits and pushes Casks/$CASK.rb (version $VERSION)."
read -r -p "  Publish? [y/N] " answer
[ "$answer" = "y" ] || [ "$answer" = "Y" ] || { echo "Not published. The notarized zip is at $ZIP."; exit 0; }

sed -i '' -E "s/^  version \".*\"/  version \"$VERSION\"/; s/^  sha256 .*/  sha256 \"$SHA\"/" "$CASK_FILE"
gh release create "$TAG" "$ZIP" --repo "$TAP_REPO" --title "$APP $VERSION" --notes "$APP $VERSION, Developer ID signed and notarized."
git -C "$TAP_DIR" add "Casks/$CASK.rb"
git -C "$TAP_DIR" commit -m "$CASK $VERSION"
git -C "$TAP_DIR" push
echo "Released. Users: brew update && brew upgrade --cask $CASK"
