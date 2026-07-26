#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 1. 动态获取/解析目标 NuGet 版本号 (支持命令行传参: ./build_native.sh 3.6.0)
TARGET_VER="$1"
if [ -z "$TARGET_VER" ]; then
    echo "🔍 未在命令行指定版本，正在查询 NuGet 官方 API 获取 DocumentFormat.OpenXml 最新稳定版..."
    TARGET_VER=$(curl -s https://api.nuget.org/v3-flatcontainer/documentformat.openxml/index.json | jq -r '.versions[-1]' 2>/dev/null || echo "3.5.1")
fi

echo "========================================================="
echo "🚀 开始本地 Native AOT 矩阵构建"
echo "📦 目标 OpenXML SDK 版本: [ $TARGET_VER ]"
echo "========================================================="

HOST_OS="$(uname -s)"

if [ "$HOST_OS" = "Darwin" ]; then
    TARGET_RIDS=("osx-x64" "osx-arm64" "ios-arm64" "iossimulator-arm64")
    echo "🍎 宿主环境: macOS"
elif [[ "$HOST_OS" == *"MINGW"* ]] || [[ "$HOST_OS" == *"CYGWIN"* ]] || [[ "$HOST_OS" == *"MSYS"* ]]; then
    TARGET_RIDS=("win-x64" "win-arm64")
    echo "🪟 宿主环境: Windows"
else
    TARGET_RIDS=("linux-x64" "linux-arm64")
    echo "🐧 宿主环境: Linux"
fi

for RID in "${TARGET_RIDS[@]}"; do
    echo ""
    echo "---------------------------------------------------------"
    echo "📦 正在构建 平台 Target: [ $RID ]"
    echo "---------------------------------------------------------"

    EXTRA_FLAGS=()
    if [ "$RID" = "linux-arm64" ]; then
        EXTRA_FLAGS+=("-p:ObjCopyName=aarch64-linux-gnu-objcopy")
    fi

    # 1. 编译共享动态库 (iOS/iOS模拟器仅支持静态库，自动跳过其动态库)
    if [[ "$RID" != ios* ]]; then
        OUT_SHARED="$SCRIPT_DIR/dist/$RID/shared"
        echo "  [1/2] 编译动态库 -> $OUT_SHARED"
        dotnet publish -c Release -r "$RID" -p:NativeLib=Shared -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_SHARED" --nologo
    fi

    # 2. 编译物理解态库 (.a / .lib)
    OUT_STATIC="$SCRIPT_DIR/dist/$RID/static"
    echo "  [2/2] 编译静态库 -> $OUT_STATIC"
    dotnet publish -c Release -r "$RID" -p:NativeLib=Static -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_STATIC" --nologo
done

echo ""
echo "========================================================="
echo "✅ 本地 Native AOT 矩阵编译完成！产物归档一览："
echo "========================================================="

for RID in "${TARGET_RIDS[@]}"; do
    echo "📁 [$RID] 动态库:"
    ls -lh "$SCRIPT_DIR/dist/$RID/shared/"*.{dylib,dll,so} 2>/dev/null || true
    echo "📁 [$RID] 静态库:"
    ls -lh "$SCRIPT_DIR/dist/$RID/static/"*.{a,lib} 2>/dev/null || true
    echo ""
done
