# openxmlsdk-native

`openxmlsdk-native` 是一个基于 .NET 10 Native AOT 技术的开源 C-ABI 包装库。它将微软官方 `DocumentFormat.OpenXml` 封装并导出为无外部运行时依赖的原生物理二进制文件（动态库与静态库），方便 Rust、C/C++、Go、Swift (macOS/iOS) 及 Java/Kotlin (Android) 等语言进行跨平台 FFI 调用。

## 项目特性

- **官方 SDK 驱动**：底层绑定微软官方 `DocumentFormat.OpenXml` (默认 3.5.1 及以上)。
- **零 Runtime 依赖**：使用 .NET 10 Native AOT 物理编译，无需目标机器安装 .NET 运行时。
- **全平台多架构支持**：
  - **macOS**：`osx-x64` / `osx-arm64` (`.dylib` 动态库 & `.a` 静态库)
  - **iOS**：`ios-arm64` / `iossimulator-arm64` (`.a` 静态库)
  - **Windows**：`win-x64` / `win-arm64` (`.dll` 动态库 & `.lib` 静态库)
  - **Linux**：`linux-x64` / `linux-arm64` (`.so` 动态库 & `.a` 静态库)
  - **Android**：`android-arm64` (`.so` 动态库)
- **标准 C 头文件**：提供 `include/OpenXmlSdkNative.h` 供 C/C++/Swift 等项目直接引用。若在 C# 中扩展了新的导出函数，开发者可根据需要自行调整该头文件声明。

## 目录结构

```text
openxmlsdk-native/
├── include/
│   └── OpenXmlSdkNative.h        # C-ABI 头文件声明
├── openxmlsdk-native.csproj       # .NET 项目配置文件
├── NativeExports.cs               # C-ABI 导出逻辑
├── build_native.sh                # 本地构建脚本
└── .github/
    └── workflows/
        └── build.yml              # 全平台 CI/CD 自动化构建流
```

## 本地构建说明

运行 `./build_native.sh` 即可开始本地构建：

```bash
# 默认构建 (自动获取 NuGet 最新稳定版本)
./build_native.sh

# 指定版本构建 (例如 3.6.0)
./build_native.sh 3.6.0
```
