# macOS 与 Windows 业务逻辑一致性修订设计

## 背景

RestEye 的 Flutter 业务层已经通过统一的 `WindowBehaviorGateway`、`ScreenStateGateway`、通知网关和 `AppExitGateway` 连接 Windows 与 macOS 原生适配层。本次审计以 `docs/requirements.md` 和 `docs/architecture.md` 为判定基准，检查窗口菜单、退出清理、屏幕锁定和通知动作是否保持相同业务语义。

## 审计结论

- Windows 与 macOS 使用相同的窗口行为通道、事件通道、菜单 action id 和 Flutter 业务分发入口。
- Windows 通过 `dev.resteye/app_exit` 在 `WM_CLOSE` 时显式请求 Dart 清理；macOS 通过 `FlutterAppDelegate` 的可等待退出协议触发同一个 `AppRuntime.dispose()`。这是平台实现差异，不是业务语义差异。
- Windows 使用 WTS 会话锁定事件和输入桌面轮询，macOS 使用 `DistributedNotificationCenter` 锁屏事件及 `CGSessionCopyCurrentDictionary`。两端均把锁屏映射为 `off`，解锁映射为 `on`，不会把显示器单独熄灭当作锁屏。
- 通知动作、幂等处理、过期判断和计时状态转换均在共享 Dart 代码中完成；Windows 的 Toast/XML 和 macOS 的 Darwin 通知类别只是原生展示差异。
- macOS 菜单栏的“打开”动作调用 `makeKeyAndOrderFront`，但没有像 Windows 的 `SW_RESTORE` 一样显式恢复最小化窗口。因此从菜单栏打开处于最小化状态的 RestEye 可能不能稳定恢复窗口，和产品要求的“打开恢复窗口”不完全一致。

## 方案选择

### 方案 A：在 macOS 打开动作中显式取消最小化（采用）

在 `MainFlutterWindow.showFromTray` 中检查 `isMiniaturized`，为真时调用 `deminiaturize(nil)`，随后保留现有的 `makeKeyAndOrderFront(nil)` 和 `NSApp.activate(ignoringOtherApps: true)`。

优点是修改范围最小，直接补齐与 Windows `SW_RESTORE` 对应的业务行为，不改变现有退出协议、通道契约或 Flutter 业务逻辑。

### 方案 B：让 macOS 复刻 Windows 的 `dev.resteye/app_exit` 握手

新增 macOS 原生退出 MethodChannel，在窗口关闭和菜单栏退出时主动调用 Dart 清理。

该方案会重复 Flutter macOS 已提供的 `FlutterAppDelegate` 可等待退出协议，与当前架构文档的约定冲突，增加无必要的退出竞态，因此不采用。

### 方案 C：把窗口恢复状态提升到共享 Dart 层

新增跨平台窗口恢复抽象，由 Dart 分发“打开”请求，再由各平台实现恢复窗口。

当前问题只涉及 macOS 原生窗口状态，提升到共享业务层会扩大端口和实现范围，不符合本次最小修订目标，因此不采用。

## 详细设计

修改 `macos/Runner/MainFlutterWindow.swift` 的 `showFromTray`：

```swift
@objc private func showFromTray(_ sender: Any?) {
  if isMiniaturized {
    deminiaturize(nil)
  }
  makeKeyAndOrderFront(nil)
  NSApp.activate(ignoringOtherApps: true)
}
```

隐藏到菜单栏的窗口仍由 `makeKeyAndOrderFront` 恢复；最小化到 Dock 的窗口先由 `deminiaturize` 恢复。动态计时菜单、退出清理、锁屏状态桥接和通知代码不变。

## 验证

按照仓库约束，不新增单元测试、Widget 测试或集成测试。实施后执行：

```bash
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter build macos
```

macOS 运行时由用户手动确认：窗口关闭保留到菜单栏、菜单栏“打开”可恢复隐藏/最小化窗口、动态计时 action 正确回到 Flutter 业务入口，以及退出时活动计时完成清理。
