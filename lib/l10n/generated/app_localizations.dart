import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'眸息'**
  String get appTitle;

  /// No description provided for @appFullName.
  ///
  /// In zh, this message translates to:
  /// **'RestEye · 眸息'**
  String get appFullName;

  /// No description provided for @appTagline.
  ///
  /// In zh, this message translates to:
  /// **'轻松保持工作与休息节奏'**
  String get appTagline;

  /// No description provided for @navigationHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get navigationHome;

  /// No description provided for @navigationSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navigationSettings;

  /// No description provided for @navigationStatistics.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get navigationStatistics;

  /// No description provided for @navigationAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get navigationAbout;

  /// No description provided for @timerPhaseIdle.
  ///
  /// In zh, this message translates to:
  /// **'待开始'**
  String get timerPhaseIdle;

  /// No description provided for @timerPhaseWorking.
  ///
  /// In zh, this message translates to:
  /// **'专注中'**
  String get timerPhaseWorking;

  /// No description provided for @timerPhaseAwaitingRest.
  ///
  /// In zh, this message translates to:
  /// **'该休息了'**
  String get timerPhaseAwaitingRest;

  /// No description provided for @timerPhaseResting.
  ///
  /// In zh, this message translates to:
  /// **'休息中'**
  String get timerPhaseResting;

  /// No description provided for @timerPhaseSuspended.
  ///
  /// In zh, this message translates to:
  /// **'锁屏暂停中'**
  String get timerPhaseSuspended;

  /// No description provided for @timerIdleMessage.
  ///
  /// In zh, this message translates to:
  /// **'开始一轮工作，眸息会在合适的时候提醒你休息。'**
  String get timerIdleMessage;

  /// No description provided for @timerWorkingMessage.
  ///
  /// In zh, this message translates to:
  /// **'保持自然眨眼，坐姿放松。'**
  String get timerWorkingMessage;

  /// No description provided for @timerAwaitingRestMessage.
  ///
  /// In zh, this message translates to:
  /// **'适时休息有助于缓解眼睛和身体的疲劳，长时间连续工作容易让疲劳越积越多。'**
  String get timerAwaitingRestMessage;

  /// No description provided for @timerRestingMessage.
  ///
  /// In zh, this message translates to:
  /// **'离开屏幕，缓慢眨眼并放松肩颈。'**
  String get timerRestingMessage;

  /// No description provided for @timerSuspendedMessage.
  ///
  /// In zh, this message translates to:
  /// **'解锁后将继续本轮工作计时。'**
  String get timerSuspendedMessage;

  /// No description provided for @timerElapsedWork.
  ///
  /// In zh, this message translates to:
  /// **'已工作'**
  String get timerElapsedWork;

  /// No description provided for @timerElapsedWorkSemantics.
  ///
  /// In zh, this message translates to:
  /// **'{phase}，已工作 {time}'**
  String timerElapsedWorkSemantics(String phase, String time);

  /// No description provided for @timerElapsedRest.
  ///
  /// In zh, this message translates to:
  /// **'已休息'**
  String get timerElapsedRest;

  /// No description provided for @timerElapsedRestSemantics.
  ///
  /// In zh, this message translates to:
  /// **'{phase}，已休息 {time}'**
  String timerElapsedRestSemantics(String phase, String time);

  /// No description provided for @timerCurrentCycle.
  ///
  /// In zh, this message translates to:
  /// **'本轮设置'**
  String get timerCurrentCycle;

  /// No description provided for @timerWorkDuration.
  ///
  /// In zh, this message translates to:
  /// **'工作 {duration}'**
  String timerWorkDuration(String duration);

  /// No description provided for @timerRestDuration.
  ///
  /// In zh, this message translates to:
  /// **'休息 {duration}'**
  String timerRestDuration(String duration);

  /// No description provided for @actionStartWork.
  ///
  /// In zh, this message translates to:
  /// **'开始工作'**
  String get actionStartWork;

  /// No description provided for @actionResumeWork.
  ///
  /// In zh, this message translates to:
  /// **'继续工作'**
  String get actionResumeWork;

  /// No description provided for @actionStartRest.
  ///
  /// In zh, this message translates to:
  /// **'开始休息'**
  String get actionStartRest;

  /// No description provided for @actionSkipRest.
  ///
  /// In zh, this message translates to:
  /// **'跳过休息'**
  String get actionSkipRest;

  /// No description provided for @actionStopTimer.
  ///
  /// In zh, this message translates to:
  /// **'结束计时'**
  String get actionStopTimer;

  /// No description provided for @actionEndRest.
  ///
  /// In zh, this message translates to:
  /// **'结束休息'**
  String get actionEndRest;

  /// No description provided for @actionSave.
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get actionCancel;

  /// No description provided for @actionDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get actionRetry;

  /// No description provided for @actionExit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get actionExit;

  /// No description provided for @actionRequestPermission.
  ///
  /// In zh, this message translates to:
  /// **'开启通知'**
  String get actionRequestPermission;

  /// No description provided for @commandFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作未完成，请重试。'**
  String get commandFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsWorkDuration.
  ///
  /// In zh, this message translates to:
  /// **'工作时长'**
  String get settingsWorkDuration;

  /// No description provided for @settingsRestDuration.
  ///
  /// In zh, this message translates to:
  /// **'休息时长'**
  String get settingsRestDuration;

  /// No description provided for @settingsRestCompletionBehavior.
  ///
  /// In zh, this message translates to:
  /// **'休息结束后'**
  String get settingsRestCompletionBehavior;

  /// No description provided for @settingsRestCompletionStartWork.
  ///
  /// In zh, this message translates to:
  /// **'自动开始工作'**
  String get settingsRestCompletionStartWork;

  /// No description provided for @settingsRestCompletionStopTimer.
  ///
  /// In zh, this message translates to:
  /// **'结束计时'**
  String get settingsRestCompletionStopTimer;

  /// No description provided for @settingsRestCompletionContinueRest.
  ///
  /// In zh, this message translates to:
  /// **'继续休息'**
  String get settingsRestCompletionContinueRest;

  /// No description provided for @settingsWorkReminder.
  ///
  /// In zh, this message translates to:
  /// **'工作提醒'**
  String get settingsWorkReminder;

  /// No description provided for @settingsWorkReminderDescription.
  ///
  /// In zh, this message translates to:
  /// **'休息结束后提醒开始工作。'**
  String get settingsWorkReminderDescription;

  /// No description provided for @settingsRestReminder.
  ///
  /// In zh, this message translates to:
  /// **'休息提醒'**
  String get settingsRestReminder;

  /// No description provided for @settingsRestReminderDescription.
  ///
  /// In zh, this message translates to:
  /// **'工作结束后提醒开始休息。'**
  String get settingsRestReminderDescription;

  /// No description provided for @settingsMissedRestReminder.
  ///
  /// In zh, this message translates to:
  /// **'未休息重复提醒'**
  String get settingsMissedRestReminder;

  /// No description provided for @settingsMissedRestReminderDescription.
  ///
  /// In zh, this message translates to:
  /// **'未开始休息时，按设定间隔重复提醒。'**
  String get settingsMissedRestReminderDescription;

  /// No description provided for @settingsReminderInterval.
  ///
  /// In zh, this message translates to:
  /// **'未休息提醒间隔'**
  String get settingsReminderInterval;

  /// No description provided for @settingsReminderTimeout.
  ///
  /// In zh, this message translates to:
  /// **'未休息超时时间'**
  String get settingsReminderTimeout;

  /// No description provided for @settingsTimeoutBehavior.
  ///
  /// In zh, this message translates to:
  /// **'超时后处理'**
  String get settingsTimeoutBehavior;

  /// No description provided for @settingsTimeoutNextCycle.
  ///
  /// In zh, this message translates to:
  /// **'进入下一轮'**
  String get settingsTimeoutNextCycle;

  /// No description provided for @settingsTimeoutStopTimer.
  ///
  /// In zh, this message translates to:
  /// **'结束计时'**
  String get settingsTimeoutStopTimer;

  /// No description provided for @settingsVibration.
  ///
  /// In zh, this message translates to:
  /// **'Android 通知震动'**
  String get settingsVibration;

  /// No description provided for @settingsPauseWhenLocked.
  ///
  /// In zh, this message translates to:
  /// **'锁屏暂停计时'**
  String get settingsPauseWhenLocked;

  /// No description provided for @settingsPauseWhenLockedDescription.
  ///
  /// In zh, this message translates to:
  /// **'锁屏时暂停工作计时，解锁后继续。'**
  String get settingsPauseWhenLockedDescription;

  /// No description provided for @settingsAutoSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'自动保存失败，请重试。'**
  String get settingsAutoSaveFailed;

  /// No description provided for @settingsThemeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'显示语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsFixedPortrait.
  ///
  /// In zh, this message translates to:
  /// **'固定竖屏'**
  String get settingsFixedPortrait;

  /// No description provided for @settingsFixedPortraitDescription.
  ///
  /// In zh, this message translates to:
  /// **'锁定应用为竖屏显示。'**
  String get settingsFixedPortraitDescription;

  /// No description provided for @settingsMinimizeToTrayOnClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭时最小化到托盘'**
  String get settingsMinimizeToTrayOnClose;

  /// No description provided for @settingsMinimizeToTrayOnCloseDescription.
  ///
  /// In zh, this message translates to:
  /// **'关闭窗口后继续在后台运行，可从系统托盘重新打开。'**
  String get settingsMinimizeToTrayOnCloseDescription;

  /// No description provided for @settingsKeepInMenuBarOnClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭时保留在菜单栏'**
  String get settingsKeepInMenuBarOnClose;

  /// No description provided for @settingsKeepInMenuBarOnCloseDescription.
  ///
  /// In zh, this message translates to:
  /// **'关闭窗口后继续在后台运行，可从菜单栏重新打开。'**
  String get settingsKeepInMenuBarOnCloseDescription;

  /// No description provided for @timerQuickWorkDurationTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置工作时长'**
  String get timerQuickWorkDurationTitle;

  /// No description provided for @timerQuickRestDurationTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置休息时长'**
  String get timerQuickRestDurationTitle;

  /// No description provided for @timerQuickDurationDescription.
  ///
  /// In zh, this message translates to:
  /// **'新时长从下一轮开始生效。'**
  String get timerQuickDurationDescription;

  /// No description provided for @settingsMinutesValue.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟'**
  String settingsMinutesValue(int minutes);

  /// No description provided for @settingsSecondsValue.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒'**
  String settingsSecondsValue(int seconds);

  /// No description provided for @settingsEditValue.
  ///
  /// In zh, this message translates to:
  /// **'调整 {setting}'**
  String settingsEditValue(String setting);

  /// No description provided for @validationWorkRange.
  ///
  /// In zh, this message translates to:
  /// **'工作时长需在 1 至 180 分钟之间。'**
  String get validationWorkRange;

  /// No description provided for @validationRestRange.
  ///
  /// In zh, this message translates to:
  /// **'休息时长需在 10 至 600 秒之间。'**
  String get validationRestRange;

  /// No description provided for @validationReminderRange.
  ///
  /// In zh, this message translates to:
  /// **'提醒间隔需在 1 至 30 分钟之间。'**
  String get validationReminderRange;

  /// No description provided for @validationTimeoutRange.
  ///
  /// In zh, this message translates to:
  /// **'超时时间需在 2 至 120 分钟之间。'**
  String get validationTimeoutRange;

  /// No description provided for @validationTimeoutAfterInterval.
  ///
  /// In zh, this message translates to:
  /// **'超时时间必须大于提醒间隔。'**
  String get validationTimeoutAfterInterval;

  /// No description provided for @statisticsTitle.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get statisticsTitle;

  /// No description provided for @statisticsDatePickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get statisticsDatePickerTitle;

  /// No description provided for @statisticsRestDuration.
  ///
  /// In zh, this message translates to:
  /// **'休息时长'**
  String get statisticsRestDuration;

  /// No description provided for @statisticsRestCount.
  ///
  /// In zh, this message translates to:
  /// **'完成休息'**
  String get statisticsRestCount;

  /// No description provided for @statisticsUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法读取统计数据。'**
  String get statisticsUnavailable;

  /// No description provided for @statisticsTimelineWork.
  ///
  /// In zh, this message translates to:
  /// **'工作'**
  String get statisticsTimelineWork;

  /// No description provided for @statisticsTimelineRest.
  ///
  /// In zh, this message translates to:
  /// **'休息'**
  String get statisticsTimelineRest;

  /// No description provided for @statisticsTimelineEmpty.
  ///
  /// In zh, this message translates to:
  /// **'今天还没有可展示的工作或休息记录。'**
  String get statisticsTimelineEmpty;

  /// No description provided for @statisticsTimelineStart.
  ///
  /// In zh, this message translates to:
  /// **'00:00'**
  String get statisticsTimelineStart;

  /// No description provided for @statisticsTimelineEnd.
  ///
  /// In zh, this message translates to:
  /// **'24:00'**
  String get statisticsTimelineEnd;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{hours} 小时 {minutes} 分钟'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟'**
  String durationMinutes(int minutes);

  /// No description provided for @durationSeconds.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒'**
  String durationSeconds(int seconds);

  /// No description provided for @countTimes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String countTimes(int count);

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知未开启'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In zh, this message translates to:
  /// **'开启系统通知后，眸息才能在计时结束时提醒你。'**
  String get notificationPermissionMessage;

  /// No description provided for @notificationDegraded.
  ///
  /// In zh, this message translates to:
  /// **'系统提醒暂不可用，应用会继续计时并在恢复后重试。'**
  String get notificationDegraded;

  /// No description provided for @notificationWorkCompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'该让眼睛休息了'**
  String get notificationWorkCompleteTitle;

  /// No description provided for @notificationWorkCompleteBody.
  ///
  /// In zh, this message translates to:
  /// **'休息一下有助于缓解眼睛和身体的疲劳，别让连续工作累积疲惫。'**
  String get notificationWorkCompleteBody;

  /// No description provided for @notificationRestReminderTitle.
  ///
  /// In zh, this message translates to:
  /// **'别忘了休息眼睛'**
  String get notificationRestReminderTitle;

  /// No description provided for @notificationRestReminderBody.
  ///
  /// In zh, this message translates to:
  /// **'休息有助于缓解疲劳，现在开始休息，或跳过本轮提醒。'**
  String get notificationRestReminderBody;

  /// No description provided for @notificationRestCompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'休息完成'**
  String get notificationRestCompleteTitle;

  /// No description provided for @notificationRestCompleteBody.
  ///
  /// In zh, this message translates to:
  /// **'休息时间已到。'**
  String get notificationRestCompleteBody;

  /// No description provided for @notificationActionStartRest.
  ///
  /// In zh, this message translates to:
  /// **'开始休息'**
  String get notificationActionStartRest;

  /// No description provided for @notificationActionSkipRest.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get notificationActionSkipRest;

  /// No description provided for @trayOpenApp.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get trayOpenApp;

  /// No description provided for @trayExitApp.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get trayExitApp;

  /// No description provided for @notificationChannelName.
  ///
  /// In zh, this message translates to:
  /// **'护眼提醒'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In zh, this message translates to:
  /// **'工作结束、休息提醒与休息完成通知'**
  String get notificationChannelDescription;

  /// No description provided for @aboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于眸息'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutGuidanceTitle.
  ///
  /// In zh, this message translates to:
  /// **'20-20-20 护眼法'**
  String get aboutGuidanceTitle;

  /// No description provided for @aboutGuidanceBody.
  ///
  /// In zh, this message translates to:
  /// **'每工作 20 分钟，看向约 6 米外至少 20 秒。'**
  String get aboutGuidanceBody;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'本地与隐私'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In zh, this message translates to:
  /// **'眸息没有账号和云同步，设置与统计默认只保存在本机。'**
  String get aboutPrivacyBody;

  /// No description provided for @aboutRepositoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 仓库'**
  String get aboutRepositoryTitle;

  /// No description provided for @aboutRepositoryBody.
  ///
  /// In zh, this message translates to:
  /// **'github.com/wzk-chi/RestEye'**
  String get aboutRepositoryBody;

  /// No description provided for @aboutRepositoryOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开 GitHub 仓库。'**
  String get aboutRepositoryOpenFailed;

  /// No description provided for @bootstrapFailureTitle.
  ///
  /// In zh, this message translates to:
  /// **'眸息暂时无法启动'**
  String get bootstrapFailureTitle;

  /// No description provided for @bootstrapFailureMessage.
  ///
  /// In zh, this message translates to:
  /// **'本地数据没有被删除。请重试，或退出后重新打开应用。'**
  String get bootstrapFailureMessage;

  /// No description provided for @accessibilityTimerProgress.
  ///
  /// In zh, this message translates to:
  /// **'本轮计时进度 {percent}%'**
  String accessibilityTimerProgress(int percent);

  /// No description provided for @accessibilityOpenSection.
  ///
  /// In zh, this message translates to:
  /// **'打开{section}'**
  String accessibilityOpenSection(String section);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
