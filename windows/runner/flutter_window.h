#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>

#include <memory>
#include <string>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      screen_state_method_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      window_behavior_method_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      notification_identity_method_channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      window_behavior_event_channel_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
      window_behavior_event_sink_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      screen_state_event_channel_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
      screen_state_event_sink_;
  bool session_notification_registered_ = false;
  bool screen_state_poll_timer_started_ = false;
  bool session_lock_state_known_ = false;
  bool session_locked_ = false;
  std::string screen_state_ = "on";

  static constexpr UINT kTrayCallbackMessage = WM_APP + 1;
  static constexpr UINT kTrayOpenCommand = 40001;
  static constexpr UINT kTrayExitCommand = 40002;
  static constexpr UINT kTrayActionCommandBase = 40010;
  static constexpr UINT kTrayIconId = 1;
  static constexpr UINT kScreenStatePollTimerId = 1;
  static constexpr UINT kScreenStatePollIntervalMs = 1000;

  struct TrayMenuItem {
    UINT command_id;
    std::string action_id;
    std::wstring label;
  };

  bool minimize_to_tray_on_close_ = true;
  bool close_requested_ = false;
  bool tray_icon_added_ = false;
  bool tray_labels_ready_ = false;
  HWND tray_window_handle_ = nullptr;
  std::wstring tray_app_title_;
  std::wstring tray_open_app_;
  std::wstring tray_exit_app_;
  std::vector<TrayMenuItem> tray_menu_items_;

  void UpdateTrayIcon();
  void RemoveTrayIcon();
  void ShowFromTray();
  void ShowTrayMenu();
  void ExitFromTray();
  void HandleTrayCallback(LPARAM lparam);
  void HandleTrayAction(
      UINT command_id,
      const std::vector<TrayMenuItem>& menu_items);
  void PollScreenState();
  void PublishScreenState(const std::string& next_state);
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
