// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '眸息';

  @override
  String get appFullName => 'RestEye · 眸息';

  @override
  String get appTagline => '轻松保持工作与休息节奏';

  @override
  String get navigationHome => '首页';

  @override
  String get navigationSettings => '设置';

  @override
  String get navigationStatistics => '统计';

  @override
  String get navigationAbout => '关于';

  @override
  String get timerPhaseIdle => '待开始';

  @override
  String get timerPhaseWorking => '专注中';

  @override
  String get timerPhaseAwaitingRest => '该休息了';

  @override
  String get timerPhaseResting => '休息中';

  @override
  String get timerPhaseSuspended => '锁屏暂停中';

  @override
  String get timerIdleMessage => '开始一轮工作，眸息会在合适的时候提醒你休息。';

  @override
  String get timerWorkingMessage => '保持自然眨眼，坐姿放松。';

  @override
  String get timerAwaitingRestMessage => '适时休息有助于缓解眼睛和身体的疲劳，长时间连续工作容易让疲劳越积越多。';

  @override
  String get timerRestingMessage => '离开屏幕，缓慢眨眼并放松肩颈。';

  @override
  String get timerSuspendedMessage => '解锁后将继续本轮工作计时。';

  @override
  String get timerElapsedWork => '已工作';

  @override
  String timerElapsedWorkSemantics(String phase, String time) {
    return '$phase，已工作 $time';
  }

  @override
  String get timerElapsedRest => '已休息';

  @override
  String timerElapsedRestSemantics(String phase, String time) {
    return '$phase，已休息 $time';
  }

  @override
  String get timerCurrentCycle => '本轮设置';

  @override
  String timerWorkDuration(String duration) {
    return '工作 $duration';
  }

  @override
  String timerRestDuration(String duration) {
    return '休息 $duration';
  }

  @override
  String get actionStartWork => '开始工作';

  @override
  String get actionResumeWork => '继续工作';

  @override
  String get actionStartRest => '开始休息';

  @override
  String get actionSkipRest => '跳过休息';

  @override
  String get actionStopTimer => '结束计时';

  @override
  String get actionEndRest => '结束休息';

  @override
  String get actionSave => '保存设置';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDone => '完成';

  @override
  String get actionRetry => '重试';

  @override
  String get actionExit => '退出';

  @override
  String get actionRequestPermission => '开启通知';

  @override
  String get commandFailed => '操作未完成，请重试。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsWorkDuration => '工作时长';

  @override
  String get settingsRestDuration => '休息时长';

  @override
  String get settingsRestCompletionBehavior => '休息结束后';

  @override
  String get settingsRestCompletionStartWork => '自动开始工作';

  @override
  String get settingsRestCompletionStopTimer => '结束计时';

  @override
  String get settingsRestCompletionContinueRest => '继续休息';

  @override
  String get settingsWorkReminder => '工作提醒';

  @override
  String get settingsWorkReminderDescription => '休息结束后提醒开始工作。';

  @override
  String get settingsRestReminder => '休息提醒';

  @override
  String get settingsRestReminderDescription => '工作结束后提醒开始休息。';

  @override
  String get settingsMissedRestReminder => '未休息重复提醒';

  @override
  String get settingsMissedRestReminderDescription => '未开始休息时，按设定间隔重复提醒。';

  @override
  String get settingsReminderInterval => '未休息提醒间隔';

  @override
  String get settingsReminderTimeout => '未休息超时时间';

  @override
  String get settingsTimeoutBehavior => '超时后处理';

  @override
  String get settingsTimeoutNextCycle => '进入下一轮';

  @override
  String get settingsTimeoutStopTimer => '结束计时';

  @override
  String get settingsVibration => 'Android 通知震动';

  @override
  String get settingsPauseWhenLocked => '锁屏暂停计时';

  @override
  String get settingsPauseWhenLockedDescription => '锁屏时暂停工作计时，解锁后继续。';

  @override
  String get settingsAutoSaveFailed => '自动保存失败，请重试。';

  @override
  String get settingsThemeMode => '主题模式';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '显示语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageEnglish => '英文';

  @override
  String get settingsFixedPortrait => '固定竖屏';

  @override
  String get settingsFixedPortraitDescription => '锁定应用为竖屏显示。';

  @override
  String get settingsMinimizeToTrayOnClose => '关闭时最小化到托盘';

  @override
  String get settingsMinimizeToTrayOnCloseDescription =>
      '关闭窗口后继续在后台运行，可从系统托盘重新打开。';

  @override
  String get settingsKeepInMenuBarOnClose => '关闭时保留在菜单栏';

  @override
  String get settingsKeepInMenuBarOnCloseDescription =>
      '关闭窗口后继续在后台运行，可从菜单栏重新打开。';

  @override
  String get timerQuickWorkDurationTitle => '设置工作时长';

  @override
  String get timerQuickRestDurationTitle => '设置休息时长';

  @override
  String get timerQuickDurationDescription => '新时长从下一轮开始生效。';

  @override
  String settingsMinutesValue(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String settingsSecondsValue(int seconds) {
    return '$seconds 秒';
  }

  @override
  String settingsEditValue(String setting) {
    return '调整 $setting';
  }

  @override
  String get validationWorkRange => '工作时长需在 1 至 180 分钟之间。';

  @override
  String get validationRestRange => '休息时长需在 10 至 600 秒之间。';

  @override
  String get validationReminderRange => '提醒间隔需在 1 至 30 分钟之间。';

  @override
  String get validationTimeoutRange => '超时时间需在 2 至 120 分钟之间。';

  @override
  String get validationTimeoutAfterInterval => '超时时间必须大于提醒间隔。';

  @override
  String get statisticsTitle => '统计';

  @override
  String get statisticsDatePickerTitle => '选择日期';

  @override
  String get statisticsRestDuration => '休息时长';

  @override
  String get statisticsRestCount => '完成休息';

  @override
  String get statisticsUnavailable => '暂时无法读取统计数据。';

  @override
  String get statisticsTimelineWork => '工作';

  @override
  String get statisticsTimelineRest => '休息';

  @override
  String get statisticsTimelineEmpty => '今天还没有可展示的工作或休息记录。';

  @override
  String get statisticsTimelineStart => '00:00';

  @override
  String get statisticsTimelineEnd => '24:00';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String countTimes(int count) {
    return '$count 次';
  }

  @override
  String get notificationPermissionTitle => '通知未开启';

  @override
  String get notificationPermissionMessage => '开启系统通知后，眸息才能在计时结束时提醒你。';

  @override
  String get notificationDegraded => '系统提醒暂不可用，应用会继续计时并在恢复后重试。';

  @override
  String get notificationWorkCompleteTitle => '该让眼睛休息了';

  @override
  String get notificationWorkCompleteBody => '休息一下有助于缓解眼睛和身体的疲劳，别让连续工作累积疲惫。';

  @override
  String get notificationRestReminderTitle => '别忘了休息眼睛';

  @override
  String get notificationRestReminderBody => '休息有助于缓解疲劳，现在开始休息，或跳过本轮提醒。';

  @override
  String get notificationRestCompleteTitle => '休息完成';

  @override
  String get notificationRestCompleteBody => '休息时间已到。';

  @override
  String get notificationActionStartRest => '开始休息';

  @override
  String get notificationActionSkipRest => '跳过';

  @override
  String get trayOpenApp => '打开';

  @override
  String get trayExitApp => '退出';

  @override
  String get notificationChannelName => '护眼提醒';

  @override
  String get notificationChannelDescription => '工作结束、休息提醒与休息完成通知';

  @override
  String get aboutTitle => '关于眸息';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get aboutGuidanceTitle => '20-20-20 护眼法';

  @override
  String get aboutGuidanceBody => '每工作 20 分钟，看向约 6 米外至少 20 秒。';

  @override
  String get aboutPrivacyTitle => '本地与隐私';

  @override
  String get aboutPrivacyBody => '眸息没有账号和云同步，设置与统计默认只保存在本机。';

  @override
  String get aboutRepositoryTitle => 'GitHub 仓库';

  @override
  String get aboutRepositoryBody => 'github.com/wzk-chi/RestEye';

  @override
  String get aboutRepositoryOpenFailed => '无法打开 GitHub 仓库。';

  @override
  String get bootstrapFailureTitle => '眸息暂时无法启动';

  @override
  String get bootstrapFailureMessage => '本地数据没有被删除。请重试，或退出后重新打开应用。';

  @override
  String accessibilityTimerProgress(int percent) {
    return '本轮计时进度 $percent%';
  }

  @override
  String accessibilityOpenSection(String section) {
    return '打开$section';
  }
}
