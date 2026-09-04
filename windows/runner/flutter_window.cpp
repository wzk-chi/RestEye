#include "flutter_window.h"

#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <shellapi.h>
#include <windows.h>
#include <wtsapi32.h>

#include <cstring>
#include <cwchar>
#include <iostream>
#include <optional>
#include <string>
#include <utility>
#include <variant>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {

std::optional<std::wstring> Utf8ToWide(const std::string& value) {
  if (value.empty()) return std::wstring();
  const auto source_length = static_cast<int>(value.size());
  const int destination_length = MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.data(), source_length, nullptr, 0);
  if (destination_length <= 0) return std::nullopt;

  std::wstring result(destination_length, L'\0');
  if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
                          source_length, result.data(), destination_length) ==
      0) {
    return std::nullopt;
  }
  return result;
}

std::optional<std::wstring> ReadStringArgument(
    const flutter::EncodableMap& arguments,
    const char* key) {
  const auto iterator =
      arguments.find(flutter::EncodableValue(std::string(key)));
  if (iterator == arguments.end()) return std::nullopt;
  const auto* value = std::get_if<std::string>(&iterator->second);
  if (value == nullptr) return std::nullopt;
  return Utf8ToWide(*value);
}

std::optional<std::string> ReadUtf8StringArgument(
    const flutter::EncodableMap& arguments,
    const char* key) {
  const auto iterator =
      arguments.find(flutter::EncodableValue(std::string(key)));
  if (iterator == arguments.end()) return std::nullopt;
  const auto* value = std::get_if<std::string>(&iterator->second);
  if (value == nullptr) return std::nullopt;
  return *value;
}

LSTATUS WriteRegistryString(HKEY key,
                            const wchar_t* value_name,
                            const std::wstring& value) {
  return RegSetValueExW(
      key, value_name, 0, REG_SZ,
      reinterpret_cast<const BYTE*>(value.c_str()),
      static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t)));
}

LSTATUS RegisterNotificationIdentity(const std::wstring& app_user_model_id,
                                     const std::wstring& display_name,
                                     const std::wstring& icon_path) {
  const auto icon_attributes = GetFileAttributesW(icon_path.c_str());
  if (icon_attributes == INVALID_FILE_ATTRIBUTES ||
      (icon_attributes & FILE_ATTRIBUTE_DIRECTORY) != 0) {
    return ERROR_FILE_NOT_FOUND;
  }

  const std::wstring subkey =
      L"Software\\Classes\\AppUserModelId\\" + app_user_model_id;
  HKEY key = nullptr;
  auto status = RegCreateKeyExW(HKEY_CURRENT_USER, subkey.c_str(), 0, nullptr,
                                0, KEY_SET_VALUE, nullptr, &key, nullptr);
  if (status != ERROR_SUCCESS) return status;

  status = WriteRegistryString(key, L"DisplayName", display_name);
  if (status == ERROR_SUCCESS) {
    status = WriteRegistryString(key, L"IconUri", icon_path);
  }
  RegCloseKey(key);
  return status;
}

void CopyTrayText(wchar_t* destination,
                  size_t destination_length,
                  const std::wstring& value) {
  if (destination_length == 0) return;
  wcsncpy_s(destination, destination_length, value.c_str(), _TRUNCATE);
}

void LogScreenState(const std::string& message) {
  const auto output = "[RestEye ScreenState] " + message + "\n";
  OutputDebugStringA(output.c_str());
#ifndef NDEBUG
  std::cerr << output;
#endif
}

std::optional<bool> ReadWindowsLockState() {
  const HDESK desktop = OpenInputDesktop(0, FALSE, DESKTOP_READOBJECTS);
  if (desktop == nullptr) return std::nullopt;

  wchar_t desktop_name[256] = {};
  DWORD returned_length = 0;
  const auto succeeded = GetUserObjectInformationW(
      desktop, UOI_NAME, desktop_name, sizeof(desktop_name), &returned_length);
  CloseDesktop(desktop);
  if (!succeeded) return std::nullopt;
  return std::wstring(desktop_name) == L"Winlogon";
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  auto* messenger = flutter_controller_->engine()->messenger();
  window_behavior_method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "dev.resteye/window_behavior",
          &flutter::StandardMethodCodec::GetInstance());
  window_behavior_method_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "setMinimizeToTrayOnClose") {
          const auto* enabled = call.arguments() == nullptr
                                    ? nullptr
                                    : std::get_if<bool>(call.arguments());
          if (enabled == nullptr) {
            result->Error("invalid_arguments", "Expected a boolean value.");
            return;
          }
          minimize_to_tray_on_close_ = *enabled;
          UpdateTrayIcon();
          result->Success();
          return;
        }

        if (call.method_name() == "setTrayMenu") {
          const auto* arguments = call.arguments() == nullptr
                                      ? nullptr
                                      : std::get_if<flutter::EncodableMap>(
                                            call.arguments());
          if (arguments == nullptr) {
            result->Error("invalid_arguments", "Expected a tray menu map.");
            return;
          }
          const auto app_title = ReadStringArgument(*arguments, "appTitle");
          const auto open_app = ReadStringArgument(*arguments, "openApp");
          const auto exit_app = ReadStringArgument(*arguments, "exitApp");
          const auto items_iterator =
              arguments->find(flutter::EncodableValue(std::string("items")));
          const auto* items = items_iterator == arguments->end()
                                  ? nullptr
                                  : std::get_if<flutter::EncodableList>(
                                        &items_iterator->second);
          if (!app_title || !open_app || !exit_app || app_title->empty() ||
              open_app->empty() || exit_app->empty() || items == nullptr) {
            result->Error("invalid_arguments", "Tray menu values are required.");
            return;
          }

          std::vector<TrayMenuItem> parsed_items;
          parsed_items.reserve(items->size());
          UINT command_id = kTrayActionCommandBase;
          for (const auto& item_value : *items) {
            const auto* item = std::get_if<flutter::EncodableMap>(&item_value);
            if (item == nullptr) {
              result->Error("invalid_arguments", "Invalid tray menu item.");
              return;
            }
            const auto action_id = ReadUtf8StringArgument(*item, "id");
            const auto label = ReadStringArgument(*item, "label");
            if (!action_id || action_id->empty() || !label || label->empty()) {
              result->Error("invalid_arguments", "Tray menu item values are required.");
              return;
            }
            parsed_items.push_back(
                TrayMenuItem{command_id++, *action_id, *label});
          }

          tray_app_title_ = *app_title;
          tray_open_app_ = *open_app;
          tray_exit_app_ = *exit_app;
          tray_menu_items_ = std::move(parsed_items);
          tray_labels_ready_ = true;
          UpdateTrayIcon();
          result->Success();
          return;
        }

        result->NotImplemented();
      });

  notification_identity_method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "dev.resteye/notification_identity",
          &flutter::StandardMethodCodec::GetInstance());
  notification_identity_method_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() != "register") {
          result->NotImplemented();
          return;
        }
        const auto* arguments =
            call.arguments() == nullptr
                ? nullptr
                : std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments == nullptr) {
          result->Error("invalid_arguments",
                        "Expected a notification identity map.");
          return;
        }
        const auto app_user_model_id =
            ReadStringArgument(*arguments, "appUserModelId");
        const auto display_name =
            ReadStringArgument(*arguments, "displayName");
        const auto icon_path = ReadStringArgument(*arguments, "iconPath");
        if (!app_user_model_id || !display_name || !icon_path ||
            app_user_model_id->empty() || display_name->empty() ||
            icon_path->empty()) {
          result->Error("invalid_arguments",
                        "Notification identity values are required.");
          return;
        }
        const auto status = RegisterNotificationIdentity(
            *app_user_model_id, *display_name, *icon_path);
        if (status != ERROR_SUCCESS) {
          result->Error("registration_failed",
                        "Could not register the notification identity.",
                        flutter::EncodableValue(static_cast<int>(status)));
          return;
        }
        result->Success();
      });

  screen_state_method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "dev.resteye/screen_state",
          &flutter::StandardMethodCodec::GetInstance());
  screen_state_method_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "getCurrentState") {
          result->Success(flutter::EncodableValue(screen_state_));
        } else {
          result->NotImplemented();
        }
      });

  screen_state_event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger, "dev.resteye/screen_state/events",
          &flutter::StandardMethodCodec::GetInstance());
  screen_state_event_channel_->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue*,
                 std::unique_ptr<
                     flutter::EventSink<flutter::EncodableValue>>&& events) {
            screen_state_event_sink_ = std::move(events);
            if (screen_state_event_sink_) {
              screen_state_event_sink_->Success(
                  flutter::EncodableValue(screen_state_));
            }
            return nullptr;
          },
          [this](const flutter::EncodableValue*) {
            screen_state_event_sink_.reset();
            return nullptr;
           }));

  window_behavior_event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger, "dev.resteye/window_behavior/events",
          &flutter::StandardMethodCodec::GetInstance());
  window_behavior_event_channel_->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue*,
                 std::unique_ptr<
                     flutter::EventSink<flutter::EncodableValue>>&& events) {
            window_behavior_event_sink_ = std::move(events);
            return nullptr;
          },
          [this](const flutter::EncodableValue*) {
            window_behavior_event_sink_.reset();
            return nullptr;
          }));

  session_notification_registered_ =
      WTSRegisterSessionNotification(GetHandle(), NOTIFY_FOR_THIS_SESSION) !=
      FALSE;
  LogScreenState(session_notification_registered_
                     ? "WTS session notification registered"
                     : "WTS session notification registration failed");
  screen_state_ = "unknown";
  PollScreenState();
  if (!session_notification_registered_ && GetHandle() != nullptr) {
    screen_state_poll_timer_started_ =
        SetTimer(GetHandle(), kScreenStatePollTimerId,
                 kScreenStatePollIntervalMs, nullptr) != 0;
  }
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([this]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  RemoveTrayIcon();
  if (session_notification_registered_) {
    WTSUnRegisterSessionNotification(GetHandle());
    session_notification_registered_ = false;
  }
  if (screen_state_poll_timer_started_) {
    KillTimer(GetHandle(), kScreenStatePollTimerId);
    screen_state_poll_timer_started_ = false;
  }
  if (screen_state_event_sink_) {
    screen_state_event_sink_->EndOfStream();
    screen_state_event_sink_.reset();
  }
  if (window_behavior_event_sink_) {
    window_behavior_event_sink_->EndOfStream();
    window_behavior_event_sink_.reset();
  }
  window_behavior_method_channel_.reset();
  notification_identity_method_channel_.reset();
  window_behavior_event_channel_.reset();
  screen_state_method_channel_.reset();
  screen_state_event_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_CLOSE && minimize_to_tray_on_close_ &&
      tray_icon_added_ && !close_requested_) {
    ShowWindow(hwnd, SW_HIDE);
    return 0;
  }

  if (message == kTrayCallbackMessage) {
    HandleTrayCallback(lparam);
    return 0;
  }

  if (message == WM_COMMAND) {
    const auto command = LOWORD(wparam);
    if (command == kTrayOpenCommand) {
      ShowFromTray();
      return 0;
    }
    if (command == kTrayExitCommand) {
      ExitFromTray();
      return 0;
    }
    for (const auto& item : tray_menu_items_) {
      if (command == item.command_id) {
        HandleTrayAction(command, tray_menu_items_);
        return 0;
      }
    }
  }

  if (message == WM_WTSSESSION_CHANGE) {
    if (wparam == WTS_SESSION_LOCK) {
      session_lock_state_known_ = true;
      session_locked_ = true;
      LogScreenState("WTS_SESSION_LOCK received");
      PublishScreenState("off");
    } else if (wparam == WTS_SESSION_UNLOCK) {
      session_lock_state_known_ = true;
      session_locked_ = false;
      LogScreenState("WTS_SESSION_UNLOCK received");
      PublishScreenState("on");
    } else {
      LogScreenState("Unknown WTS session event: " +
                     std::to_string(static_cast<unsigned long>(wparam)));
    }
    return 0;
  }

  if (message == WM_TIMER && wparam == kScreenStatePollTimerId) {
    PollScreenState();
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      if (flutter_controller_) {
        flutter_controller_->engine()->ReloadSystemFonts();
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::UpdateTrayIcon() {
  if (!minimize_to_tray_on_close_ || !tray_labels_ready_) {
    RemoveTrayIcon();
    return;
  }

  NOTIFYICONDATAW data{};
  data.cbSize = sizeof(data);
  data.hWnd = GetHandle();
  data.uID = kTrayIconId;
  data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  data.uCallbackMessage = kTrayCallbackMessage;
  data.hIcon = LoadIconW(GetModuleHandle(nullptr),
                         MAKEINTRESOURCEW(IDI_APP_ICON));
  if (data.hIcon == nullptr) {
    data.hIcon = LoadIconW(nullptr, IDI_APPLICATION);
  }
  CopyTrayText(data.szTip, ARRAYSIZE(data.szTip), tray_app_title_);

  if (tray_icon_added_) {
    if (Shell_NotifyIconW(NIM_MODIFY, &data)) return;
    tray_icon_added_ = false;
    tray_window_handle_ = nullptr;
  }

  if (data.hWnd != nullptr && Shell_NotifyIconW(NIM_ADD, &data)) {
    tray_icon_added_ = true;
    tray_window_handle_ = data.hWnd;
    data.uVersion = NOTIFYICON_VERSION_4;
    Shell_NotifyIconW(NIM_SETVERSION, &data);
  }
}

void FlutterWindow::RemoveTrayIcon() {
  if (!tray_icon_added_) return;

  NOTIFYICONDATAW data{};
  data.cbSize = sizeof(data);
  data.hWnd = tray_window_handle_;
  data.uID = kTrayIconId;
  Shell_NotifyIconW(NIM_DELETE, &data);
  tray_icon_added_ = false;
  tray_window_handle_ = nullptr;
}

void FlutterWindow::ShowFromTray() {
  if (GetHandle() == nullptr) return;
  ShowWindow(GetHandle(), SW_SHOW);
  ShowWindow(GetHandle(), SW_RESTORE);
  SetForegroundWindow(GetHandle());
}

void FlutterWindow::ShowTrayMenu() {
  if (GetHandle() == nullptr || !tray_labels_ready_) return;

  const auto menu_items = tray_menu_items_;
  const HMENU menu = CreatePopupMenu();
  if (menu == nullptr) return;
  AppendMenuW(menu, MF_STRING, kTrayOpenCommand, tray_open_app_.c_str());
  if (!menu_items.empty()) {
    AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
    for (const auto& item : menu_items) {
      AppendMenuW(menu, MF_STRING, item.command_id, item.label.c_str());
    }
  }
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kTrayExitCommand, tray_exit_app_.c_str());

  POINT cursor_position{};
  GetCursorPos(&cursor_position);
  SetForegroundWindow(GetHandle());
  const auto selected_command = TrackPopupMenu(
      menu,
      TPM_RIGHTBUTTON | TPM_BOTTOMALIGN | TPM_RIGHTALIGN | TPM_RETURNCMD,
      cursor_position.x, cursor_position.y, 0, GetHandle(), nullptr);
  DestroyMenu(menu);
  PostMessageW(GetHandle(), WM_NULL, 0, 0);

  if (selected_command == kTrayOpenCommand) {
    ShowFromTray();
    return;
  }
  if (selected_command == kTrayExitCommand) {
    ExitFromTray();
    return;
  }
  HandleTrayAction(selected_command, menu_items);
}

void FlutterWindow::ExitFromTray() {
  close_requested_ = true;
  RemoveTrayIcon();
  if (GetHandle() != nullptr) {
    PostMessageW(GetHandle(), WM_CLOSE, 0, 0);
  }
}

void FlutterWindow::HandleTrayCallback(LPARAM lparam) {
  // Version 4 notification icons pack the event into the low word.
  const auto event = LOWORD(lparam);
  switch (event) {
    case WM_LBUTTONUP:
    case WM_LBUTTONDBLCLK:
    case NIN_SELECT:
    case NIN_KEYSELECT:
      ShowFromTray();
      return;
    case WM_RBUTTONUP:
    case WM_CONTEXTMENU:
      ShowTrayMenu();
      return;
    default:
      return;
  }
}

void FlutterWindow::HandleTrayAction(
    UINT command_id,
    const std::vector<TrayMenuItem>& menu_items) {
  if (!window_behavior_event_sink_) return;
  for (const auto& item : menu_items) {
    if (item.command_id == command_id) {
      window_behavior_event_sink_->Success(
          flutter::EncodableValue(item.action_id));
      return;
    }
  }
}

void FlutterWindow::PollScreenState() {
  // The WTS session event is authoritative. During the lock transition the
  // input desktop can briefly report the normal desktop; never turn that into
  // an unlock event until WTS_SESSION_UNLOCK arrives.
  if (session_lock_state_known_ && session_locked_) {
    PublishScreenState("off");
    return;
  }

  const auto locked = ReadWindowsLockState();
  if (!locked.has_value()) return;
  session_lock_state_known_ = true;
  session_locked_ = *locked;
  PublishScreenState(*locked ? "off" : "on");
}

void FlutterWindow::PublishScreenState(const std::string& next_state) {
  if (next_state == screen_state_) return;
  LogScreenState("Screen state changed from " + screen_state_ + " to " +
                 next_state);
  screen_state_ = next_state;
  if (screen_state_event_sink_) {
    screen_state_event_sink_->Success(flutter::EncodableValue(screen_state_));
  }
}
