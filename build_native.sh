#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

HOST_OS="$(uname -s)"

if [ "$HOST_OS" = "Darwin" ]; then
    TARGET_RIDS=("osx-x64" "osx-arm64")
    echo "========================================================="
    echo "🍎 宿主环境: macOS | 启动全量 macOS 架构 Native AOT 编译"
    echo "========================================================="
elif [[ "$HOST_OS" == *"MINGW"* ]] || [[ "$HOST_OS" == *"CYGWIN"* ]] || [[ "$HOST_OS" == *"MSYS"* ]]; then
    TARGET_RIDS=("win-x64" "win-arm64")
    echo "========================================================="
    echo "🪟 宿主环境: Windows | 启动全量 Windows 架构 Native AOT 编译"
    echo "========================================================="
else
    TARGET_RIDS=("linux-x64" "linux-arm64")
    echo "========================================================="
    echo "🐧 宿主环境: Linux | 启动全量 Linux 架构 Native AOT 编译"
    echo "========================================================="
fi

for RID in "${TARGET_RIDS[@]}"; do
    echo ""
    echo "---------------------------------------------------------"
    echo "📦 正在构建 平台 Target: [ $RID ]"
    echo "---------------------------------------------------------"

    # 1. 编译共享动态库 (.dylib / .dll / .so)
    OUT_SHARED="$SCRIPT_DIR/dist/$RID/shared"
    echo "  [1/2] 编译动态库 -> $OUT_SHARED"
    dotnet publish -c Release -r "$RID" -p:NativeLib=Shared -o "$OUT_SHARED" --nologo

    # 2. 编译物理解态库 (.a / .lib)
    OUT_STATIC="$SCRIPT_DIR/dist/$RID/static"
    echo "  [2/2] 编译静态库 -> $OUT_STATIC"
    dotnet publish -c Release -r "$RID" -p:NativeLib=Static -o "$OUT_STATIC" --nologo
done

echo ""
echo "========================================================="
echo "✅ 编译完成！本地产物一览："
echo "========================================================="

for RID in "${TARGET_RIDS[@]}"; do
    echo "📁 [$RID] 动态库:"
    ls -lh "$SCRIPT_DIR/dist/$RID/shared/"*.{dylib,dll,so} 2>/dev/null || true
    echo "📁 [$RID] 静态库:"
    ls -lh "$SCRIPT_DIR/dist/$RID/static/"*.{a,lib} 2>/dev/null || true
    echo ""
done
