import Cocoa
import FlutterMacOS

final class MainFlutterWindow: NSWindow, NSWindowDelegate, FlutterStreamHandler {
  private static let windowFrameDefaultsKey = "RestEye.windowFrame"
  private static let windowBehaviorChannelName = "dev.resteye/window_behavior"
  private static let windowBehaviorEventsChannelName =
    "dev.resteye/window_behavior/events"

  private struct TrayMenuItem {
    let actionID: String
    let title: String
  }

  private var screenStateBridge: ScreenStateBridge?
  private var windowBehaviorMethodChannel: FlutterMethodChannel?
  private var windowBehaviorEventChannel: FlutterEventChannel?
  private var trayEventSink: FlutterEventSink?
  private var trayStatusItem: NSStatusItem?
  private var trayMenuItems: [TrayMenuItem] = []
  private var trayAppTitle = ""
  private var trayOpenApp = ""
  private var trayExitApp = ""
  private var trayLabelsReady = false
  private var minimizeToTrayOnClose = true
  private var closeRequested = false
  private var terminationObserver: NSObjectProtocol?
  private var lastNormalFrame: NSRect?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = Self.restoredWindowFrame ?? self.frame
    lastNormalFrame = windowFrame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
    delegate = self
    terminationObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.willTerminateNotification,
      object: NSApp,
      queue: .main
    ) { [weak self] _ in
      self?.saveNormalWindowFrame()
    }

    screenStateBridge = ScreenStateBridge(
      messenger: flutterViewController.engine.binaryMessenger
    )
    configureWindowBehavior(
      messenger: flutterViewController.engine.binaryMessenger
    )
  }

  private static var restoredWindowFrame: NSRect? {
    guard
      let value = UserDefaults.standard.string(forKey: windowFrameDefaultsKey)
    else {
      return nil
    }
    let frame = NSRectFromString(value)
    guard frame.width > 0, frame.height > 0 else { return nil }
    return frame
  }

  private func updateLastNormalFrame() {
    guard !isZoomed && !isMiniaturized else { return }
    lastNormalFrame = frame
  }

  private func saveNormalWindowFrame() {
    updateLastNormalFrame()
    guard let frame = lastNormalFrame else { return }
    UserDefaults.standard.set(
      NSStringFromRect(frame),
      forKey: Self.windowFrameDefaultsKey
    )
  }

  func windowDidMove(_ notification: Notification) {
    updateLastNormalFrame()
  }

  func windowDidResize(_ notification: Notification) {
    updateLastNormalFrame()
  }

  private func configureWindowBehavior(messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: Self.windowBehaviorChannelName,
      binaryMessenger: messenger
    )
    windowBehaviorMethodChannel = methodChannel
    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }
      switch call.method {
      case "setMinimizeToTrayOnClose":
        guard let enabled = call.arguments as? Bool else {
          result(
            FlutterError(
              code: "invalid_arguments",
              message: "Expected a boolean value.",
              details: nil
            )
          )
          return
        }
        self.minimizeToTrayOnClose = enabled
        self.updateTrayItem()
        result(nil)
      case "setTrayMenu":
        self.handleSetTrayMenu(call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let eventChannel = FlutterEventChannel(
      name: Self.windowBehaviorEventsChannelName,
      binaryMessenger: messenger
    )
    windowBehaviorEventChannel = eventChannel
    eventChannel.setStreamHandler(self)
  }

  private func handleSetTrayMenu(
    _ arguments: Any?,
    result: @escaping FlutterResult
  ) {
    guard
      let values = arguments as? [String: Any],
      let appTitle = values["appTitle"] as? String,
      let openApp = values["openApp"] as? String,
      let exitApp = values["exitApp"] as? String,
      let rawItems = values["items"] as? [Any],
      !appTitle.isEmpty,
      !openApp.isEmpty,
      !exitApp.isEmpty
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Tray menu values are required.",
          details: nil
        )
      )
      return
    }

    var parsedItems: [TrayMenuItem] = []
    parsedItems.reserveCapacity(rawItems.count)
    for rawItem in rawItems {
      guard
        let item = rawItem as? [String: Any],
        let actionID = item["id"] as? String,
        let title = item["label"] as? String,
        !actionID.isEmpty,
        !title.isEmpty
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "Invalid tray menu item.",
            details: nil
          )
        )
        return
      }
      parsedItems.append(TrayMenuItem(actionID: actionID, title: title))
    }

    trayAppTitle = appTitle
    trayOpenApp = openApp
    trayExitApp = exitApp
    trayMenuItems = parsedItems
    trayLabelsReady = true
    updateTrayItem()
    result(nil)
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    trayEventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    trayEventSink = nil
    return nil
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    if minimizeToTrayOnClose && trayStatusItem != nil && !closeRequested {
      orderOut(nil)
      return false
    }
    return true
  }

  private func updateTrayItem() {
    guard minimizeToTrayOnClose && trayLabelsReady else {
      removeTrayItem()
      return
    }

    if trayStatusItem == nil {
      let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.squareLength
      )
      if let button = statusItem.button {
        if let applicationIcon = NSApplication.shared.applicationIconImage.copy()
          as? NSImage {
          applicationIcon.size = NSSize(width: 18, height: 18)
          button.image = applicationIcon
        }
        button.imagePosition = .imageOnly
      }
      trayStatusItem = statusItem
    }

    trayStatusItem?.button?.toolTip = trayAppTitle
    rebuildTrayMenu()
  }

  private func removeTrayItem() {
    guard let statusItem = trayStatusItem else { return }
    NSStatusBar.system.removeStatusItem(statusItem)
    self.trayStatusItem = nil
  }

  private func rebuildTrayMenu() {
    guard let statusItem = trayStatusItem else { return }
    let menu = NSMenu()
    menu.autoenablesItems = false

    let openItem = NSMenuItem(
      title: trayOpenApp,
      action: #selector(showFromTray(_:)),
      keyEquivalent: ""
    )
    openItem.target = self
    menu.addItem(openItem)

    if !trayMenuItems.isEmpty {
      menu.addItem(.separator())
      for item in trayMenuItems {
        let menuItem = NSMenuItem(
          title: item.title,
          action: #selector(selectTrayAction(_:)),
          keyEquivalent: ""
        )
        menuItem.target = self
        menuItem.representedObject = item.actionID
        menu.addItem(menuItem)
      }
    }

    menu.addItem(.separator())
    let exitItem = NSMenuItem(
      title: trayExitApp,
      action: #selector(exitFromTray(_:)),
      keyEquivalent: ""
    )
    exitItem.target = self
    menu.addItem(exitItem)
    statusItem.menu = menu
  }

  @objc private func showFromTray(_ sender: Any?) {
    if isMiniaturized {
      deminiaturize(nil)
    }
    makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc private func exitFromTray(_ sender: Any?) {
    closeRequested = true
    removeTrayItem()
    NSApp.terminate(nil)
  }

  @objc private func selectTrayAction(_ sender: NSMenuItem) {
    guard let actionID = sender.representedObject as? String else { return }
    trayEventSink?(actionID)
  }

  deinit {
    if let observer = terminationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
    removeTrayItem()
    windowBehaviorMethodChannel?.setMethodCallHandler(nil)
    windowBehaviorEventChannel?.setStreamHandler(nil)
  }
}
