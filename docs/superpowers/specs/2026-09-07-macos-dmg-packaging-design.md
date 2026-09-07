# RestEye macOS DMG 打包设计

## 背景

RestEye 当前可以通过 `flutter build macos --release` 生成 `rest_eye.app`，但没有面向用户分发的 macOS 安装包入口。直接下载场景需要一个符合 macOS 使用习惯的 DMG，并在具备 Apple Developer 凭据时完成 Developer ID 签名和 Apple 公证。

## 目标

- 从 `pubspec.yaml` 自动读取版本，并生成 `artifacts/RestEye-<version>-macos.dmg`。
- DMG 内包含可拖入“应用程序”的 `RestEye.app` 和 `/Applications` 快捷方式。
- 使用仓库内的 shell 脚本完成构建、暂存、DMG 创建和 SHA-256 输出。
- 有 Developer ID 签名身份时支持 hardened runtime 签名；有公证 profile 时支持 notarytool 提交、等待和 stapling。
- 没有签名凭据时仍能生成本地验收用 DMG，但脚本必须明确提示该产物未完成正式签名/公证。

## 非目标

- 不创建 `.pkg` 安装器，不接入 Mac App Store，也不引入第三方 DMG 制作依赖。
- 不把 Apple 私钥、App Store Connect 密码或公证凭据写入仓库。
- 不改变 macOS 应用业务代码、Bundle Identifier 或现有 Flutter 构建配置。

## 方案

新增 `tool/build_resteye_macos.sh`，流程固定为：

1. 从 `pubspec.yaml` 读取 `1.2.0+4` 中的发布版本 `1.2.0`。
2. 执行 `flutter pub get` 和 `flutter build macos --release`。
3. 将 `build/macos/Build/Products/Release/rest_eye.app` 复制到临时目录并命名为 `RestEye.app`，同时创建指向 `/Applications` 的 Finder 快捷方式。
4. 如果 `MACOS_SIGNING_IDENTITY` 已设置，对暂存的 `RestEye.app` 使用 `codesign --deep --options runtime --timestamp` 签名并验证。
5. 使用系统 `hdiutil create -format UDZO` 生成 DMG。
6. 如果 `MACOS_NOTARY_PROFILE` 已设置，使用 `xcrun notarytool submit --keychain-profile ... --wait` 公证 DMG，随后 stapling 并验证。
7. 输出 DMG 路径和 SHA-256。

签名和公证采用环境变量而不是命令行密码参数：

- `MACOS_SIGNING_IDENTITY`：完整的 Developer ID Application 身份名称；为空时跳过正式签名。
- `MACOS_NOTARY_PROFILE`：`xcrun notarytool store-credentials` 保存的 Keychain profile；为空时跳过公证。

设置公证 profile 但未设置签名身份属于配置错误，脚本直接失败；没有任何凭据则只生成本地验收 DMG。脚本不启动 RestEye，也不删除项目目录外的用户数据，只清理自身创建的临时目录并覆盖同名 artifact。

## 文档与验证

在 `docs/development.md` 和 `docs/architecture.md` 增加 macOS 正式发布命令、签名/公证环境变量、产物命名和本地未签名限制。验证包括 shell 语法检查、版本解析、`flutter analyze`、`flutter build macos --release`、DMG 挂载内容检查、签名验证（有身份时）和 `git diff --check`。
