#!/bin/bash
# IconFade 一键编译脚本
# 用法: chmod +x build.sh && ./build.sh

set -e

echo "🚀 IconFade 编译脚本"
echo "===================="

# 检查 Theos
if [ -z "$THEOS" ]; then
    echo "❌ 错误: 未设置 THEOS 环境变量"
    echo "请先安装 Theos: https://theos.dev/docs/installation"
    exit 1
fi

echo "✅ Theos 路径: $THEOS"

# 清理旧构建
echo "🧹 清理旧构建..."
make clean 2>/dev/null || true
rm -rf .theos packages 2>/dev/null || true

# 编译
echo "🔨 开始编译..."
make

# 打包
echo "📦 打包 deb..."
make package

# 查找生成的 deb
DEB_FILE=$(find packages -name "*.deb" | head -n 1)

if [ -n "$DEB_FILE" ]; then
    echo ""
    echo "✅ 编译成功!"
    echo "📦 文件路径: $(pwd)/$DEB_FILE"
    echo ""
    echo "安装方式:"
    echo "  1. 通过 SSH 安装: make install THEOS_DEVICE_IP=你的设备IP"
    echo "  2. 手动安装: 用 Filza 等工具将 deb 安装到设备"
    echo ""
else
    echo "❌ 未找到生成的 deb 文件"
    exit 1
fi
