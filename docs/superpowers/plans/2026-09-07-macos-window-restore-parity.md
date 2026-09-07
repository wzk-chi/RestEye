# macOS Window Restore Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the macOS menu-bar “Open” action explicitly restore a minimized RestEye window, matching Windows tray behavior.

**Architecture:** Keep the existing platform-specific `WindowBehaviorGateway` contract and Flutter menu action routing unchanged. Adjust only the macOS host window presentation code so hidden windows continue using `makeKeyAndOrderFront`, while minimized windows are first deminiaturized; exit, screen-state, notification, and timer business logic remain untouched.

**Tech Stack:** Swift/AppKit, Flutter macOS host, Flutter static analysis and macOS release build.

---

## File map

- Modify: `macos/Runner/MainFlutterWindow.swift` — restore a minimized `NSWindow` before activating it from the status-item “Open” action.
- No test files — the repository explicitly prohibits adding or running unit, widget, or integration tests; compilation and static analysis are the required verification.

### Task 1: Restore minimized macOS window from the menu bar

**Files:**
- Modify: `macos/Runner/MainFlutterWindow.swift:231-234`

- [ ] **Step 1: Apply the minimal AppKit change**

Replace the existing `showFromTray` body:

```swift
  @objc private func showFromTray(_ sender: Any?) {
    makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
```

with:

```swift
  @objc private func showFromTray(_ sender: Any?) {
    if isMiniaturized {
      deminiaturize(nil)
    }
    makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
```

This preserves the existing behavior for windows hidden with `orderOut(nil)` and adds the missing equivalent of Windows `ShowWindow(..., SW_RESTORE)` for Dock-minimized windows.

- [ ] **Step 2: Check the focused diff**

Run:

```bash
git diff --check
git diff -- macos/Runner/MainFlutterWindow.swift
```

Expected: only the `isMiniaturized`/`deminiaturize(nil)` guard appears in `showFromTray`, with no whitespace errors.

- [ ] **Step 3: Run Dart static analysis**

Run:

```bash
flutter analyze
```

Expected: exit code 0 with no analyzer errors.

- [ ] **Step 4: Build the macOS target**

Run:

```bash
flutter build macos
```

Expected: exit code 0 and a generated macOS build artifact; do not launch RestEye during packaging or verification.

- [ ] **Step 5: Review and commit the implementation**

Run:

```bash
git diff --check
git status --short
git add macos/Runner/MainFlutterWindow.swift
git commit -m "fix: restore macOS window from menu bar"
```

Expected: the commit contains only the macOS window restoration change; the previously committed design and plan documents remain separate documentation commits.
