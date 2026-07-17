#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="SwitchModDownloader"
BUILD_DIR="$PROJECT_DIR/.build"
DIST_DIR="$PROJECT_DIR/dist"
SRC_DIR="$PROJECT_DIR/$APP_NAME"

build_app() {
    local ARCH=$1
    local APP_BUNDLE="$DIST_DIR/${APP_NAME}-${ARCH}.app"
    local ZIP_PATH="$PROJECT_DIR/${APP_NAME}-${ARCH}.zip"
    
    echo "==> Building for $ARCH..."
    cd "$PROJECT_DIR"
    swift build -c release --arch $ARCH
    
    if [ "$ARCH" = "arm64" ]; then
        local BUILD_PATH="$BUILD_DIR/arm64-apple-macosx/release/$APP_NAME"
    else
        local BUILD_PATH="$BUILD_DIR/x86_64-apple-macosx/release/$APP_NAME"
    fi
    
    echo "==> Creating app bundle for $ARCH..."
    rm -rf "$APP_BUNDLE"
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    cp "$BUILD_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
    
    cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>SwitchModDownloader</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleIdentifier</key><string>com.switchmoddownloader.app</string>
    <key>CFBundleName</key><string>SwitchModDownloader</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSSupportsAutomaticTermination</key><true/>
    <key>NSSupportsSuddenTermination</key><true/>
</dict>
</plist>
PLIST
    
    cp -R "$SRC_DIR/Assets.xcassets" "$APP_BUNDLE/Contents/Resources/Assets.xcassets"
    
    # Copy localization files
    if [ -d "$SRC_DIR/Resources" ]; then
        for lproj in "$SRC_DIR/Resources"/*.lproj; do
            if [ -d "$lproj" ]; then
                lproj_name=$(basename "$lproj")
                mkdir -p "$APP_BUNDLE/Contents/Resources/$lproj_name"
                cp "$lproj"/* "$APP_BUNDLE/Contents/Resources/$lproj_name/"
            fi
        done
    fi
    
    echo "==> Generating icns for $ARCH..."
    ICON_SRC="$SRC_DIR/Assets.xcassets/AppIcon.appiconset/icon_512x512.png"
    sips -s format icns "$ICON_SRC" --out "$APP_BUNDLE/Contents/Resources/AppIcon.icns" >/dev/null 2>&1
    
    echo "==> Creating zip for $ARCH..."
    rm -f "$ZIP_PATH"
    cd "$DIST_DIR"
    zip -r "$ZIP_PATH" "${APP_NAME}-${ARCH}.app"
    
    local ZIP_SIZE=$(ls -lh "$ZIP_PATH" | awk '{print $5}')
    echo "==> Done! $ZIP_PATH ($ZIP_SIZE)"
}

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "════════════════════════════════════════"
echo "  Building for Apple Silicon (arm64)"
echo "════════════════════════════════════════"
build_app "arm64"

echo ""
echo "════════════════════════════════════════"
echo "  Building for Intel Mac (x86_64)"
echo "════════════════════════════════════════"
build_app "x86_64"

echo ""
echo "════════════════════════════════════════"
echo "  Build Complete!"
echo "════════════════════════════════════════"
echo "  - SwitchModDownloader-arm64.zip (Apple Silicon)"
echo "  - SwitchModDownloader-x86_64.zip (Intel Mac)"
echo "════════════════════════════════════════"
