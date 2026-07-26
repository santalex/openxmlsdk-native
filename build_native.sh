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
echo "开始本地 Native AOT 构建"
echo "Target Package: DocumentFormat.OpenXml [ $TARGET_VER ]"
echo "========================================================="

# 2. 自动检测系统当前已安装的 .NET Workload 扩展
INSTALLED_WORKLOADS=$(dotnet workload list 2>/dev/null || true)

HOST_OS="$(uname -s)"
TARGET_RIDS=()

if [ "$HOST_OS" = "Darwin" ]; then
    TARGET_RIDS+=("osx-x64" "osx-arm64")
    if echo "$INSTALLED_WORKLOADS" | grep -i "ios" >/dev/null 2>&1; then
        TARGET_RIDS+=("ios-arm64" "iossimulator-arm64")
        echo "Host OS: macOS | 已检测到 iOS Workload，启用 macOS + iOS 目标构建"
    else
        echo "Host OS: macOS | 未检测到 iOS Workload，自动跳过 iOS 目标构建 (可选安装: dotnet workload install ios)"
    fi
elif [[ "$HOST_OS" == *"MINGW"* ]] || [[ "$HOST_OS" == *"CYGWIN"* ]] || [[ "$HOST_OS" == *"MSYS"* ]]; then
    TARGET_RIDS+=("win-x64" "win-arm64")
    echo "Host OS: Windows | 启用 Windows 目标构建"
else
    TARGET_RIDS+=("linux-x64" "linux-arm64")
    if echo "$INSTALLED_WORKLOADS" | grep -i "android" >/dev/null 2>&1; then
        TARGET_RIDS+=("android-arm64")
        echo "Host OS: Linux | 已检测到 Android Workload，启用 Linux + Android 目标构建"
    else
        echo "Host OS: Linux | 未检测到 Android Workload，自动跳过 Android 目标构建 (可选安装: dotnet workload install android)"
    fi
fi

echo "Active Targets: ${TARGET_RIDS[*]}"

for RID in "${TARGET_RIDS[@]}"; do
    echo ""
    echo "---------------------------------------------------------"
    echo "Building Target: [ $RID ]"
    echo "---------------------------------------------------------"

    EXTRA_FLAGS=()
    if [ "$RID" = "linux-arm64" ]; then
        EXTRA_FLAGS+=("-p:ObjCopyName=aarch64-linux-gnu-objcopy")
    fi

    # 1. 编译动态库 (iOS Targets 仅输出静态库)
    if [[ "$RID" != ios* ]]; then
        OUT_SHARED="$SCRIPT_DIR/dist/$RID/shared"
        echo "  [1/2] Compiling shared library -> $OUT_SHARED"
        dotnet publish -c Release -r "$RID" -p:NativeLib=Shared -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_SHARED" --nologo
    fi

    # 2. 编译静态库 (.a / .lib)
    OUT_STATIC="$SCRIPT_DIR/dist/$RID/static"
    echo "  [2/2] Compiling static library -> $OUT_STATIC"
    dotnet publish -c Release -r "$RID" -p:NativeLib=Static -p:OpenXmlPackageVersion="$TARGET_VER" "${EXTRA_FLAGS[@]}" -o "$OUT_STATIC" --nologo
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
