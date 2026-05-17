#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

CONFIGURATION="Release"
SCHEME="GitHubApp"
EXPORT_METHOD="app-store"
IPA_NAME="GitHubApp.ipa"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|development)
            EXPORT_METHOD="development"
            CONFIGURATION="Debug"
            IPA_NAME="GitHubApp-Dev.ipa"
            shift
            ;;
        prod|production|release)
            EXPORT_METHOD="app-store"
            CONFIGURATION="Release"
            IPA_NAME="GitHubApp-Release.ipa"
            shift
            ;;
        enterprise)
            EXPORT_METHOD="enterprise"
            CONFIGURATION="Release"
            IPA_NAME="GitHubApp-Enterprise.ipa"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "===================================="
echo "GitHubApp iOS Build Script"
echo "Configuration: $CONFIGURATION"
echo "Export Method: $EXPORT_METHOD"
echo "===================================="

# Create build directory
mkdir -p "$BUILD_DIR"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found!"
    echo "Please install: xcode-select --install"
    exit 1
fi

# Clean build
echo "🧹 Cleaning build folder..."
rm -rf "$BUILD_DIR"/*

cd "$PROJECT_DIR"

# Build archive
echo "📦 Building archive..."
xcodebuild archive \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$BUILD_DIR/GitHubApp.xcarchive" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    | xcbeautify || exit 1

# Generate export plist
echo "📝 Generating export options..."
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$EXPORT_METHOD</string>
    <key>teamID</key>
    <string>$DEVELOPMENT_TEAM</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

# Export IPA
echo "🚀 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/GitHubApp.xcarchive" \
    -exportPath "$BUILD_DIR" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
    -allowProvisioningUpdates \
    | xcbeautify || exit 1

# Rename IPA
mv "$BUILD_DIR/GitHubApp.ipa" "$BUILD_DIR/$IPA_NAME" 2>/dev/null || true

echo ""
echo "✅ Build complete!"
echo "📱 IPA: $BUILD_DIR/$IPA_NAME"
echo ""
echo "Installation Instructions:"
echo "  • Development: Use Xcode → Devices and Simulators"
echo "  • TestFlight: Upload to App Store Connect"
echo "  • Enterprise: Host on HTTPS server with manifest"
echo ""
