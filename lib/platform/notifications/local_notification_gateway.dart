import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';
import 'package:rest_eye/l10n/l10n.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final class LocalNotificationGateway
    implements NotificationGateway, ActiveNotificationQueryCapability {
  LocalNotificationGateway(
    this._clock,
    this._logger, {
    required this._initialPresentation,
    this.onDidReceiveBackgroundNotificationResponse,
  });

  static const _startRestAction = 'startRest';
  static const _skipRestAction = 'skipRest';
  static const _startWorkAction = 'startWork';
  static const _restCategory = 'restEyeRestActions';
  static const _workCategory = 'restEyeWorkActions';
  static const _windowsAppUserModelId = 'RestEye.RestEye';
  static const _windowsGuid = 'f9bd2cd7-4f6c-4a16-b65d-2fbe306b77ef';
  static const _windowsIdentityChannel = MethodChannel(
    'dev.resteye/notification_identity',
  );

  final AppClock _clock;
  final AppLogger _logger;
  final NotificationPresentationOptions _initialPresentation;
  final DidReceiveBackgroundNotificationResponseCallback?
  onDidReceiveBackgroundNotificationResponse;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _actions = StreamController<NotificationActionRequest>.broadcast();
  final _claimedActionNotificationIds = <int>{};
  AppLocalizations? _cachedStrings;
  String? _cachedLocaleKey;
  AndroidScheduleMode? _cachedAndroidScheduleMode;
  NotificationActionRequest? _launchAction;
  ActiveNotificationQueryReliability _activeNotificationQueryReliability =
      ActiveNotificationQueryReliability.nonAuthoritative;
  var _pluginReady = false;
  var _disposed = false;

  @override
  int get maxPendingNotificationRequests => switch (defaultTargetPlatform) {
    TargetPlatform.macOS => 64,
    TargetPlatform.android || TargetPlatform.windows => 256,
    _ => 0,
  };

  @override
  Stream<NotificationActionRequest> get actions => _actions.stream;

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final strings = _stringsFor(_initialPresentation.localeCode);
    try {
      final windowsIconPath = _windowsNotificationIconPath();
      final darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            _restCategory,
            actions: [
              DarwinNotificationAction.plain(
                _startRestAction,
                strings.notificationActionStartRest,
              ),
              DarwinNotificationAction.plain(
                _skipRestAction,
                strings.notificationActionSkipRest,
              ),
            ],
          ),
          DarwinNotificationCategory(
            _workCategory,
            actions: [
              DarwinNotificationAction.plain(
                _startWorkAction,
                strings.actionStartWork,
              ),
            ],
          ),
        ],
      );
      final initializationSettings = InitializationSettings(
        android: const AndroidInitializationSettings('ic_stat_rest_eye'),
        iOS: darwin,
        macOS: darwin,
        windows: WindowsInitializationSettings(
          appName: strings.appTitle,
          appUserModelId: _windowsAppUserModelId,
          guid: _windowsGuid,
          iconPath: windowsIconPath,
        ),
      );
      await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _handleResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
      _activeNotificationQueryReliability =
          _platformActiveNotificationQueryReliability();
      if (windowsIconPath != null) {
        await _windowsIdentityChannel.invokeMethod<void>('register', {
          'appUserModelId': _windowsAppUserModelId,
          'displayName': strings.appTitle,
          'iconPath': windowsIconPath,
        });
      }
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      final response = launchDetails?.notificationResponse;
      if (launchDetails?.didNotificationLaunchApp == true && response != null) {
        _launchAction = _parseResponse(response);
        final action = _launchAction;
        if (action != null) claimActionNotification(action.notificationId);
      }
      // Notification capability degradation is handled by the reconciler via
      // failed queries/schedules; a broken plugin setup must not take down
      // application bootstrap.
      _pluginReady = true;
    } catch (error) {
      _pluginReady = false;
      _logger.warning(
        'Notification gateway initialization failed; '
        'notifications degrade until restart',
        error: error,
      );
    }
  }

  String? _windowsNotificationIconPath() {
    if (defaultTargetPlatform != TargetPlatform.windows) return null;
    final executableDirectory = File(Platform.resolvedExecutable).parent;
    final icon = File.fromUri(
      executableDirectory.uri.resolve(
        'data/flutter_assets/assets/brand/resteye_icon.png',
      ),
    );
    if (!icon.existsSync()) {
      throw StateError('Windows notification icon was not found: ${icon.path}');
    }
    return icon.path;
  }

  @override
  Future<NotificationPermissionStatus> permissionStatus() async {
    if (!_pluginReady) return NotificationPermissionStatus.unavailable;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return NotificationPermissionStatus.granted;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await android?.areNotificationsEnabled();
      return enabled == null
          ? NotificationPermissionStatus.notDetermined
          : enabled
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final options = await macOS?.checkPermissions();
      if (options == null) return NotificationPermissionStatus.notDetermined;
      return options.isEnabled
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    return NotificationPermissionStatus.unavailable;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      if (granted == true) {
        _cachedAndroidScheduleMode = null;
        try {
          await android?.requestExactAlarmsPermission();
        } on PlatformException {
          // Exact alarms improve punctuality; schedule() falls back safely.
        } on MissingPluginException {
          // Older or incomplete platform implementations use the fallback.
        } on UnsupportedError {
          // Unsupported platform implementations use the fallback.
        }
      }
      return granted == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final granted = await macOS?.requestPermissions(alert: true, sound: true);
      return granted == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    return permissionStatus();
  }

  @override
  Future<Set<int>> pendingNotificationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((item) => item.id).toSet();
  }

  @override
  ActiveNotificationQueryReliability get activeNotificationQueryReliability =>
      _activeNotificationQueryReliability;

  @override
  Future<Set<int>> activeNotificationIds() async {
    final ids = <int>{..._claimedActionNotificationIds};
    if (_activeNotificationQueryReliability ==
        ActiveNotificationQueryReliability.nonAuthoritative) {
      return ids;
    }
    try {
      final active = await _plugin.getActiveNotifications();
      ids.addAll(active.map((item) => item.id).whereType<int>());
    } on UnimplementedError {
      _markActiveNotificationQueryNonAuthoritative();
    } on UnsupportedError {
      _markActiveNotificationQueryNonAuthoritative();
    } on PlatformException {
      _markActiveNotificationQueryNonAuthoritative();
    } on MissingPluginException {
      _markActiveNotificationQueryNonAuthoritative();
    }
    return ids;
  }

  ActiveNotificationQueryReliability
  _platformActiveNotificationQueryReliability() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows =>
        MsixUtils.hasPackageIdentity()
            ? ActiveNotificationQueryReliability.authoritative
            : ActiveNotificationQueryReliability.nonAuthoritative,
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => ActiveNotificationQueryReliability.authoritative,
      _ => ActiveNotificationQueryReliability.nonAuthoritative,
    };
  }

  void _markActiveNotificationQueryNonAuthoritative() {
    _activeNotificationQueryReliability =
        ActiveNotificationQueryReliability.nonAuthoritative;
  }

  @override
  void claimActionNotification(int notificationId) {
    if (!_disposed) _claimedActionNotificationIds.add(notificationId);
  }

  @override
  void releaseActionNotification(int notificationId) {
    if (!_disposed) _claimedActionNotificationIds.remove(notificationId);
  }

  @override
  Set<int> get claimedActionNotificationIds =>
      Set.unmodifiable(_claimedActionNotificationIds);

  @override
  Future<void> schedule(
    ScheduledNotification notification, {
    required NotificationPresentationOptions presentation,
  }) async {
    if (_claimedActionNotificationIds.contains(notification.id)) return;
    final strings = _stringsFor(presentation.localeCode);
    final copy = _copyFor(notification.kind, strings);
    final basePayload = jsonEncode({
      'notificationId': notification.id,
      'cycleId': notification.cycleId,
      'expectedPhase': notification.expectedPhase.name,
      'expectedRevision': notification.expectedRevision,
      'expiresAtUtc': notification.expiresAtUtc.toUtc().toIso8601String(),
    });
    final androidActions = notification.hasRestActions
        ? [
            AndroidNotificationAction(
              _startRestAction,
              strings.notificationActionStartRest,
              showsUserInterface: false,
              cancelNotification: false,
            ),
            AndroidNotificationAction(
              _skipRestAction,
              strings.notificationActionSkipRest,
              showsUserInterface: false,
              cancelNotification: false,
            ),
          ]
        : notification.hasStartWorkAction
        ? [
            AndroidNotificationAction(
              _startWorkAction,
              strings.actionStartWork,
              showsUserInterface: false,
              cancelNotification: false,
            ),
          ]
        : const <AndroidNotificationAction>[];
    final windowsActions = notification.hasRestActions
        ? [
            WindowsAction(
              content: strings.notificationActionStartRest,
              arguments: _windowsActionPayload(_startRestAction, notification),
            ),
            WindowsAction(
              content: strings.notificationActionSkipRest,
              arguments: _windowsActionPayload(_skipRestAction, notification),
            ),
          ]
        : notification.hasStartWorkAction
        ? [
            WindowsAction(
              content: strings.actionStartWork,
              arguments: _windowsActionPayload(_startWorkAction, notification),
            ),
          ]
        : const <WindowsAction>[];
    final darwinCategory = notification.hasRestActions
        ? _restCategory
        : notification.hasStartWorkAction
        ? _workCategory
        : null;
    final channelSuffix = notification.vibrationEnabled ? 'vibration' : 'quiet';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rest_eye_reminders_$channelSuffix',
        strings.notificationChannelName,
        channelDescription: strings.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: notification.vibrationEnabled,
        playSound: true,
        // Keep timer reminders in the notification shade until the user
        // dismisses them or the timer state makes them obsolete. Android's
        // heads-up banner may still fade out, but the notification itself
        // must not expire just because it was delivered by an alarm receiver.
        autoCancel: false,
        ongoing: false,
        timeoutAfter: null,
        actions: androidActions,
      ),
      iOS: DarwinNotificationDetails(categoryIdentifier: darwinCategory),
      macOS: DarwinNotificationDetails(categoryIdentifier: darwinCategory),
      windows: WindowsNotificationDetails(
        duration: WindowsNotificationDuration.long,
        actions: windowsActions,
        audio: WindowsNotificationAudio.preset(
          sound: WindowsNotificationSound.defaultSound,
        ),
      ),
    );
    final now = _clock.utcNow;
    if (!notification.scheduledAtUtc.isAfter(now)) {
      // A scheduled notification may still have an AlarmManager entry when
      // the in-app deadline reconciler wins the race. Remove that entry
      // before showing the due notification immediately, otherwise Android
      // can deliver it twice.
      await _plugin.cancel(id: notification.id);
      if (_claimedActionNotificationIds.contains(notification.id)) return;
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _windowsNotifications.showRawXml(
          id: notification.id,
          xml: _windowsToastXml(
            title: copy.$1,
            body: copy.$2,
            payload: basePayload,
            actions: windowsActions,
          ),
        );
      } else {
        await _plugin.show(
          id: notification.id,
          title: copy.$1,
          body: copy.$2,
          notificationDetails: details,
          payload: basePayload,
        );
      }
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await _windowsNotifications.zonedScheduleRawXml(
        id: notification.id,
        xml: _windowsToastXml(
          title: copy.$1,
          body: copy.$2,
          payload: basePayload,
          actions: windowsActions,
        ),
        scheduledDate: tz.TZDateTime.from(notification.scheduledAtUtc, tz.UTC),
      );
    } else {
      await _plugin.zonedSchedule(
        id: notification.id,
        title: copy.$1,
        body: copy.$2,
        scheduledDate: tz.TZDateTime.from(notification.scheduledAtUtc, tz.UTC),
        notificationDetails: details,
        androidScheduleMode: await _androidScheduleMode(),
        payload: basePayload,
      );
    }
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final cached = _cachedAndroidScheduleMode;
    if (cached != null) return cached;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return _cachedAndroidScheduleMode =
          AndroidScheduleMode.inexactAllowWhileIdle;
    }
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canScheduleExact = await android?.canScheduleExactNotifications();
      return _cachedAndroidScheduleMode = canScheduleExact == true
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } on PlatformException {
      return _cachedAndroidScheduleMode =
          AndroidScheduleMode.inexactAllowWhileIdle;
    } on MissingPluginException {
      return _cachedAndroidScheduleMode =
          AndroidScheduleMode.inexactAllowWhileIdle;
    } on UnsupportedError {
      return _cachedAndroidScheduleMode =
          AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  AppLocalizations _stringsFor(String? localeCode) {
    final locale = resolveSupportedLocale(
      localeCode,
      PlatformDispatcher.instance.locales,
    );
    final key = locale.toString();
    if (_cachedLocaleKey == key && _cachedStrings != null) {
      return _cachedStrings!;
    }
    final strings = lookupAppLocalizations(locale);
    _cachedLocaleKey = key;
    _cachedStrings = strings;
    return strings;
  }

  FlutterLocalNotificationsWindows get _windowsNotifications {
    final windows = _plugin
        .resolvePlatformSpecificImplementation<
          FlutterLocalNotificationsWindows
        >();
    if (windows == null) {
      throw StateError('Windows notifications are not initialized');
    }
    return windows;
  }

  String _windowsToastXml({
    required String title,
    required String body,
    String? payload,
    required List<WindowsAction> actions,
  }) {
    final actionXml = actions.isEmpty
        ? ''
        : '<actions>${actions.map(_windowsActionXml).join()}</actions>';
    final launchAttribute = payload == null
        ? ''
        : ' launch="${_xmlEscape(payload)}"';
    return '<toast duration="long"$launchAttribute useButtonStyle="true">'
        '<visual><binding template="ToastGeneric">'
        '<text>${_xmlEscape(title)}</text>'
        '<text>${_xmlEscape(body)}</text>'
        '</binding></visual>'
        '<audio src="${WindowsNotificationSound.defaultSound.name}" '
        'silent="false" loop="false"/>'
        '$actionXml'
        '</toast>';
  }

  String _windowsActionXml(WindowsAction action) {
    final attributes = <String, String>{
      'content': action.content,
      'arguments': action.arguments,
      'activationType': action.activationType.name,
      'afterActivationBehavior': action.activationBehavior.name,
      if (action.placement != null) 'placement': action.placement!.name,
      if (action.imageUri != null) 'imageUri': action.imageUri.toString(),
      if (action.inputId != null) 'hint-inputId': action.inputId!,
      if (action.buttonStyle != null)
        'hint-buttonStyle': action.buttonStyle!.name,
      if (action.tooltip != null) 'hint-toolTip': action.tooltip!,
    };
    final serialized = attributes.entries
        .map((entry) => '${entry.key}="${_xmlEscape(entry.value)}"')
        .join(' ');
    return '<action $serialized/>';
  }

  String _xmlEscape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  @override
  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(id: notificationId);
    _claimedActionNotificationIds.remove(notificationId);
  }

  @override
  Future<NotificationActionRequest?> takeLaunchAction() async {
    final action = _launchAction;
    _launchAction = null;
    return action;
  }

  void _handleResponse(NotificationResponse response) {
    if (_disposed) return;
    final action = _parseResponse(response);
    if (action != null && !_actions.isClosed) {
      claimActionNotification(action.notificationId);
      _actions.add(action);
    }
  }

  NotificationActionRequest? _parseResponse(NotificationResponse response) {
    return parseLocalNotificationActionResponse(response, _clock);
  }

  String _windowsActionPayload(
    String action,
    ScheduledNotification notification,
  ) {
    return jsonEncode({
      'action': action,
      'notificationId': notification.id,
      'cycleId': notification.cycleId,
      'expectedPhase': notification.expectedPhase.name,
      'expectedRevision': notification.expectedRevision,
      'expiresAtUtc': notification.expiresAtUtc.toUtc().toIso8601String(),
    });
  }

  (String, String) _copyFor(NotificationKind kind, AppLocalizations strings) {
    return switch (kind) {
      NotificationKind.workComplete => (
        strings.notificationWorkCompleteTitle,
        strings.notificationWorkCompleteBody,
      ),
      NotificationKind.restReminder => (
        strings.notificationRestReminderTitle,
        strings.notificationRestReminderBody,
      ),
      NotificationKind.restComplete => (
        strings.notificationRestCompleteTitle,
        strings.notificationRestCompleteBody,
      ),
    };
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _launchAction = null;
    _claimedActionNotificationIds.clear();
    await _actions.close();
  }
}

NotificationActionRequest? parseLocalNotificationActionResponse(
  NotificationResponse response,
  AppClock clock,
) {
  final actionId = response.actionId;
  final raw = actionId?.startsWith('{') == true ? actionId : response.payload;
  if (raw == null || raw.isEmpty) return null;
  try {
    final json = jsonDecode(raw) as Map<String, Object?>;
    final typeCode = actionId?.startsWith('{') == true
        ? json['action'] as String?
        : actionId;
    final type = switch (typeCode) {
      LocalNotificationGateway._startRestAction =>
        NotificationActionType.startRest,
      LocalNotificationGateway._skipRestAction =>
        NotificationActionType.skipRest,
      LocalNotificationGateway._startWorkAction =>
        NotificationActionType.startWork,
      _ => null,
    };
    if (type == null) return null;
    final now = clock.utcNow;
    final notificationId =
        response.id ?? (json['notificationId'] as num?)?.toInt();
    if (notificationId == null) return null;
    return NotificationActionRequest(
      commandId: 'notification-${json['cycleId']}-$notificationId-$typeCode',
      notificationId: notificationId,
      type: type,
      cycleId: json['cycleId']! as String,
      expectedPhase: TimerPhase.values.byName(json['expectedPhase']! as String),
      expectedRevision: json['expectedRevision']! as int,
      occurredAtUtc: now,
      expiresAtUtc: _parseUtc(json['expiresAtUtc']),
    );
  } on FormatException {
    return null;
  } on ArgumentError {
    return null;
  } on TypeError {
    return null;
  }
}

DateTime? _parseUtc(Object? value) {
  if (value is! String) return null;
  try {
    return DateTime.parse(value).toUtc();
  } on FormatException {
    return null;
  }
}
