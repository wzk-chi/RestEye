# Windows/macOS 窗口位置与大小持久化设计

## 背景

RestEye 当前在 Windows 和 macOS 使用固定的初始窗口位置与大小。用户退出后重新启动时，窗口没有恢复到上次使用的位置和大小。窗口几何属于桌面宿主的 UI 偏好，不属于计时、设置或统计业务数据。

## 目标

- Windows 和 macOS 在真正退出时保存最后一次正常窗口的位置与大小。
- 下次启动时，在窗口首次显示前恢复保存的几何信息。
- 隐藏到 Windows 系统托盘或 macOS 菜单栏不视为退出，不覆盖已保存的几何信息。
- 不恢复最大化或最小化状态，只保存和恢复普通窗口的正常位置与大小。

## 非目标

- 不把窗口几何加入 Drift、业务 domain、application port 或 Flutter 设置状态。
- 不改变托盘/菜单栏的关闭行为、退出握手或计时生命周期。
- 不新增跨平台共享的窗口配置文件格式。

## 方案

### Windows

Windows runner 使用当前用户注册表保存几何信息：

- 注册表路径：`HKCU\Software\RestEye`
- 值名：`WindowNormalRect`
- 类型：`REG_BINARY`
- 内容：Win32 `RECT`，表示窗口的正常屏幕坐标和大小

`FlutterWindow::OnCreate()` 在窗口创建完成后、Flutter 首帧显示前读取该值，并使用 `SetWindowPos` 恢复窗口。恢复值使用屏幕物理像素，不再经过初始 `Create()` 的 DPI 缩放。

真正关闭的 `WM_CLOSE` 路径在退出握手完成后保存 `GetWindowPlacement()` 返回的 `rcNormalPosition`。隐藏到托盘的 `WM_CLOSE` 分支在返回前不保存；从托盘退出最终进入同一真正关闭路径，因此会保存几何信息。

### macOS

macOS runner 使用 `UserDefaults.standard` 保存几何信息：

- 键名：`RestEye.windowFrame`
- 值：`NSStringFromRect` 序列化的 `NSRect`

`MainFlutterWindow.awakeFromNib()` 在首次显示前读取并恢复 frame。窗口 delegate 只在窗口处于普通状态时更新 `lastNormalFrame`，因此缩放到最大化或最小化时不会把临时状态写成新的普通窗口尺寸。`NSApplication.willTerminateNotification` 触发时保存最后的普通 frame；隐藏到菜单栏不会触发该通知，也不会保存。

### 数据流

```text
启动
  ├─ Windows: Create → 读取注册表 → SetWindowPos → 首帧显示
  └─ macOS: awakeFromNib → 读取 UserDefaults → setFrame → 首次显示

退出
  ├─ 托盘/菜单栏隐藏 → 保持已保存值不变
  └─ 真正退出 → 保存普通窗口 frame → 完成宿主退出
```

## 错误与默认行为

- 首次启动没有保存值时，继续使用现有默认窗口位置和大小。
- 保存值不存在或无法解析时，保留当前默认几何，不阻断 RestEye 启动或退出。
- 所有存储均使用用户级权限，不需要管理员权限，也不写入业务数据库。

## 文档与验证

同步更新 `docs/requirements.md` 和 `docs/architecture.md`，明确两端的保存时机、原生存储位置以及托盘隐藏不覆盖记录的规则。

验证使用项目既有流程：

- `dart format --output=none --set-exit-if-changed lib`
- `flutter analyze`
- `flutter build macos`
- `git diff --check`

当前 macOS 主机不执行 Windows 构建，也不启动 Windows UI；Windows 真机行为由用户按托盘和退出路径手动验证。
