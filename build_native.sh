#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 1. 动态解析目标 DocumentFormat.OpenXml 版本号
TARGET_VER="$1"
if [ -z "$TARGET_VER" ]; then
    echo "未在参数中指定版本，正在从 NuGet API 查询 DocumentFormat.OpenXml 最新版本..."
    TARGET_VER=$(curl -s https://api.nuget.org/v3-flatcontainer/documentformat.openxml/index.json | jq -r '.versions[-1]' 2>/dev/null || echo "3.5.1")
fi

echo "========================================================="
echo "🚀 开始本地 Native AOT 构建"
echo "Target Package: DocumentFormat.OpenXml [ $TARGET_VER ]"
echo "（注: 本项目主要依赖 GitHub Actions 云端流水线构建，本地脚本仅供调试参考）"
echo "========================================================="

HOST_OS="$(uname -s)"

if [ "$HOST_OS" = "Darwin" ]; then
    TARGET_RIDS=("osx-x64" "osx-arm64")
    echo "Host OS: macOS | Active Targets: ${TARGET_RIDS[*]}"
elif [[ "$HOST_OS" == *"MINGW"* ]] || [[ "$HOST_OS" == *"CYGWIN"* ]] || [[ "$HOST_OS" == *"MSYS"* ]]; then
    TARGET_RIDS=("win-x64" "win-arm64")
    echo "Host OS: Windows | Active Targets: ${TARGET_RIDS[*]}"
else
    TARGET_RIDS=("linux-x64" "linux-arm64")
    echo "Host OS: Linux | Active Targets: ${TARGET_RIDS[*]}"
fi

for RID in "${TARGET_RIDS[@]}"; do
    echo ""
    echo "---------------------------------------------------------"
    echo "Building Target: [ $RID ]"
    echo "---------------------------------------------------------"

    EXTRA_FLAGS=()
    if [ "$RID" = "linux-arm64" ]; then
        EXTRA_FLAGS+=("-p:ObjCopyName=aarch64-linux-gnu-objcopy")
    fi

    # 1. 编译共享动态库 (.dylib / .dll / .so)
    OUT_SHARED="$SCRIPT_DIR/dist/$RID/shared"
    echo "  [1/2] Compiling shared library -> $OUT_SHARED"
    dotnet publish -c Release -r "$RID" --self-contained true -p:NativeLib=Shared -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_SHARED" --nologo

    # 2. 编译物理解态库 (.a / .lib)
    OUT_STATIC="$SCRIPT_DIR/dist/$RID/static"
    echo "  [2/2] Compiling static library -> $OUT_STATIC"
    dotnet publish -c Release -r "$RID" --self-contained true -p:NativeLib=Static -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_STATIC" --nologo
done

echo ""
echo "========================================================="
echo "构建完成。产物列表："
echo "========================================================="

for RID in "${TARGET_RIDS[@]}"; do
    echo "[$RID] Shared:"
    ls -lh "$SCRIPT_DIR/dist/$RID/shared/"*.{dylib,dll,so} 2>/dev/null || true
    echo "[$RID] Static:"
    ls -lh "$SCRIPT_DIR/dist/$RID/static/"*.{a,lib} 2>/dev/null || true
    echo ""
done
