#!/bin/bash
# =========================================
# GitHub Release 自动发布脚本
# =========================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================="
echo "🚀 GitHub iOS App v1.0.0 发布"
echo "===================================="
echo ""

# 检查 gh 命令
if ! command -v gh &> /dev/null; then
    echo "ℹ️  未安装 GitHub CLI，请手动在 GitHub 网页创建 Release"
    echo ""
    echo "下载地址: https://cli.github.com/"
    echo ""
else
    echo "✅ 检测到 GitHub CLI"
    echo ""
    echo "发布命令："
    echo "  cd $PROJECT_DIR"
    echo "  gh release create v1.0.0 \\"
    echo "    --title \"GitHub iOS App v1.0.0\" \\"
    echo "    --notes-file RELEASE_NOTES.md \\"
    echo "    build/*.ipa"
    echo ""
fi

echo "===================================="
echo "📦 发布内容清单："
echo ""
echo "✅ 完整Xcode项目（可直接编译运行）"
echo "✅ Clean Architecture 分层架构"
echo "✅ 网络层 + 数据层 + UI层 + 安全层"
echo "✅ GitHub OAuth 2.0 认证"
echo "✅ Keychain Token 安全存储"
echo "✅ 仓库浏览 + Issue/PR + 个人主页"
echo "✅ 搜索模块 + 通知中心"
echo "✅ 117+ 单元测试用例"
echo "✅ GitHub 暗黑主题设计系统"
echo "✅ Fastlane 自动化构建"
echo "✅ 5种 IPA 分发方式"
echo ""
echo "===================================="
echo "📱 安装方式："
echo ""
echo "1️⃣  Sideloadly / AltStore 侧载（推荐）"
echo "   - 下载: https://sideloadly.io/"
echo "   - 拖放 IPA → 选择设备 → Start"
echo ""
echo "2️⃣  Xcode 直接安装"
echo "   - Window → Devices and Simulators"
echo "   - 选择设备 → 点击 + 选择 IPA"
echo ""
echo "3️⃣  TestFlight / App Store"
echo "   - 使用 Transporter App 上传"
echo ""
echo "===================================="
echo "📄 详细文档："
echo "   - README.md: 项目概述"
echo "   - INSTALLATION_GUIDE.md: 安装指南"
echo "   - SIDELOAD_GUIDE.md: 侧载详细教程"
echo "   - DELIVERABLES_SUMMARY.md: 交付清单"
echo "===================================="
echo ""
