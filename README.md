# RestEye · 眸息

RestEye（眸息）是一款跨平台的 20-20-20 护眼提醒工具，帮助用户形成规律的工作、休息节奏，并记录基础护眼数据。

项目使用 Flutter 构建，Android、Windows、macOS 共享 Material 3 界面、计时规则和本地数据模型；系统通知、亮屏状态等能力通过平台适配层接入。

## 功能

- 20-20-20 工作与休息提醒
- 首页正计时：已工作、已休息
- 工作、休息、等待休息和超时处理
- Android 锁屏暂停、通知动作和震动设置
- Windows 系统托盘和安装程序
- 工作时长、休息时长和完成次数统计
- 中文、英文、浅色、深色和跟随系统设置

用户数据默认只保存在本机 SQLite，不需要账号或云端同步。

## 平台

- Android（Android SDK 36）
- Windows
- macOS（Windows 开发主机暂缓构建）

## Android 使用注意事项

为确保应用在后台按时提醒，请在系统设置中完成以下配置（不同 Android 版本或手机厂商的菜单名称可能略有差异）：

1. 将 RestEye 的电池/省电策略设置为“无限制”或“不限制”。
2. 授予 RestEye 通知权限。
3. 在通知设置中开启“弹窗通知”“悬浮通知”或同名选项。

## 开发

在包含 `pubspec.yaml` 的目录执行：

```bash
flutter pub get
flutter analyze
flutter run -d windows
flutter build apk --debug
flutter build windows
```

本项目不编写单元测试、Widget 测试或集成测试，使用静态分析和平台构建验证代码；平台运行验收由用户执行。

## Android GitHub 发布

GitHub 直接下载默认只发布 Android `arm64-v8a` 包，适合绝大多数现代手机。确保本机已经配置 `android/key.properties` 和 release keystore，然后在项目根目录执行：

```powershell
.\tool\build_resteye_android.ps1
```

脚本会读取 `pubspec.yaml` 中的版本，构建正式签名 APK，并输出：

```text
artifacts/RestEye-<version>-android-arm64-v8a.apk
```

`android/key.properties`、`.jks` 私钥和 `PUB_CACHE` 不提交到 Git；`PUB_CACHE` 应放在与项目相同的磁盘。其他 Android 架构或通用包只有在明确需要时才构建。

本地需要同时安装 Debug 和 Release 时，Debug 使用独立包名 `dev.resteye.app.debug`，不会覆盖 Release。执行：

```powershell
.\tool\build_resteye_android_debug.ps1
```

Debug 输出文件名以 `-debug.apk` 结尾，仅用于本地开发和验收。

## Windows 安装版发布

Windows GitHub 发布使用 Inno Setup 生成安装程序。确保已安装 Inno Setup，然后在项目根目录执行：

```powershell
.\tool\build_resteye_windows.ps1
```

输出文件为：

```text
artifacts/RestEye-<version>-windows-x64-setup.exe
```

安装程序包含完整的 Windows Release 文件，不要只上传 `rest_eye.exe`。安装默认写入当前用户目录，不需要管理员权限，也不会删除 RestEye 用户数据。

## 文档

- [产品需求文档](docs/requirements.md)
- [系统架构设计](docs/architecture.md)
- [贡献与仓库规范](AGENTS.md)

## 许可证

RestEye 采用 [MIT License](LICENSE) 开源。
