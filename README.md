# 🚀 openxmlsdk-native

> **Standalone Native AOT C-ABI Packaging for Microsoft OpenXML SDK**  
> 跨平台 (macOS / Windows / Linux) 物理 Native AOT C-ABI 包装库，将微软官方 `DocumentFormat.OpenXml` 编译为无依赖的二进制动态库 (`.dylib` / `.dll` / `.so`) 与静态库 (`.a` / `.lib`)，供 Rust (Tauri)、C/C++、Go 及 Python 调用。

---

## 🌟 核心特性 (Features)

* 🛡️ **100% 微软官方工业级稳定**：底层基于 `DocumentFormat.OpenXml 3.5.1`；
* ⚡ **零 .NET 运行时依赖**：通过 .NET 10 Native AOT 编译为纯物理 C 机器码；
* 📦 **全平台支持矩阵 (6 大 Target 全覆盖)**：
  * **macOS**：`osx-x64` (Intel) / `osx-arm64` (Apple Silicon)
  * **Windows**：`win-x64` (x86_64) / `win-arm64` (Snapdragon / Surface)
  * **Linux**：`linux-x64` / `linux-arm64`
* 🔌 **静态库物理融合**：支持将 `.a` / `.lib` 直接静态链接打包入 Rust/Tauri 可执行程序，满足 App Store 合规沙盒与极致瘦身要求。

---

## 📁 目录结构 (Directory Layout)

```text
openxmlsdk-native/
├── README.md                      # 本说明文档
├── openxmlsdk-native.csproj       # .NET 10 Native AOT 项目配置
├── NativeExports.cs               # [UnmanagedCallersOnly] 导出的 C-ABI 函数
├── build_native.sh                # 本地一键构建脚本
└── .github/
    └── workflows/
        └── build.yml              # 三大系统 (macOS, Windows, Linux) 全矩阵 GitHub Actions CI/CD
```

---

## 🚀 快速本地构建 (Local Build)

```bash
chmod +x build_native.sh
./build_native.sh
```

编译产物会自动存放在 `dist/<RID>/shared` 和 `dist/<RID>/static` 目录中。
