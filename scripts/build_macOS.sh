#!/bin/bash
# =========================================
# GitHub iOS App - macOS 一键构建脚本
# =========================================
# 使用方法：
#   1. 在 macOS 上运行此脚本
#   2. ./scripts/build_macOS.sh development  # 开发版（可侧载
#   3. ./scripts/build_macOS.sh release      # 发布版
#   4. ./scripts/build_macOS.sh enterprise   # 企业版
# =========================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
IPA_DIR="$PROJECT_DIR/IPA"

# 创建目录
mkdir -p "$BUILD_DIR"
mkdir -p "$IPA_DIR"

# 默认配置
CONFIGURATION="Release"
EXPORT_METHOD="development"
IPA_NAME="GitHubApp-v1.0.0.ipa"
SCHEME="GitHubApp"

# 解析参数
case "${1:-development}" in
    dev|development)
        EXPORT_METHOD="development"
        CONFIGURATION="Debug"
        IPA_NAME="GitHubApp-v1.0.0-Dev.ipa"
        ;;
    prod|production|release)
        EXPORT_METHOD="app-store"
        CONFIGURATION="Release"
        IPA_NAME="GitHubApp-v1.0.0-Release.ipa"
        ;;
    enterprise)
        EXPORT_METHOD="enterprise"
        CONFIGURATION="Release"
        IPA_NAME="GitHubApp-v1.0.0-Enterprise.ipa"
        ;;
    *)
        echo "使用方法: $0 [development|release|enterprise]"
        exit 1
        ;;
esac

echo "===================================="
echo "🚀 GitHub iOS App 构建脚本"
echo "📋 配置: $CONFIGURATION"
echo "📦 导出方式: $EXPORT_METHOD"
echo "📱 输出IPA: $IPA_NAME"
echo "===================================="

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 未找到 Xcode 命令行工具！"
    echo "请安装: xcode-select --install"
    exit 1
fi

echo ""
echo "ℹ️  Xcode 版本:"
xcodebuild -version
echo ""

# 清理构建目录
echo "🧹 清理构建目录..."
rm -rf "$BUILD_DIR"/*

cd "$PROJECT_DIR"

# 检查项目
if [ ! -d "GitHubApp.xcodeproj" ]; then
    echo "❌ 未找到 GitHubApp.xcodeproj！"
    exit 1
fi

# 检查 Build Settings
echo "🔍 验证项目..."
xcodebuild -list -project GitHubApp.xcodeproj

# 构建 Archive
echo ""
echo "📦 构建 Archive..."
xcodebuild archive \
    -project GitHubApp.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$BUILD_DIR/GitHubApp.xcarchive" \
    -destination "generic/platform=iOS" \
    -quiet || exit 1

echo "✅ Archive 构建成功！"

# 生成 ExportOptions.plist
echo ""
echo "📝 生成导出配置..."
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$EXPORT_METHOD</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

# 导出 IPA
echo "🚀 导出 IPA..."
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/GitHubApp.xcarchive" \
    -exportPath "$IPA_DIR" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
    -quiet || exit 1

# 查找输出的 IPA
GENERATED_IPA=$(find "$IPA_DIR" -name "*.ipa" -type f | head -1)
if [ -n "$GENERATED_IPA" ]; then
    mv "$GENERATED_IPA" "$IPA_DIR/$IPA_NAME"
    echo ""
    echo "🎉🎉 IPA 构建成功！"
    echo ""
    echo "📱 IPA 位置: $IPA_DIR/$IPA_NAME"
    echo "📦 文件大小: $(du -h "$IPA_DIR/$IPA_NAME" | cut -f1)"
    echo ""
    echo "===================================="
    echo "安装方式："
    echo ""
    echo "1️⃣  AltStore / Sideloadly 侧载（推荐）："
    echo "   打开 Sideloadly → 选择 IPA → 选择设备 → 点击 Start"
    echo ""
    echo "2️⃣  Xcode 直接安装："
    echo "   Window → Devices and Simulators → 选择设备 → 点击 + 添加 IPA"
    echo ""
    echo "3️⃣  TestFlight 发布："
    echo "   使用 Transporter App 上传到 App Store Connect"
    echo ""
    echo "===================================="
else
    echo "❌ IPA 导出失败！"
    exit 1
fi
