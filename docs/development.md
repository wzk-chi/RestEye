# RestEye 开发指南

本文档面向 RestEye 的开发、验证与发布维护。产品行为以[产品需求](requirements.md)为准，分层、状态机和平台边界以[架构设计](architecture.md)为准，仓库协作约束见 [`AGENTS.md`](../AGENTS.md)。

## 开发环境

RestEye 是 Flutter 项目，支持 Android、Windows 和 macOS。所有 Flutter 命令都应在包含 `pubspec.yaml` 的 `rest_eye/` 目录执行。

- Android 构建需要可用的 Android SDK。
- Windows 构建需要 Visual Studio 的桌面 C++ 工具链。
- macOS 构建必须在 macOS 主机上执行。
- Windows 安装包还需要 Inno Setup。

## 常用命令

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter build apk --debug
flutter build windows --release
# macOS 主机：flutter build macos
```

只有修改 Drift schema 或相关映射时才需要重新运行 `build_runner`；只有修改 ARB 本地化资源时才需要重新运行 `flutter gen-l10n`。不要手动编辑生成的 Drift 或本地化文件。

项目不编写或运行单元测试、Widget 测试和集成测试。代码验证使用格式检查、静态分析和目标平台构建；运行时冒烟与界面验收在对应平台手动完成。

## Debug 快速计时

Debug 构建使用独立的 `rest_eye_debug` 本地数据库，并将首次运行的工作时长和休息时长默认设为 5 秒；Release 构建继续使用 `rest_eye` 数据库和 20 分钟/20 秒的正式默认值。两种构建不会共享设置数据，因此 Debug 的测试设置不会修改 Release。

Debug 设置页和首页快捷时长编辑支持秒级调整，Release 的正式时长范围和步进保持不变。

## Android 本地 Debug 构建

本地安装使用标准脚本：

```powershell
.\tool\build_resteye_android_debug.ps1
```

脚本只构建 `arm64-v8a`，并将 APK 输出为：

```text
artifacts/RestEye-<version>-android-arm64-v8a-debug.apk
```

Debug 使用独立包名 `dev.resteye.app.debug` 和 `-debug` 版本后缀，可以与正式版同时安装。Debug 包仅用于本地开发和验收，不得作为 GitHub 正式发布包。

## Android 正式发布

GitHub 直接下载默认只发布 `arm64-v8a` APK。发布前需要在本机配置被 Git 忽略的 `android/key.properties` 和 release keystore，然后执行：

```powershell
.\tool\build_resteye_android.ps1
```

正式产物为：

```text
artifacts/RestEye-<version>-android-arm64-v8a.apk
```

`android/key.properties`、`.jks` 私钥和其他签名材料不得提交到仓库。`PUB_CACHE` 建议放在与项目相同的磁盘，避免 Windows 上 Kotlin 增量编译器的跨盘缓存路径问题。除非发布需求明确变更，不构建通用 APK、`armeabi-v7a` 或 `x86_64` 包。

发布前应记录 APK 的 SHA-256，并确认 Release 签名证书没有变化。

## Windows 正式发布

Windows 发布使用 Inno Setup 将完整 Release 目录打包为安装程序：

```powershell
.\tool\build_resteye_windows.ps1
```

输出文件为：

```text
artifacts/RestEye-<version>-windows-x64-setup.exe
```

安装程序必须包含 `build/windows/x64/runner/Release/` 下的可执行文件、DLL 和 `data/` 目录，不得只分发 `rest_eye.exe`。安装默认面向当前用户，不要求管理员权限；卸载不会删除 RestEye 的用户数据。

发布前应记录安装程序的 SHA-256。构建或打包过程不得自动启动 RestEye，Windows 运行验收由维护者单独执行。

## macOS 验证

在 macOS 主机执行：

```bash
flutter build macos
```

通知、通知操作、菜单栏驻留、窗口关闭行为、锁屏暂停与真正退出清理都需要在 macOS 上进行运行验收。其他操作系统只能进行 Dart 层和 Swift 源码的静态复核，不能代替 macOS 构建结果。

## 发布检查

发布前至少确认：

- 格式检查和 `flutter analyze` 通过。
- 对应目标平台构建成功。
- 版本号和产物文件名一致。
- Android APK 或 Windows 安装程序的 SHA-256 已记录。
- 签名密钥、`key.properties` 和本机路径没有进入版本控制。
- 通知、计时、退出、托盘或菜单栏等受影响功能已在目标平台完成手动验收。
