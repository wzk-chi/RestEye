import Cocoa
import CoreGraphics
import FlutterMacOS

final class ScreenStateBridge: NSObject, FlutterStreamHandler {
  private static let methodChannelName = "dev.resteye/screen_state"
  private static let eventChannelName = "dev.resteye/screen_state/events"
  private static let screenLockedNotification = Notification.Name(
    "com.apple.screenIsLocked"
  )
  private static let screenUnlockedNotification = Notification.Name(
    "com.apple.screenIsUnlocked"
  )

  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private var eventSink: FlutterEventSink?
  private var state: String
  private var observers: [NSObjectProtocol] = []

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: Self.methodChannelName,
      binaryMessenger: messenger
    )
    eventChannel = FlutterEventChannel(
      name: Self.eventChannelName,
      binaryMessenger: messenger
    )
    state = Self.readCurrentState()
    super.init()

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getCurrentState" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.state ?? "unknown")
    }
    eventChannel.setStreamHandler(self)

    let notificationCenter = DistributedNotificationCenter.default
    observers.append(
      notificationCenter.addObserver(
        forName: Self.screenLockedNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.publish("off")
      }
    )
    observers.append(
      notificationCenter.addObserver(
        forName: Self.screenUnlockedNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.publish("on")
      }
    )
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    state = Self.readCurrentState()
    eventSink = events
    events(state)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  deinit {
    methodChannel.setMethodCallHandler(nil)
    eventChannel.setStreamHandler(nil)
    let notificationCenter = DistributedNotificationCenter.default
    for observer in observers {
      notificationCenter.removeObserver(observer)
    }
  }

  private func publish(_ nextState: String) {
    guard nextState != state else { return }
    state = nextState
    eventSink?(nextState)
  }

  private static func readCurrentState() -> String {
    guard let session = CGSessionCopyCurrentDictionary() as NSDictionary? else {
      return "unknown"
    }
    guard let locked = session["CGSSessionScreenIsLocked"] as? NSNumber else {
      return "unknown"
    }
    return locked.boolValue ? "off" : "on"
  }
}
