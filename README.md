# openxmlsdk-native

`openxmlsdk-native` is an open-source C-ABI wrapper for Microsoft's `DocumentFormat.OpenXml` powered by **.NET 10 Native AOT**. It exports standalone native binaries (dynamic & static libraries) without requiring target machines to pre-install the .NET runtime, enabling seamless FFI interop for C/C++, Rust, Go, and Tauri apps.

---

## 🌟 Key Features

- **Official SDK Binding**: Built directly on top of Microsoft `DocumentFormat.OpenXml` (3.5.1+).
- **Zero Runtime Overhead**: Uses .NET Native AOT compilation to produce self-contained native binaries with zero external runtime dependencies.
- **Cross-Platform Architecture Support**:
  - **macOS**: `osx-x64` / `osx-arm64` (`.dylib` dynamic & `.a` static libraries)
  - **Windows**: `win-x64` / `win-arm64` (`.dll` dynamic & `.lib` static libraries)
  - **Linux**: `linux-x64` / `linux-arm64` (`.so` dynamic & `.a` static libraries)
- **Standard C Header**: Provides `include/OpenXmlSdkNative.h` for seamless C/C++/Rust integration.

---

## 🛠️ Requirements & Build Instructions

### Prerequisites
- **.NET 10 SDK**
- Platform C/C++ build tools:
  - **macOS**: Xcode Command Line Tools (`xcode-select --install`)
  - **Linux**: `clang` or `gcc`, `zlib1g-dev` (ARM64 requires `gcc-aarch64-linux-gnu`)
  - **Windows**: Visual Studio 2022 / Build Tools with C++ workload

### Local Build

```bash
chmod +x build_native.sh

# Default build (fetches latest stable OpenXml package)
./build_native.sh

# Build targeting a specific DocumentFormat.OpenXml package version
./build_native.sh 3.6.0
```

---

## 📁 Repository Layout

```text
openxmlsdk-native/
├── include/
│   └── OpenXmlSdkNative.h        # C-ABI header definitions
├── openxmlsdk-native.csproj       # .NET project configuration
├── NativeExports.cs               # C-ABI export implementations
├── build_native.sh                # Local build script
└── .github/
    └── workflows/
        └── build.yml              # CI/CD automated build workflow
```

---

## 📄 License

Distributed under the **MIT License**.
