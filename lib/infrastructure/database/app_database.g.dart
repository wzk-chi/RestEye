// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _workDurationMsMeta = const VerificationMeta(
    'workDurationMs',
  );
  @override
  late final GeneratedColumn<int> workDurationMs = GeneratedColumn<int>(
    'work_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restDurationMsMeta = const VerificationMeta(
    'restDurationMs',
  );
  @override
  late final GeneratedColumn<int> restDurationMs = GeneratedColumn<int>(
    'rest_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIntervalMsMeta =
      const VerificationMeta('reminderIntervalMs');
  @override
  late final GeneratedColumn<int> reminderIntervalMs = GeneratedColumn<int>(
    'reminder_interval_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTimeoutMsMeta = const VerificationMeta(
    'reminderTimeoutMs',
  );
  @override
  late final GeneratedColumn<int> reminderTimeoutMs = GeneratedColumn<int>(
    'reminder_timeout_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _androidVibrationEnabledMeta =
      const VerificationMeta('androidVibrationEnabled');
  @override
  late final GeneratedColumn<bool> androidVibrationEnabled =
      GeneratedColumn<bool>(
        'android_vibration_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("android_vibration_enabled" IN (0, 1))',
        ),
      );
  static const VerificationMeta _workReminderEnabledMeta =
      const VerificationMeta('workReminderEnabled');
  @override
  late final GeneratedColumn<bool> workReminderEnabled = GeneratedColumn<bool>(
    'work_reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("work_reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _restReminderEnabledMeta =
      const VerificationMeta('restReminderEnabled');
  @override
  late final GeneratedColumn<bool> restReminderEnabled = GeneratedColumn<bool>(
    'rest_reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rest_reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _missedRestReminderEnabledMeta =
      const VerificationMeta('missedRestReminderEnabled');
  @override
  late final GeneratedColumn<bool> missedRestReminderEnabled =
      GeneratedColumn<bool>(
        'missed_rest_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("missed_rest_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeCodeMeta = const VerificationMeta(
    'themeModeCode',
  );
  @override
  late final GeneratedColumn<String> themeModeCode = GeneratedColumn<String>(
    'theme_mode_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pauseWhenLockedMeta = const VerificationMeta(
    'pauseWhenLocked',
  );
  @override
  late final GeneratedColumn<bool> pauseWhenLocked = GeneratedColumn<bool>(
    'pause_when_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pause_when_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fixedPortraitEnabledMeta =
      const VerificationMeta('fixedPortraitEnabled');
  @override
  late final GeneratedColumn<bool> fixedPortraitEnabled = GeneratedColumn<bool>(
    'fixed_portrait_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fixed_portrait_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _minimizeToTrayOnCloseMeta =
      const VerificationMeta('minimizeToTrayOnClose');
  @override
  late final GeneratedColumn<bool> minimizeToTrayOnClose =
      GeneratedColumn<bool>(
        'minimize_to_tray_on_close',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("minimize_to_tray_on_close" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _timeoutBehaviorMeta = const VerificationMeta(
    'timeoutBehavior',
  );
  @override
  late final GeneratedColumn<String> timeoutBehavior = GeneratedColumn<String>(
    'timeout_behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nextCycle'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workDurationMs,
    restDurationMs,
    reminderIntervalMs,
    reminderTimeoutMs,
    androidVibrationEnabled,
    workReminderEnabled,
    restReminderEnabled,
    missedRestReminderEnabled,
    localeCode,
    themeModeCode,
    pauseWhenLocked,
    fixedPortraitEnabled,
    minimizeToTrayOnClose,
    timeoutBehavior,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('work_duration_ms')) {
      context.handle(
        _workDurationMsMeta,
        workDurationMs.isAcceptableOrUnknown(
          data['work_duration_ms']!,
          _workDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workDurationMsMeta);
    }
    if (data.containsKey('rest_duration_ms')) {
      context.handle(
        _restDurationMsMeta,
        restDurationMs.isAcceptableOrUnknown(
          data['rest_duration_ms']!,
          _restDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restDurationMsMeta);
    }
    if (data.containsKey('reminder_interval_ms')) {
      context.handle(
        _reminderIntervalMsMeta,
        reminderIntervalMs.isAcceptableOrUnknown(
          data['reminder_interval_ms']!,
          _reminderIntervalMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderIntervalMsMeta);
    }
    if (data.containsKey('reminder_timeout_ms')) {
      context.handle(
        _reminderTimeoutMsMeta,
        reminderTimeoutMs.isAcceptableOrUnknown(
          data['reminder_timeout_ms']!,
          _reminderTimeoutMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTimeoutMsMeta);
    }
    if (data.containsKey('android_vibration_enabled')) {
      context.handle(
        _androidVibrationEnabledMeta,
        androidVibrationEnabled.isAcceptableOrUnknown(
          data['android_vibration_enabled']!,
          _androidVibrationEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_androidVibrationEnabledMeta);
    }
    if (data.containsKey('work_reminder_enabled')) {
      context.handle(
        _workReminderEnabledMeta,
        workReminderEnabled.isAcceptableOrUnknown(
          data['work_reminder_enabled']!,
          _workReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('rest_reminder_enabled')) {
      context.handle(
        _restReminderEnabledMeta,
        restReminderEnabled.isAcceptableOrUnknown(
          data['rest_reminder_enabled']!,
          _restReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('missed_rest_reminder_enabled')) {
      context.handle(
        _missedRestReminderEnabledMeta,
        missedRestReminderEnabled.isAcceptableOrUnknown(
          data['missed_rest_reminder_enabled']!,
          _missedRestReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeCodeMeta);
    }
    if (data.containsKey('theme_mode_code')) {
      context.handle(
        _themeModeCodeMeta,
        themeModeCode.isAcceptableOrUnknown(
          data['theme_mode_code']!,
          _themeModeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_themeModeCodeMeta);
    }
    if (data.containsKey('pause_when_locked')) {
      context.handle(
        _pauseWhenLockedMeta,
        pauseWhenLocked.isAcceptableOrUnknown(
          data['pause_when_locked']!,
          _pauseWhenLockedMeta,
        ),
      );
    }
    if (data.containsKey('fixed_portrait_enabled')) {
      context.handle(
        _fixedPortraitEnabledMeta,
        fixedPortraitEnabled.isAcceptableOrUnknown(
          data['fixed_portrait_enabled']!,
          _fixedPortraitEnabledMeta,
        ),
      );
    }
    if (data.containsKey('minimize_to_tray_on_close')) {
      context.handle(
        _minimizeToTrayOnCloseMeta,
        minimizeToTrayOnClose.isAcceptableOrUnknown(
          data['minimize_to_tray_on_close']!,
          _minimizeToTrayOnCloseMeta,
        ),
      );
    }
    if (data.containsKey('timeout_behavior')) {
      context.handle(
        _timeoutBehaviorMeta,
        timeoutBehavior.isAcceptableOrUnknown(
          data['timeout_behavior']!,
          _timeoutBehaviorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_duration_ms'],
      )!,
      restDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_ms'],
      )!,
      reminderIntervalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_ms'],
      )!,
      reminderTimeoutMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_timeout_ms'],
      )!,
      androidVibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}android_vibration_enabled'],
      )!,
      workReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}work_reminder_enabled'],
      )!,
      restReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rest_reminder_enabled'],
      )!,
      missedRestReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}missed_rest_reminder_enabled'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      themeModeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode_code'],
      )!,
      pauseWhenLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pause_when_locked'],
      )!,
      fixedPortraitEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fixed_portrait_enabled'],
      )!,
      minimizeToTrayOnClose: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}minimize_to_tray_on_close'],
      )!,
      timeoutBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeout_behavior'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final int workDurationMs;
  final int restDurationMs;
  final int reminderIntervalMs;
  final int reminderTimeoutMs;
  final bool androidVibrationEnabled;
  final bool workReminderEnabled;
  final bool restReminderEnabled;
  final bool missedRestReminderEnabled;
  final String localeCode;
  final String themeModeCode;
  final bool pauseWhenLocked;
  final bool fixedPortraitEnabled;
  final bool minimizeToTrayOnClose;
  final String timeoutBehavior;
  const AppSettingsRow({
    required this.id,
    required this.workDurationMs,
    required this.restDurationMs,
    required this.reminderIntervalMs,
    required this.reminderTimeoutMs,
    required this.androidVibrationEnabled,
    required this.workReminderEnabled,
    required this.restReminderEnabled,
    required this.missedRestReminderEnabled,
    required this.localeCode,
    required this.themeModeCode,
    required this.pauseWhenLocked,
    required this.fixedPortraitEnabled,
    required this.minimizeToTrayOnClose,
    required this.timeoutBehavior,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['work_duration_ms'] = Variable<int>(workDurationMs);
    map['rest_duration_ms'] = Variable<int>(restDurationMs);
    map['reminder_interval_ms'] = Variable<int>(reminderIntervalMs);
    map['reminder_timeout_ms'] = Variable<int>(reminderTimeoutMs);
    map['android_vibration_enabled'] = Variable<bool>(androidVibrationEnabled);
    map['work_reminder_enabled'] = Variable<bool>(workReminderEnabled);
    map['rest_reminder_enabled'] = Variable<bool>(restReminderEnabled);
    map['missed_rest_reminder_enabled'] = Variable<bool>(
      missedRestReminderEnabled,
    );
    map['locale_code'] = Variable<String>(localeCode);
    map['theme_mode_code'] = Variable<String>(themeModeCode);
    map['pause_when_locked'] = Variable<bool>(pauseWhenLocked);
    map['fixed_portrait_enabled'] = Variable<bool>(fixedPortraitEnabled);
    map['minimize_to_tray_on_close'] = Variable<bool>(minimizeToTrayOnClose);
    map['timeout_behavior'] = Variable<String>(timeoutBehavior);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      workDurationMs: Value(workDurationMs),
      restDurationMs: Value(restDurationMs),
      reminderIntervalMs: Value(reminderIntervalMs),
      reminderTimeoutMs: Value(reminderTimeoutMs),
      androidVibrationEnabled: Value(androidVibrationEnabled),
      workReminderEnabled: Value(workReminderEnabled),
      restReminderEnabled: Value(restReminderEnabled),
      missedRestReminderEnabled: Value(missedRestReminderEnabled),
      localeCode: Value(localeCode),
      themeModeCode: Value(themeModeCode),
      pauseWhenLocked: Value(pauseWhenLocked),
      fixedPortraitEnabled: Value(fixedPortraitEnabled),
      minimizeToTrayOnClose: Value(minimizeToTrayOnClose),
      timeoutBehavior: Value(timeoutBehavior),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      workDurationMs: serializer.fromJson<int>(json['workDurationMs']),
      restDurationMs: serializer.fromJson<int>(json['restDurationMs']),
      reminderIntervalMs: serializer.fromJson<int>(json['reminderIntervalMs']),
      reminderTimeoutMs: serializer.fromJson<int>(json['reminderTimeoutMs']),
      androidVibrationEnabled: serializer.fromJson<bool>(
        json['androidVibrationEnabled'],
      ),
      workReminderEnabled: serializer.fromJson<bool>(
        json['workReminderEnabled'],
      ),
      restReminderEnabled: serializer.fromJson<bool>(
        json['restReminderEnabled'],
      ),
      missedRestReminderEnabled: serializer.fromJson<bool>(
        json['missedRestReminderEnabled'],
      ),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      themeModeCode: serializer.fromJson<String>(json['themeModeCode']),
      pauseWhenLocked: serializer.fromJson<bool>(json['pauseWhenLocked']),
      fixedPortraitEnabled: serializer.fromJson<bool>(
        json['fixedPortraitEnabled'],
      ),
      minimizeToTrayOnClose: serializer.fromJson<bool>(
        json['minimizeToTrayOnClose'],
      ),
      timeoutBehavior: serializer.fromJson<String>(json['timeoutBehavior']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workDurationMs': serializer.toJson<int>(workDurationMs),
      'restDurationMs': serializer.toJson<int>(restDurationMs),
      'reminderIntervalMs': serializer.toJson<int>(reminderIntervalMs),
      'reminderTimeoutMs': serializer.toJson<int>(reminderTimeoutMs),
      'androidVibrationEnabled': serializer.toJson<bool>(
        androidVibrationEnabled,
      ),
      'workReminderEnabled': serializer.toJson<bool>(workReminderEnabled),
      'restReminderEnabled': serializer.toJson<bool>(restReminderEnabled),
      'missedRestReminderEnabled': serializer.toJson<bool>(
        missedRestReminderEnabled,
      ),
      'localeCode': serializer.toJson<String>(localeCode),
      'themeModeCode': serializer.toJson<String>(themeModeCode),
      'pauseWhenLocked': serializer.toJson<bool>(pauseWhenLocked),
      'fixedPortraitEnabled': serializer.toJson<bool>(fixedPortraitEnabled),
      'minimizeToTrayOnClose': serializer.toJson<bool>(minimizeToTrayOnClose),
      'timeoutBehavior': serializer.toJson<String>(timeoutBehavior),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    int? workDurationMs,
    int? restDurationMs,
    int? reminderIntervalMs,
    int? reminderTimeoutMs,
    bool? androidVibrationEnabled,
    bool? workReminderEnabled,
    bool? restReminderEnabled,
    bool? missedRestReminderEnabled,
    String? localeCode,
    String? themeModeCode,
    bool? pauseWhenLocked,
    bool? fixedPortraitEnabled,
    bool? minimizeToTrayOnClose,
    String? timeoutBehavior,
  }) => AppSettingsRow(
    id: id ?? this.id,
    workDurationMs: workDurationMs ?? this.workDurationMs,
    restDurationMs: restDurationMs ?? this.restDurationMs,
    reminderIntervalMs: reminderIntervalMs ?? this.reminderIntervalMs,
    reminderTimeoutMs: reminderTimeoutMs ?? this.reminderTimeoutMs,
    androidVibrationEnabled:
        androidVibrationEnabled ?? this.androidVibrationEnabled,
    workReminderEnabled: workReminderEnabled ?? this.workReminderEnabled,
    restReminderEnabled: restReminderEnabled ?? this.restReminderEnabled,
    missedRestReminderEnabled:
        missedRestReminderEnabled ?? this.missedRestReminderEnabled,
    localeCode: localeCode ?? this.localeCode,
    themeModeCode: themeModeCode ?? this.themeModeCode,
    pauseWhenLocked: pauseWhenLocked ?? this.pauseWhenLocked,
    fixedPortraitEnabled: fixedPortraitEnabled ?? this.fixedPortraitEnabled,
    minimizeToTrayOnClose: minimizeToTrayOnClose ?? this.minimizeToTrayOnClose,
    timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
  );
  AppSettingsRow copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      workDurationMs: data.workDurationMs.present
          ? data.workDurationMs.value
          : this.workDurationMs,
      restDurationMs: data.restDurationMs.present
          ? data.restDurationMs.value
          : this.restDurationMs,
      reminderIntervalMs: data.reminderIntervalMs.present
          ? data.reminderIntervalMs.value
          : this.reminderIntervalMs,
      reminderTimeoutMs: data.reminderTimeoutMs.present
          ? data.reminderTimeoutMs.value
          : this.reminderTimeoutMs,
      androidVibrationEnabled: data.androidVibrationEnabled.present
          ? data.androidVibrationEnabled.value
          : this.androidVibrationEnabled,
      workReminderEnabled: data.workReminderEnabled.present
          ? data.workReminderEnabled.value
          : this.workReminderEnabled,
      restReminderEnabled: data.restReminderEnabled.present
          ? data.restReminderEnabled.value
          : this.restReminderEnabled,
      missedRestReminderEnabled: data.missedRestReminderEnabled.present
          ? data.missedRestReminderEnabled.value
          : this.missedRestReminderEnabled,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      themeModeCode: data.themeModeCode.present
          ? data.themeModeCode.value
          : this.themeModeCode,
      pauseWhenLocked: data.pauseWhenLocked.present
          ? data.pauseWhenLocked.value
          : this.pauseWhenLocked,
      fixedPortraitEnabled: data.fixedPortraitEnabled.present
          ? data.fixedPortraitEnabled.value
          : this.fixedPortraitEnabled,
      minimizeToTrayOnClose: data.minimizeToTrayOnClose.present
          ? data.minimizeToTrayOnClose.value
          : this.minimizeToTrayOnClose,
      timeoutBehavior: data.timeoutBehavior.present
          ? data.timeoutBehavior.value
          : this.timeoutBehavior,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('workDurationMs: $workDurationMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('reminderIntervalMs: $reminderIntervalMs, ')
          ..write('reminderTimeoutMs: $reminderTimeoutMs, ')
          ..write('androidVibrationEnabled: $androidVibrationEnabled, ')
          ..write('workReminderEnabled: $workReminderEnabled, ')
          ..write('restReminderEnabled: $restReminderEnabled, ')
          ..write('missedRestReminderEnabled: $missedRestReminderEnabled, ')
          ..write('localeCode: $localeCode, ')
          ..write('themeModeCode: $themeModeCode, ')
          ..write('pauseWhenLocked: $pauseWhenLocked, ')
          ..write('fixedPortraitEnabled: $fixedPortraitEnabled, ')
          ..write('minimizeToTrayOnClose: $minimizeToTrayOnClose, ')
          ..write('timeoutBehavior: $timeoutBehavior')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workDurationMs,
    restDurationMs,
    reminderIntervalMs,
    reminderTimeoutMs,
    androidVibrationEnabled,
    workReminderEnabled,
    restReminderEnabled,
    missedRestReminderEnabled,
    localeCode,
    themeModeCode,
    pauseWhenLocked,
    fixedPortraitEnabled,
    minimizeToTrayOnClose,
    timeoutBehavior,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.workDurationMs == this.workDurationMs &&
          other.restDurationMs == this.restDurationMs &&
          other.reminderIntervalMs == this.reminderIntervalMs &&
          other.reminderTimeoutMs == this.reminderTimeoutMs &&
          other.androidVibrationEnabled == this.androidVibrationEnabled &&
          other.workReminderEnabled == this.workReminderEnabled &&
          other.restReminderEnabled == this.restReminderEnabled &&
          other.missedRestReminderEnabled == this.missedRestReminderEnabled &&
          other.localeCode == this.localeCode &&
          other.themeModeCode == this.themeModeCode &&
          other.pauseWhenLocked == this.pauseWhenLocked &&
          other.fixedPortraitEnabled == this.fixedPortraitEnabled &&
          other.minimizeToTrayOnClose == this.minimizeToTrayOnClose &&
          other.timeoutBehavior == this.timeoutBehavior);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> workDurationMs;
  final Value<int> restDurationMs;
  final Value<int> reminderIntervalMs;
  final Value<int> reminderTimeoutMs;
  final Value<bool> androidVibrationEnabled;
  final Value<bool> workReminderEnabled;
  final Value<bool> restReminderEnabled;
  final Value<bool> missedRestReminderEnabled;
  final Value<String> localeCode;
  final Value<String> themeModeCode;
  final Value<bool> pauseWhenLocked;
  final Value<bool> fixedPortraitEnabled;
  final Value<bool> minimizeToTrayOnClose;
  final Value<String> timeoutBehavior;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.workDurationMs = const Value.absent(),
    this.restDurationMs = const Value.absent(),
    this.reminderIntervalMs = const Value.absent(),
    this.reminderTimeoutMs = const Value.absent(),
    this.androidVibrationEnabled = const Value.absent(),
    this.workReminderEnabled = const Value.absent(),
    this.restReminderEnabled = const Value.absent(),
    this.missedRestReminderEnabled = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.themeModeCode = const Value.absent(),
    this.pauseWhenLocked = const Value.absent(),
    this.fixedPortraitEnabled = const Value.absent(),
    this.minimizeToTrayOnClose = const Value.absent(),
    this.timeoutBehavior = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int workDurationMs,
    required int restDurationMs,
    required int reminderIntervalMs,
    required int reminderTimeoutMs,
    required bool androidVibrationEnabled,
    this.workReminderEnabled = const Value.absent(),
    this.restReminderEnabled = const Value.absent(),
    this.missedRestReminderEnabled = const Value.absent(),
    required String localeCode,
    required String themeModeCode,
    this.pauseWhenLocked = const Value.absent(),
    this.fixedPortraitEnabled = const Value.absent(),
    this.minimizeToTrayOnClose = const Value.absent(),
    this.timeoutBehavior = const Value.absent(),
  }) : workDurationMs = Value(workDurationMs),
       restDurationMs = Value(restDurationMs),
       reminderIntervalMs = Value(reminderIntervalMs),
       reminderTimeoutMs = Value(reminderTimeoutMs),
       androidVibrationEnabled = Value(androidVibrationEnabled),
       localeCode = Value(localeCode),
       themeModeCode = Value(themeModeCode);
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? workDurationMs,
    Expression<int>? restDurationMs,
    Expression<int>? reminderIntervalMs,
    Expression<int>? reminderTimeoutMs,
    Expression<bool>? androidVibrationEnabled,
    Expression<bool>? workReminderEnabled,
    Expression<bool>? restReminderEnabled,
    Expression<bool>? missedRestReminderEnabled,
    Expression<String>? localeCode,
    Expression<String>? themeModeCode,
    Expression<bool>? pauseWhenLocked,
    Expression<bool>? fixedPortraitEnabled,
    Expression<bool>? minimizeToTrayOnClose,
    Expression<String>? timeoutBehavior,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workDurationMs != null) 'work_duration_ms': workDurationMs,
      if (restDurationMs != null) 'rest_duration_ms': restDurationMs,
      if (reminderIntervalMs != null)
        'reminder_interval_ms': reminderIntervalMs,
      if (reminderTimeoutMs != null) 'reminder_timeout_ms': reminderTimeoutMs,
      if (androidVibrationEnabled != null)
        'android_vibration_enabled': androidVibrationEnabled,
      if (workReminderEnabled != null)
        'work_reminder_enabled': workReminderEnabled,
      if (restReminderEnabled != null)
        'rest_reminder_enabled': restReminderEnabled,
      if (missedRestReminderEnabled != null)
        'missed_rest_reminder_enabled': missedRestReminderEnabled,
      if (localeCode != null) 'locale_code': localeCode,
      if (themeModeCode != null) 'theme_mode_code': themeModeCode,
      if (pauseWhenLocked != null) 'pause_when_locked': pauseWhenLocked,
      if (fixedPortraitEnabled != null)
        'fixed_portrait_enabled': fixedPortraitEnabled,
      if (minimizeToTrayOnClose != null)
        'minimize_to_tray_on_close': minimizeToTrayOnClose,
      if (timeoutBehavior != null) 'timeout_behavior': timeoutBehavior,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? workDurationMs,
    Value<int>? restDurationMs,
    Value<int>? reminderIntervalMs,
    Value<int>? reminderTimeoutMs,
    Value<bool>? androidVibrationEnabled,
    Value<bool>? workReminderEnabled,
    Value<bool>? restReminderEnabled,
    Value<bool>? missedRestReminderEnabled,
    Value<String>? localeCode,
    Value<String>? themeModeCode,
    Value<bool>? pauseWhenLocked,
    Value<bool>? fixedPortraitEnabled,
    Value<bool>? minimizeToTrayOnClose,
    Value<String>? timeoutBehavior,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      workDurationMs: workDurationMs ?? this.workDurationMs,
      restDurationMs: restDurationMs ?? this.restDurationMs,
      reminderIntervalMs: reminderIntervalMs ?? this.reminderIntervalMs,
      reminderTimeoutMs: reminderTimeoutMs ?? this.reminderTimeoutMs,
      androidVibrationEnabled:
          androidVibrationEnabled ?? this.androidVibrationEnabled,
      workReminderEnabled: workReminderEnabled ?? this.workReminderEnabled,
      restReminderEnabled: restReminderEnabled ?? this.restReminderEnabled,
      missedRestReminderEnabled:
          missedRestReminderEnabled ?? this.missedRestReminderEnabled,
      localeCode: localeCode ?? this.localeCode,
      themeModeCode: themeModeCode ?? this.themeModeCode,
      pauseWhenLocked: pauseWhenLocked ?? this.pauseWhenLocked,
      fixedPortraitEnabled: fixedPortraitEnabled ?? this.fixedPortraitEnabled,
      minimizeToTrayOnClose:
          minimizeToTrayOnClose ?? this.minimizeToTrayOnClose,
      timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workDurationMs.present) {
      map['work_duration_ms'] = Variable<int>(workDurationMs.value);
    }
    if (restDurationMs.present) {
      map['rest_duration_ms'] = Variable<int>(restDurationMs.value);
    }
    if (reminderIntervalMs.present) {
      map['reminder_interval_ms'] = Variable<int>(reminderIntervalMs.value);
    }
    if (reminderTimeoutMs.present) {
      map['reminder_timeout_ms'] = Variable<int>(reminderTimeoutMs.value);
    }
    if (androidVibrationEnabled.present) {
      map['android_vibration_enabled'] = Variable<bool>(
        androidVibrationEnabled.value,
      );
    }
    if (workReminderEnabled.present) {
      map['work_reminder_enabled'] = Variable<bool>(workReminderEnabled.value);
    }
    if (restReminderEnabled.present) {
      map['rest_reminder_enabled'] = Variable<bool>(restReminderEnabled.value);
    }
    if (missedRestReminderEnabled.present) {
      map['missed_rest_reminder_enabled'] = Variable<bool>(
        missedRestReminderEnabled.value,
      );
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (themeModeCode.present) {
      map['theme_mode_code'] = Variable<String>(themeModeCode.value);
    }
    if (pauseWhenLocked.present) {
      map['pause_when_locked'] = Variable<bool>(pauseWhenLocked.value);
    }
    if (fixedPortraitEnabled.present) {
      map['fixed_portrait_enabled'] = Variable<bool>(
        fixedPortraitEnabled.value,
      );
    }
    if (minimizeToTrayOnClose.present) {
      map['minimize_to_tray_on_close'] = Variable<bool>(
        minimizeToTrayOnClose.value,
      );
    }
    if (timeoutBehavior.present) {
      map['timeout_behavior'] = Variable<String>(timeoutBehavior.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('workDurationMs: $workDurationMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('reminderIntervalMs: $reminderIntervalMs, ')
          ..write('reminderTimeoutMs: $reminderTimeoutMs, ')
          ..write('androidVibrationEnabled: $androidVibrationEnabled, ')
          ..write('workReminderEnabled: $workReminderEnabled, ')
          ..write('restReminderEnabled: $restReminderEnabled, ')
          ..write('missedRestReminderEnabled: $missedRestReminderEnabled, ')
          ..write('localeCode: $localeCode, ')
          ..write('themeModeCode: $themeModeCode, ')
          ..write('pauseWhenLocked: $pauseWhenLocked, ')
          ..write('fixedPortraitEnabled: $fixedPortraitEnabled, ')
          ..write('minimizeToTrayOnClose: $minimizeToTrayOnClose, ')
          ..write('timeoutBehavior: $timeoutBehavior')
          ..write(')'))
        .toString();
  }
}

class $TimerSnapshotsTableTable extends TimerSnapshotsTable
    with TableInfo<$TimerSnapshotsTableTable, TimerSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerSnapshotsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _executionStatusMeta = const VerificationMeta(
    'executionStatus',
  );
  @override
  late final GeneratedColumn<String> executionStatus = GeneratedColumn<String>(
    'execution_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineAtUtcMeta = const VerificationMeta(
    'deadlineAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAtUtc =
      GeneratedColumn<DateTime>(
        'deadline_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextReminderAtUtcMeta = const VerificationMeta(
    'nextReminderAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> nextReminderAtUtc =
      GeneratedColumn<DateTime>(
        'next_reminder_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _workDurationMsMeta = const VerificationMeta(
    'workDurationMs',
  );
  @override
  late final GeneratedColumn<int> workDurationMs = GeneratedColumn<int>(
    'work_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restDurationMsMeta = const VerificationMeta(
    'restDurationMs',
  );
  @override
  late final GeneratedColumn<int> restDurationMs = GeneratedColumn<int>(
    'rest_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIntervalMsMeta =
      const VerificationMeta('reminderIntervalMs');
  @override
  late final GeneratedColumn<int> reminderIntervalMs = GeneratedColumn<int>(
    'reminder_interval_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTimeoutMsMeta = const VerificationMeta(
    'reminderTimeoutMs',
  );
  @override
  late final GeneratedColumn<int> reminderTimeoutMs = GeneratedColumn<int>(
    'reminder_timeout_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeoutBehaviorMeta = const VerificationMeta(
    'timeoutBehavior',
  );
  @override
  late final GeneratedColumn<String> timeoutBehavior = GeneratedColumn<String>(
    'timeout_behavior',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nextCycle'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    revision,
    phase,
    executionStatus,
    startedAtUtc,
    deadlineAtUtc,
    nextReminderAtUtc,
    workDurationMs,
    restDurationMs,
    reminderIntervalMs,
    reminderTimeoutMs,
    timeoutBehavior,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_snapshots_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('execution_status')) {
      context.handle(
        _executionStatusMeta,
        executionStatus.isAcceptableOrUnknown(
          data['execution_status']!,
          _executionStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_executionStatusMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('deadline_at_utc')) {
      context.handle(
        _deadlineAtUtcMeta,
        deadlineAtUtc.isAcceptableOrUnknown(
          data['deadline_at_utc']!,
          _deadlineAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('next_reminder_at_utc')) {
      context.handle(
        _nextReminderAtUtcMeta,
        nextReminderAtUtc.isAcceptableOrUnknown(
          data['next_reminder_at_utc']!,
          _nextReminderAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('work_duration_ms')) {
      context.handle(
        _workDurationMsMeta,
        workDurationMs.isAcceptableOrUnknown(
          data['work_duration_ms']!,
          _workDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workDurationMsMeta);
    }
    if (data.containsKey('rest_duration_ms')) {
      context.handle(
        _restDurationMsMeta,
        restDurationMs.isAcceptableOrUnknown(
          data['rest_duration_ms']!,
          _restDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restDurationMsMeta);
    }
    if (data.containsKey('reminder_interval_ms')) {
      context.handle(
        _reminderIntervalMsMeta,
        reminderIntervalMs.isAcceptableOrUnknown(
          data['reminder_interval_ms']!,
          _reminderIntervalMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderIntervalMsMeta);
    }
    if (data.containsKey('reminder_timeout_ms')) {
      context.handle(
        _reminderTimeoutMsMeta,
        reminderTimeoutMs.isAcceptableOrUnknown(
          data['reminder_timeout_ms']!,
          _reminderTimeoutMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTimeoutMsMeta);
    }
    if (data.containsKey('timeout_behavior')) {
      context.handle(
        _timeoutBehaviorMeta,
        timeoutBehavior.isAcceptableOrUnknown(
          data['timeout_behavior']!,
          _timeoutBehaviorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      executionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execution_status'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      deadlineAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at_utc'],
      ),
      nextReminderAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_reminder_at_utc'],
      ),
      workDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_duration_ms'],
      )!,
      restDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_ms'],
      )!,
      reminderIntervalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_ms'],
      )!,
      reminderTimeoutMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_timeout_ms'],
      )!,
      timeoutBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeout_behavior'],
      )!,
    );
  }

  @override
  $TimerSnapshotsTableTable createAlias(String alias) {
    return $TimerSnapshotsTableTable(attachedDatabase, alias);
  }
}

class TimerSnapshotRow extends DataClass
    implements Insertable<TimerSnapshotRow> {
  final int id;
  final String cycleId;
  final int revision;
  final String phase;
  final String executionStatus;
  final DateTime startedAtUtc;
  final DateTime? deadlineAtUtc;
  final DateTime? nextReminderAtUtc;
  final int workDurationMs;
  final int restDurationMs;
  final int reminderIntervalMs;
  final int reminderTimeoutMs;
  final String timeoutBehavior;
  const TimerSnapshotRow({
    required this.id,
    required this.cycleId,
    required this.revision,
    required this.phase,
    required this.executionStatus,
    required this.startedAtUtc,
    this.deadlineAtUtc,
    this.nextReminderAtUtc,
    required this.workDurationMs,
    required this.restDurationMs,
    required this.reminderIntervalMs,
    required this.reminderTimeoutMs,
    required this.timeoutBehavior,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_id'] = Variable<String>(cycleId);
    map['revision'] = Variable<int>(revision);
    map['phase'] = Variable<String>(phase);
    map['execution_status'] = Variable<String>(executionStatus);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    if (!nullToAbsent || deadlineAtUtc != null) {
      map['deadline_at_utc'] = Variable<DateTime>(deadlineAtUtc);
    }
    if (!nullToAbsent || nextReminderAtUtc != null) {
      map['next_reminder_at_utc'] = Variable<DateTime>(nextReminderAtUtc);
    }
    map['work_duration_ms'] = Variable<int>(workDurationMs);
    map['rest_duration_ms'] = Variable<int>(restDurationMs);
    map['reminder_interval_ms'] = Variable<int>(reminderIntervalMs);
    map['reminder_timeout_ms'] = Variable<int>(reminderTimeoutMs);
    map['timeout_behavior'] = Variable<String>(timeoutBehavior);
    return map;
  }

  TimerSnapshotsTableCompanion toCompanion(bool nullToAbsent) {
    return TimerSnapshotsTableCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      revision: Value(revision),
      phase: Value(phase),
      executionStatus: Value(executionStatus),
      startedAtUtc: Value(startedAtUtc),
      deadlineAtUtc: deadlineAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineAtUtc),
      nextReminderAtUtc: nextReminderAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReminderAtUtc),
      workDurationMs: Value(workDurationMs),
      restDurationMs: Value(restDurationMs),
      reminderIntervalMs: Value(reminderIntervalMs),
      reminderTimeoutMs: Value(reminderTimeoutMs),
      timeoutBehavior: Value(timeoutBehavior),
    );
  }

  factory TimerSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerSnapshotRow(
      id: serializer.fromJson<int>(json['id']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      revision: serializer.fromJson<int>(json['revision']),
      phase: serializer.fromJson<String>(json['phase']),
      executionStatus: serializer.fromJson<String>(json['executionStatus']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      deadlineAtUtc: serializer.fromJson<DateTime?>(json['deadlineAtUtc']),
      nextReminderAtUtc: serializer.fromJson<DateTime?>(
        json['nextReminderAtUtc'],
      ),
      workDurationMs: serializer.fromJson<int>(json['workDurationMs']),
      restDurationMs: serializer.fromJson<int>(json['restDurationMs']),
      reminderIntervalMs: serializer.fromJson<int>(json['reminderIntervalMs']),
      reminderTimeoutMs: serializer.fromJson<int>(json['reminderTimeoutMs']),
      timeoutBehavior: serializer.fromJson<String>(json['timeoutBehavior']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleId': serializer.toJson<String>(cycleId),
      'revision': serializer.toJson<int>(revision),
      'phase': serializer.toJson<String>(phase),
      'executionStatus': serializer.toJson<String>(executionStatus),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'deadlineAtUtc': serializer.toJson<DateTime?>(deadlineAtUtc),
      'nextReminderAtUtc': serializer.toJson<DateTime?>(nextReminderAtUtc),
      'workDurationMs': serializer.toJson<int>(workDurationMs),
      'restDurationMs': serializer.toJson<int>(restDurationMs),
      'reminderIntervalMs': serializer.toJson<int>(reminderIntervalMs),
      'reminderTimeoutMs': serializer.toJson<int>(reminderTimeoutMs),
      'timeoutBehavior': serializer.toJson<String>(timeoutBehavior),
    };
  }

  TimerSnapshotRow copyWith({
    int? id,
    String? cycleId,
    int? revision,
    String? phase,
    String? executionStatus,
    DateTime? startedAtUtc,
    Value<DateTime?> deadlineAtUtc = const Value.absent(),
    Value<DateTime?> nextReminderAtUtc = const Value.absent(),
    int? workDurationMs,
    int? restDurationMs,
    int? reminderIntervalMs,
    int? reminderTimeoutMs,
    String? timeoutBehavior,
  }) => TimerSnapshotRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    revision: revision ?? this.revision,
    phase: phase ?? this.phase,
    executionStatus: executionStatus ?? this.executionStatus,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    deadlineAtUtc: deadlineAtUtc.present
        ? deadlineAtUtc.value
        : this.deadlineAtUtc,
    nextReminderAtUtc: nextReminderAtUtc.present
        ? nextReminderAtUtc.value
        : this.nextReminderAtUtc,
    workDurationMs: workDurationMs ?? this.workDurationMs,
    restDurationMs: restDurationMs ?? this.restDurationMs,
    reminderIntervalMs: reminderIntervalMs ?? this.reminderIntervalMs,
    reminderTimeoutMs: reminderTimeoutMs ?? this.reminderTimeoutMs,
    timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
  );
  TimerSnapshotRow copyWithCompanion(TimerSnapshotsTableCompanion data) {
    return TimerSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      revision: data.revision.present ? data.revision.value : this.revision,
      phase: data.phase.present ? data.phase.value : this.phase,
      executionStatus: data.executionStatus.present
          ? data.executionStatus.value
          : this.executionStatus,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      deadlineAtUtc: data.deadlineAtUtc.present
          ? data.deadlineAtUtc.value
          : this.deadlineAtUtc,
      nextReminderAtUtc: data.nextReminderAtUtc.present
          ? data.nextReminderAtUtc.value
          : this.nextReminderAtUtc,
      workDurationMs: data.workDurationMs.present
          ? data.workDurationMs.value
          : this.workDurationMs,
      restDurationMs: data.restDurationMs.present
          ? data.restDurationMs.value
          : this.restDurationMs,
      reminderIntervalMs: data.reminderIntervalMs.present
          ? data.reminderIntervalMs.value
          : this.reminderIntervalMs,
      reminderTimeoutMs: data.reminderTimeoutMs.present
          ? data.reminderTimeoutMs.value
          : this.reminderTimeoutMs,
      timeoutBehavior: data.timeoutBehavior.present
          ? data.timeoutBehavior.value
          : this.timeoutBehavior,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerSnapshotRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('revision: $revision, ')
          ..write('phase: $phase, ')
          ..write('executionStatus: $executionStatus, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('deadlineAtUtc: $deadlineAtUtc, ')
          ..write('nextReminderAtUtc: $nextReminderAtUtc, ')
          ..write('workDurationMs: $workDurationMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('reminderIntervalMs: $reminderIntervalMs, ')
          ..write('reminderTimeoutMs: $reminderTimeoutMs, ')
          ..write('timeoutBehavior: $timeoutBehavior')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    revision,
    phase,
    executionStatus,
    startedAtUtc,
    deadlineAtUtc,
    nextReminderAtUtc,
    workDurationMs,
    restDurationMs,
    reminderIntervalMs,
    reminderTimeoutMs,
    timeoutBehavior,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerSnapshotRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.revision == this.revision &&
          other.phase == this.phase &&
          other.executionStatus == this.executionStatus &&
          other.startedAtUtc == this.startedAtUtc &&
          other.deadlineAtUtc == this.deadlineAtUtc &&
          other.nextReminderAtUtc == this.nextReminderAtUtc &&
          other.workDurationMs == this.workDurationMs &&
          other.restDurationMs == this.restDurationMs &&
          other.reminderIntervalMs == this.reminderIntervalMs &&
          other.reminderTimeoutMs == this.reminderTimeoutMs &&
          other.timeoutBehavior == this.timeoutBehavior);
}

class TimerSnapshotsTableCompanion extends UpdateCompanion<TimerSnapshotRow> {
  final Value<int> id;
  final Value<String> cycleId;
  final Value<int> revision;
  final Value<String> phase;
  final Value<String> executionStatus;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime?> deadlineAtUtc;
  final Value<DateTime?> nextReminderAtUtc;
  final Value<int> workDurationMs;
  final Value<int> restDurationMs;
  final Value<int> reminderIntervalMs;
  final Value<int> reminderTimeoutMs;
  final Value<String> timeoutBehavior;
  const TimerSnapshotsTableCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.revision = const Value.absent(),
    this.phase = const Value.absent(),
    this.executionStatus = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.deadlineAtUtc = const Value.absent(),
    this.nextReminderAtUtc = const Value.absent(),
    this.workDurationMs = const Value.absent(),
    this.restDurationMs = const Value.absent(),
    this.reminderIntervalMs = const Value.absent(),
    this.reminderTimeoutMs = const Value.absent(),
    this.timeoutBehavior = const Value.absent(),
  });
  TimerSnapshotsTableCompanion.insert({
    this.id = const Value.absent(),
    required String cycleId,
    required int revision,
    required String phase,
    required String executionStatus,
    required DateTime startedAtUtc,
    this.deadlineAtUtc = const Value.absent(),
    this.nextReminderAtUtc = const Value.absent(),
    required int workDurationMs,
    required int restDurationMs,
    required int reminderIntervalMs,
    required int reminderTimeoutMs,
    this.timeoutBehavior = const Value.absent(),
  }) : cycleId = Value(cycleId),
       revision = Value(revision),
       phase = Value(phase),
       executionStatus = Value(executionStatus),
       startedAtUtc = Value(startedAtUtc),
       workDurationMs = Value(workDurationMs),
       restDurationMs = Value(restDurationMs),
       reminderIntervalMs = Value(reminderIntervalMs),
       reminderTimeoutMs = Value(reminderTimeoutMs);
  static Insertable<TimerSnapshotRow> custom({
    Expression<int>? id,
    Expression<String>? cycleId,
    Expression<int>? revision,
    Expression<String>? phase,
    Expression<String>? executionStatus,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? deadlineAtUtc,
    Expression<DateTime>? nextReminderAtUtc,
    Expression<int>? workDurationMs,
    Expression<int>? restDurationMs,
    Expression<int>? reminderIntervalMs,
    Expression<int>? reminderTimeoutMs,
    Expression<String>? timeoutBehavior,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (revision != null) 'revision': revision,
      if (phase != null) 'phase': phase,
      if (executionStatus != null) 'execution_status': executionStatus,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (deadlineAtUtc != null) 'deadline_at_utc': deadlineAtUtc,
      if (nextReminderAtUtc != null) 'next_reminder_at_utc': nextReminderAtUtc,
      if (workDurationMs != null) 'work_duration_ms': workDurationMs,
      if (restDurationMs != null) 'rest_duration_ms': restDurationMs,
      if (reminderIntervalMs != null)
        'reminder_interval_ms': reminderIntervalMs,
      if (reminderTimeoutMs != null) 'reminder_timeout_ms': reminderTimeoutMs,
      if (timeoutBehavior != null) 'timeout_behavior': timeoutBehavior,
    });
  }

  TimerSnapshotsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? cycleId,
    Value<int>? revision,
    Value<String>? phase,
    Value<String>? executionStatus,
    Value<DateTime>? startedAtUtc,
    Value<DateTime?>? deadlineAtUtc,
    Value<DateTime?>? nextReminderAtUtc,
    Value<int>? workDurationMs,
    Value<int>? restDurationMs,
    Value<int>? reminderIntervalMs,
    Value<int>? reminderTimeoutMs,
    Value<String>? timeoutBehavior,
  }) {
    return TimerSnapshotsTableCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      revision: revision ?? this.revision,
      phase: phase ?? this.phase,
      executionStatus: executionStatus ?? this.executionStatus,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      deadlineAtUtc: deadlineAtUtc ?? this.deadlineAtUtc,
      nextReminderAtUtc: nextReminderAtUtc ?? this.nextReminderAtUtc,
      workDurationMs: workDurationMs ?? this.workDurationMs,
      restDurationMs: restDurationMs ?? this.restDurationMs,
      reminderIntervalMs: reminderIntervalMs ?? this.reminderIntervalMs,
      reminderTimeoutMs: reminderTimeoutMs ?? this.reminderTimeoutMs,
      timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (executionStatus.present) {
      map['execution_status'] = Variable<String>(executionStatus.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (deadlineAtUtc.present) {
      map['deadline_at_utc'] = Variable<DateTime>(deadlineAtUtc.value);
    }
    if (nextReminderAtUtc.present) {
      map['next_reminder_at_utc'] = Variable<DateTime>(nextReminderAtUtc.value);
    }
    if (workDurationMs.present) {
      map['work_duration_ms'] = Variable<int>(workDurationMs.value);
    }
    if (restDurationMs.present) {
      map['rest_duration_ms'] = Variable<int>(restDurationMs.value);
    }
    if (reminderIntervalMs.present) {
      map['reminder_interval_ms'] = Variable<int>(reminderIntervalMs.value);
    }
    if (reminderTimeoutMs.present) {
      map['reminder_timeout_ms'] = Variable<int>(reminderTimeoutMs.value);
    }
    if (timeoutBehavior.present) {
      map['timeout_behavior'] = Variable<String>(timeoutBehavior.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerSnapshotsTableCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('revision: $revision, ')
          ..write('phase: $phase, ')
          ..write('executionStatus: $executionStatus, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('deadlineAtUtc: $deadlineAtUtc, ')
          ..write('nextReminderAtUtc: $nextReminderAtUtc, ')
          ..write('workDurationMs: $workDurationMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('reminderIntervalMs: $reminderIntervalMs, ')
          ..write('reminderTimeoutMs: $reminderTimeoutMs, ')
          ..write('timeoutBehavior: $timeoutBehavior')
          ..write(')'))
        .toString();
  }
}

class $PendingCommandsTableTable extends PendingCommandsTable
    with TableInfo<$PendingCommandsTableTable, PendingCommandRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingCommandsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _commandIdMeta = const VerificationMeta(
    'commandId',
  );
  @override
  late final GeneratedColumn<String> commandId = GeneratedColumn<String>(
    'command_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedPhaseMeta = const VerificationMeta(
    'expectedPhase',
  );
  @override
  late final GeneratedColumn<String> expectedPhase = GeneratedColumn<String>(
    'expected_phase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedRevisionMeta = const VerificationMeta(
    'expectedRevision',
  );
  @override
  late final GeneratedColumn<int> expectedRevision = GeneratedColumn<int>(
    'expected_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedAtUtcMeta = const VerificationMeta(
    'processedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> processedAtUtc =
      GeneratedColumn<DateTime>(
        'processed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _staleAtUtcMeta = const VerificationMeta(
    'staleAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> staleAtUtc = GeneratedColumn<DateTime>(
    'stale_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    commandId,
    action,
    cycleId,
    expectedPhase,
    expectedRevision,
    occurredAtUtc,
    payloadJson,
    processedAtUtc,
    staleAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_commands_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingCommandRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('command_id')) {
      context.handle(
        _commandIdMeta,
        commandId.isAcceptableOrUnknown(data['command_id']!, _commandIdMeta),
      );
    } else if (isInserting) {
      context.missing(_commandIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    }
    if (data.containsKey('expected_phase')) {
      context.handle(
        _expectedPhaseMeta,
        expectedPhase.isAcceptableOrUnknown(
          data['expected_phase']!,
          _expectedPhaseMeta,
        ),
      );
    }
    if (data.containsKey('expected_revision')) {
      context.handle(
        _expectedRevisionMeta,
        expectedRevision.isAcceptableOrUnknown(
          data['expected_revision']!,
          _expectedRevisionMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('processed_at_utc')) {
      context.handle(
        _processedAtUtcMeta,
        processedAtUtc.isAcceptableOrUnknown(
          data['processed_at_utc']!,
          _processedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('stale_at_utc')) {
      context.handle(
        _staleAtUtcMeta,
        staleAtUtc.isAcceptableOrUnknown(
          data['stale_at_utc']!,
          _staleAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingCommandRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingCommandRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      commandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      ),
      expectedPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_phase'],
      ),
      expectedRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_revision'],
      ),
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      processedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at_utc'],
      ),
      staleAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stale_at_utc'],
      ),
    );
  }

  @override
  $PendingCommandsTableTable createAlias(String alias) {
    return $PendingCommandsTableTable(attachedDatabase, alias);
  }
}

class PendingCommandRow extends DataClass
    implements Insertable<PendingCommandRow> {
  final int id;
  final String commandId;
  final String action;
  final String? cycleId;
  final String? expectedPhase;
  final int? expectedRevision;
  final DateTime occurredAtUtc;
  final String payloadJson;
  final DateTime? processedAtUtc;
  final DateTime? staleAtUtc;
  const PendingCommandRow({
    required this.id,
    required this.commandId,
    required this.action,
    this.cycleId,
    this.expectedPhase,
    this.expectedRevision,
    required this.occurredAtUtc,
    required this.payloadJson,
    this.processedAtUtc,
    this.staleAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['command_id'] = Variable<String>(commandId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || cycleId != null) {
      map['cycle_id'] = Variable<String>(cycleId);
    }
    if (!nullToAbsent || expectedPhase != null) {
      map['expected_phase'] = Variable<String>(expectedPhase);
    }
    if (!nullToAbsent || expectedRevision != null) {
      map['expected_revision'] = Variable<int>(expectedRevision);
    }
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || processedAtUtc != null) {
      map['processed_at_utc'] = Variable<DateTime>(processedAtUtc);
    }
    if (!nullToAbsent || staleAtUtc != null) {
      map['stale_at_utc'] = Variable<DateTime>(staleAtUtc);
    }
    return map;
  }

  PendingCommandsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingCommandsTableCompanion(
      id: Value(id),
      commandId: Value(commandId),
      action: Value(action),
      cycleId: cycleId == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleId),
      expectedPhase: expectedPhase == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedPhase),
      expectedRevision: expectedRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedRevision),
      occurredAtUtc: Value(occurredAtUtc),
      payloadJson: Value(payloadJson),
      processedAtUtc: processedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAtUtc),
      staleAtUtc: staleAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(staleAtUtc),
    );
  }

  factory PendingCommandRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingCommandRow(
      id: serializer.fromJson<int>(json['id']),
      commandId: serializer.fromJson<String>(json['commandId']),
      action: serializer.fromJson<String>(json['action']),
      cycleId: serializer.fromJson<String?>(json['cycleId']),
      expectedPhase: serializer.fromJson<String?>(json['expectedPhase']),
      expectedRevision: serializer.fromJson<int?>(json['expectedRevision']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      processedAtUtc: serializer.fromJson<DateTime?>(json['processedAtUtc']),
      staleAtUtc: serializer.fromJson<DateTime?>(json['staleAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'commandId': serializer.toJson<String>(commandId),
      'action': serializer.toJson<String>(action),
      'cycleId': serializer.toJson<String?>(cycleId),
      'expectedPhase': serializer.toJson<String?>(expectedPhase),
      'expectedRevision': serializer.toJson<int?>(expectedRevision),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'processedAtUtc': serializer.toJson<DateTime?>(processedAtUtc),
      'staleAtUtc': serializer.toJson<DateTime?>(staleAtUtc),
    };
  }

  PendingCommandRow copyWith({
    int? id,
    String? commandId,
    String? action,
    Value<String?> cycleId = const Value.absent(),
    Value<String?> expectedPhase = const Value.absent(),
    Value<int?> expectedRevision = const Value.absent(),
    DateTime? occurredAtUtc,
    String? payloadJson,
    Value<DateTime?> processedAtUtc = const Value.absent(),
    Value<DateTime?> staleAtUtc = const Value.absent(),
  }) => PendingCommandRow(
    id: id ?? this.id,
    commandId: commandId ?? this.commandId,
    action: action ?? this.action,
    cycleId: cycleId.present ? cycleId.value : this.cycleId,
    expectedPhase: expectedPhase.present
        ? expectedPhase.value
        : this.expectedPhase,
    expectedRevision: expectedRevision.present
        ? expectedRevision.value
        : this.expectedRevision,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    payloadJson: payloadJson ?? this.payloadJson,
    processedAtUtc: processedAtUtc.present
        ? processedAtUtc.value
        : this.processedAtUtc,
    staleAtUtc: staleAtUtc.present ? staleAtUtc.value : this.staleAtUtc,
  );
  PendingCommandRow copyWithCompanion(PendingCommandsTableCompanion data) {
    return PendingCommandRow(
      id: data.id.present ? data.id.value : this.id,
      commandId: data.commandId.present ? data.commandId.value : this.commandId,
      action: data.action.present ? data.action.value : this.action,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      expectedPhase: data.expectedPhase.present
          ? data.expectedPhase.value
          : this.expectedPhase,
      expectedRevision: data.expectedRevision.present
          ? data.expectedRevision.value
          : this.expectedRevision,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      processedAtUtc: data.processedAtUtc.present
          ? data.processedAtUtc.value
          : this.processedAtUtc,
      staleAtUtc: data.staleAtUtc.present
          ? data.staleAtUtc.value
          : this.staleAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingCommandRow(')
          ..write('id: $id, ')
          ..write('commandId: $commandId, ')
          ..write('action: $action, ')
          ..write('cycleId: $cycleId, ')
          ..write('expectedPhase: $expectedPhase, ')
          ..write('expectedRevision: $expectedRevision, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('processedAtUtc: $processedAtUtc, ')
          ..write('staleAtUtc: $staleAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    commandId,
    action,
    cycleId,
    expectedPhase,
    expectedRevision,
    occurredAtUtc,
    payloadJson,
    processedAtUtc,
    staleAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingCommandRow &&
          other.id == this.id &&
          other.commandId == this.commandId &&
          other.action == this.action &&
          other.cycleId == this.cycleId &&
          other.expectedPhase == this.expectedPhase &&
          other.expectedRevision == this.expectedRevision &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.payloadJson == this.payloadJson &&
          other.processedAtUtc == this.processedAtUtc &&
          other.staleAtUtc == this.staleAtUtc);
}

class PendingCommandsTableCompanion extends UpdateCompanion<PendingCommandRow> {
  final Value<int> id;
  final Value<String> commandId;
  final Value<String> action;
  final Value<String?> cycleId;
  final Value<String?> expectedPhase;
  final Value<int?> expectedRevision;
  final Value<DateTime> occurredAtUtc;
  final Value<String> payloadJson;
  final Value<DateTime?> processedAtUtc;
  final Value<DateTime?> staleAtUtc;
  const PendingCommandsTableCompanion({
    this.id = const Value.absent(),
    this.commandId = const Value.absent(),
    this.action = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.expectedPhase = const Value.absent(),
    this.expectedRevision = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.processedAtUtc = const Value.absent(),
    this.staleAtUtc = const Value.absent(),
  });
  PendingCommandsTableCompanion.insert({
    this.id = const Value.absent(),
    required String commandId,
    required String action,
    this.cycleId = const Value.absent(),
    this.expectedPhase = const Value.absent(),
    this.expectedRevision = const Value.absent(),
    required DateTime occurredAtUtc,
    required String payloadJson,
    this.processedAtUtc = const Value.absent(),
    this.staleAtUtc = const Value.absent(),
  }) : commandId = Value(commandId),
       action = Value(action),
       occurredAtUtc = Value(occurredAtUtc),
       payloadJson = Value(payloadJson);
  static Insertable<PendingCommandRow> custom({
    Expression<int>? id,
    Expression<String>? commandId,
    Expression<String>? action,
    Expression<String>? cycleId,
    Expression<String>? expectedPhase,
    Expression<int>? expectedRevision,
    Expression<DateTime>? occurredAtUtc,
    Expression<String>? payloadJson,
    Expression<DateTime>? processedAtUtc,
    Expression<DateTime>? staleAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commandId != null) 'command_id': commandId,
      if (action != null) 'action': action,
      if (cycleId != null) 'cycle_id': cycleId,
      if (expectedPhase != null) 'expected_phase': expectedPhase,
      if (expectedRevision != null) 'expected_revision': expectedRevision,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (processedAtUtc != null) 'processed_at_utc': processedAtUtc,
      if (staleAtUtc != null) 'stale_at_utc': staleAtUtc,
    });
  }

  PendingCommandsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? commandId,
    Value<String>? action,
    Value<String?>? cycleId,
    Value<String?>? expectedPhase,
    Value<int?>? expectedRevision,
    Value<DateTime>? occurredAtUtc,
    Value<String>? payloadJson,
    Value<DateTime?>? processedAtUtc,
    Value<DateTime?>? staleAtUtc,
  }) {
    return PendingCommandsTableCompanion(
      id: id ?? this.id,
      commandId: commandId ?? this.commandId,
      action: action ?? this.action,
      cycleId: cycleId ?? this.cycleId,
      expectedPhase: expectedPhase ?? this.expectedPhase,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      payloadJson: payloadJson ?? this.payloadJson,
      processedAtUtc: processedAtUtc ?? this.processedAtUtc,
      staleAtUtc: staleAtUtc ?? this.staleAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (commandId.present) {
      map['command_id'] = Variable<String>(commandId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (expectedPhase.present) {
      map['expected_phase'] = Variable<String>(expectedPhase.value);
    }
    if (expectedRevision.present) {
      map['expected_revision'] = Variable<int>(expectedRevision.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (processedAtUtc.present) {
      map['processed_at_utc'] = Variable<DateTime>(processedAtUtc.value);
    }
    if (staleAtUtc.present) {
      map['stale_at_utc'] = Variable<DateTime>(staleAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingCommandsTableCompanion(')
          ..write('id: $id, ')
          ..write('commandId: $commandId, ')
          ..write('action: $action, ')
          ..write('cycleId: $cycleId, ')
          ..write('expectedPhase: $expectedPhase, ')
          ..write('expectedRevision: $expectedRevision, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('processedAtUtc: $processedAtUtc, ')
          ..write('staleAtUtc: $staleAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTableTable extends ActivityEventsTable
    with TableInfo<$ActivityEventsTableTable, ActivityEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _utcOffsetMinutesMeta = const VerificationMeta(
    'utcOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> utcOffsetMinutes = GeneratedColumn<int>(
    'utc_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateKeyMeta = const VerificationMeta(
    'localDateKey',
  );
  @override
  late final GeneratedColumn<String> localDateKey = GeneratedColumn<String>(
    'local_date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _countValueMeta = const VerificationMeta(
    'countValue',
  );
  @override
  late final GeneratedColumn<int> countValue = GeneratedColumn<int>(
    'count_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    cycleId,
    eventType,
    occurredAtUtc,
    utcOffsetMinutes,
    localDateKey,
    durationMs,
    countValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('utc_offset_minutes')) {
      context.handle(
        _utcOffsetMinutesMeta,
        utcOffsetMinutes.isAcceptableOrUnknown(
          data['utc_offset_minutes']!,
          _utcOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utcOffsetMinutesMeta);
    }
    if (data.containsKey('local_date_key')) {
      context.handle(
        _localDateKeyMeta,
        localDateKey.isAcceptableOrUnknown(
          data['local_date_key']!,
          _localDateKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localDateKeyMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('count_value')) {
      context.handle(
        _countValueMeta,
        countValue.isAcceptableOrUnknown(data['count_value']!, _countValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ActivityEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEventRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      utcOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utc_offset_minutes'],
      )!,
      localDateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date_key'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      countValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_value'],
      )!,
    );
  }

  @override
  $ActivityEventsTableTable createAlias(String alias) {
    return $ActivityEventsTableTable(attachedDatabase, alias);
  }
}

class ActivityEventRow extends DataClass
    implements Insertable<ActivityEventRow> {
  final String eventId;
  final String cycleId;
  final String eventType;
  final DateTime occurredAtUtc;
  final int utcOffsetMinutes;
  final String localDateKey;
  final int durationMs;
  final int countValue;
  const ActivityEventRow({
    required this.eventId,
    required this.cycleId,
    required this.eventType,
    required this.occurredAtUtc,
    required this.utcOffsetMinutes,
    required this.localDateKey,
    required this.durationMs,
    required this.countValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['cycle_id'] = Variable<String>(cycleId);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes);
    map['local_date_key'] = Variable<String>(localDateKey);
    map['duration_ms'] = Variable<int>(durationMs);
    map['count_value'] = Variable<int>(countValue);
    return map;
  }

  ActivityEventsTableCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsTableCompanion(
      eventId: Value(eventId),
      cycleId: Value(cycleId),
      eventType: Value(eventType),
      occurredAtUtc: Value(occurredAtUtc),
      utcOffsetMinutes: Value(utcOffsetMinutes),
      localDateKey: Value(localDateKey),
      durationMs: Value(durationMs),
      countValue: Value(countValue),
    );
  }

  factory ActivityEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEventRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      utcOffsetMinutes: serializer.fromJson<int>(json['utcOffsetMinutes']),
      localDateKey: serializer.fromJson<String>(json['localDateKey']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      countValue: serializer.fromJson<int>(json['countValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'cycleId': serializer.toJson<String>(cycleId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'utcOffsetMinutes': serializer.toJson<int>(utcOffsetMinutes),
      'localDateKey': serializer.toJson<String>(localDateKey),
      'durationMs': serializer.toJson<int>(durationMs),
      'countValue': serializer.toJson<int>(countValue),
    };
  }

  ActivityEventRow copyWith({
    String? eventId,
    String? cycleId,
    String? eventType,
    DateTime? occurredAtUtc,
    int? utcOffsetMinutes,
    String? localDateKey,
    int? durationMs,
    int? countValue,
  }) => ActivityEventRow(
    eventId: eventId ?? this.eventId,
    cycleId: cycleId ?? this.cycleId,
    eventType: eventType ?? this.eventType,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
    localDateKey: localDateKey ?? this.localDateKey,
    durationMs: durationMs ?? this.durationMs,
    countValue: countValue ?? this.countValue,
  );
  ActivityEventRow copyWithCompanion(ActivityEventsTableCompanion data) {
    return ActivityEventRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      utcOffsetMinutes: data.utcOffsetMinutes.present
          ? data.utcOffsetMinutes.value
          : this.utcOffsetMinutes,
      localDateKey: data.localDateKey.present
          ? data.localDateKey.value
          : this.localDateKey,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      countValue: data.countValue.present
          ? data.countValue.value
          : this.countValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventRow(')
          ..write('eventId: $eventId, ')
          ..write('cycleId: $cycleId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('localDateKey: $localDateKey, ')
          ..write('durationMs: $durationMs, ')
          ..write('countValue: $countValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    cycleId,
    eventType,
    occurredAtUtc,
    utcOffsetMinutes,
    localDateKey,
    durationMs,
    countValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEventRow &&
          other.eventId == this.eventId &&
          other.cycleId == this.cycleId &&
          other.eventType == this.eventType &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.utcOffsetMinutes == this.utcOffsetMinutes &&
          other.localDateKey == this.localDateKey &&
          other.durationMs == this.durationMs &&
          other.countValue == this.countValue);
}

class ActivityEventsTableCompanion extends UpdateCompanion<ActivityEventRow> {
  final Value<String> eventId;
  final Value<String> cycleId;
  final Value<String> eventType;
  final Value<DateTime> occurredAtUtc;
  final Value<int> utcOffsetMinutes;
  final Value<String> localDateKey;
  final Value<int> durationMs;
  final Value<int> countValue;
  final Value<int> rowid;
  const ActivityEventsTableCompanion({
    this.eventId = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.utcOffsetMinutes = const Value.absent(),
    this.localDateKey = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.countValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsTableCompanion.insert({
    required String eventId,
    required String cycleId,
    required String eventType,
    required DateTime occurredAtUtc,
    required int utcOffsetMinutes,
    required String localDateKey,
    this.durationMs = const Value.absent(),
    this.countValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       cycleId = Value(cycleId),
       eventType = Value(eventType),
       occurredAtUtc = Value(occurredAtUtc),
       utcOffsetMinutes = Value(utcOffsetMinutes),
       localDateKey = Value(localDateKey);
  static Insertable<ActivityEventRow> custom({
    Expression<String>? eventId,
    Expression<String>? cycleId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? utcOffsetMinutes,
    Expression<String>? localDateKey,
    Expression<int>? durationMs,
    Expression<int>? countValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (cycleId != null) 'cycle_id': cycleId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (utcOffsetMinutes != null) 'utc_offset_minutes': utcOffsetMinutes,
      if (localDateKey != null) 'local_date_key': localDateKey,
      if (durationMs != null) 'duration_ms': durationMs,
      if (countValue != null) 'count_value': countValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsTableCompanion copyWith({
    Value<String>? eventId,
    Value<String>? cycleId,
    Value<String>? eventType,
    Value<DateTime>? occurredAtUtc,
    Value<int>? utcOffsetMinutes,
    Value<String>? localDateKey,
    Value<int>? durationMs,
    Value<int>? countValue,
    Value<int>? rowid,
  }) {
    return ActivityEventsTableCompanion(
      eventId: eventId ?? this.eventId,
      cycleId: cycleId ?? this.cycleId,
      eventType: eventType ?? this.eventType,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      localDateKey: localDateKey ?? this.localDateKey,
      durationMs: durationMs ?? this.durationMs,
      countValue: countValue ?? this.countValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (utcOffsetMinutes.present) {
      map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes.value);
    }
    if (localDateKey.present) {
      map['local_date_key'] = Variable<String>(localDateKey.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (countValue.present) {
      map['count_value'] = Variable<int>(countValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('cycleId: $cycleId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('localDateKey: $localDateKey, ')
          ..write('durationMs: $durationMs, ')
          ..write('countValue: $countValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreenActivityStateTableTable extends ScreenActivityStateTable
    with TableInfo<$ScreenActivityStateTableTable, ScreenActivityStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenActivityStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, startedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_activity_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenActivityStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenActivityStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenActivityStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
    );
  }

  @override
  $ScreenActivityStateTableTable createAlias(String alias) {
    return $ScreenActivityStateTableTable(attachedDatabase, alias);
  }
}

class ScreenActivityStateRow extends DataClass
    implements Insertable<ScreenActivityStateRow> {
  final int id;
  final DateTime startedAtUtc;
  const ScreenActivityStateRow({required this.id, required this.startedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    return map;
  }

  ScreenActivityStateTableCompanion toCompanion(bool nullToAbsent) {
    return ScreenActivityStateTableCompanion(
      id: Value(id),
      startedAtUtc: Value(startedAtUtc),
    );
  }

  factory ScreenActivityStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenActivityStateRow(
      id: serializer.fromJson<int>(json['id']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
    };
  }

  ScreenActivityStateRow copyWith({int? id, DateTime? startedAtUtc}) =>
      ScreenActivityStateRow(
        id: id ?? this.id,
        startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      );
  ScreenActivityStateRow copyWithCompanion(
    ScreenActivityStateTableCompanion data,
  ) {
    return ScreenActivityStateRow(
      id: data.id.present ? data.id.value : this.id,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenActivityStateRow(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenActivityStateRow &&
          other.id == this.id &&
          other.startedAtUtc == this.startedAtUtc);
}

class ScreenActivityStateTableCompanion
    extends UpdateCompanion<ScreenActivityStateRow> {
  final Value<int> id;
  final Value<DateTime> startedAtUtc;
  const ScreenActivityStateTableCompanion({
    this.id = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
  });
  ScreenActivityStateTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAtUtc,
  }) : startedAtUtc = Value(startedAtUtc);
  static Insertable<ScreenActivityStateRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
    });
  }

  ScreenActivityStateTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAtUtc,
  }) {
    return ScreenActivityStateTableCompanion(
      id: id ?? this.id,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenActivityStateTableCompanion(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $TimerSnapshotsTableTable timerSnapshotsTable =
      $TimerSnapshotsTableTable(this);
  late final $PendingCommandsTableTable pendingCommandsTable =
      $PendingCommandsTableTable(this);
  late final $ActivityEventsTableTable activityEventsTable =
      $ActivityEventsTableTable(this);
  late final $ScreenActivityStateTableTable screenActivityStateTable =
      $ScreenActivityStateTableTable(this);
  late final Index pendingCommandsStatusIdx = Index(
    'pending_commands_status_idx',
    'CREATE INDEX pending_commands_status_idx ON pending_commands_table (processed_at_utc, stale_at_utc, occurred_at_utc)',
  );
  late final Index activityEventsLocalDateKeyIdx = Index(
    'activity_events_local_date_key_idx',
    'CREATE INDEX activity_events_local_date_key_idx ON activity_events_table (local_date_key)',
  );
  late final Index activityEventsOccurredAtIdx = Index(
    'activity_events_occurred_at_idx',
    'CREATE INDEX activity_events_occurred_at_idx ON activity_events_table (occurred_at_utc)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettingsTable,
    timerSnapshotsTable,
    pendingCommandsTable,
    activityEventsTable,
    screenActivityStateTable,
    pendingCommandsStatusIdx,
    activityEventsLocalDateKeyIdx,
    activityEventsOccurredAtIdx,
  ];
}

typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      required int workDurationMs,
      required int restDurationMs,
      required int reminderIntervalMs,
      required int reminderTimeoutMs,
      required bool androidVibrationEnabled,
      Value<bool> workReminderEnabled,
      Value<bool> restReminderEnabled,
      Value<bool> missedRestReminderEnabled,
      required String localeCode,
      required String themeModeCode,
      Value<bool> pauseWhenLocked,
      Value<bool> fixedPortraitEnabled,
      Value<bool> minimizeToTrayOnClose,
      Value<String> timeoutBehavior,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<int> id,
      Value<int> workDurationMs,
      Value<int> restDurationMs,
      Value<int> reminderIntervalMs,
      Value<int> reminderTimeoutMs,
      Value<bool> androidVibrationEnabled,
      Value<bool> workReminderEnabled,
      Value<bool> restReminderEnabled,
      Value<bool> missedRestReminderEnabled,
      Value<String> localeCode,
      Value<String> themeModeCode,
      Value<bool> pauseWhenLocked,
      Value<bool> fixedPortraitEnabled,
      Value<bool> minimizeToTrayOnClose,
      Value<String> timeoutBehavior,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get androidVibrationEnabled => $composableBuilder(
    column: $table.androidVibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get workReminderEnabled => $composableBuilder(
    column: $table.workReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get restReminderEnabled => $composableBuilder(
    column: $table.restReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get missedRestReminderEnabled => $composableBuilder(
    column: $table.missedRestReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeModeCode => $composableBuilder(
    column: $table.themeModeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pauseWhenLocked => $composableBuilder(
    column: $table.pauseWhenLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fixedPortraitEnabled => $composableBuilder(
    column: $table.fixedPortraitEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get minimizeToTrayOnClose => $composableBuilder(
    column: $table.minimizeToTrayOnClose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get androidVibrationEnabled => $composableBuilder(
    column: $table.androidVibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get workReminderEnabled => $composableBuilder(
    column: $table.workReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get restReminderEnabled => $composableBuilder(
    column: $table.restReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get missedRestReminderEnabled => $composableBuilder(
    column: $table.missedRestReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeModeCode => $composableBuilder(
    column: $table.themeModeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pauseWhenLocked => $composableBuilder(
    column: $table.pauseWhenLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fixedPortraitEnabled => $composableBuilder(
    column: $table.fixedPortraitEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get minimizeToTrayOnClose => $composableBuilder(
    column: $table.minimizeToTrayOnClose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get androidVibrationEnabled => $composableBuilder(
    column: $table.androidVibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get workReminderEnabled => $composableBuilder(
    column: $table.workReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get restReminderEnabled => $composableBuilder(
    column: $table.restReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get missedRestReminderEnabled => $composableBuilder(
    column: $table.missedRestReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeModeCode => $composableBuilder(
    column: $table.themeModeCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pauseWhenLocked => $composableBuilder(
    column: $table.pauseWhenLocked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fixedPortraitEnabled => $composableBuilder(
    column: $table.fixedPortraitEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get minimizeToTrayOnClose => $composableBuilder(
    column: $table.minimizeToTrayOnClose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsRow,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workDurationMs = const Value.absent(),
                Value<int> restDurationMs = const Value.absent(),
                Value<int> reminderIntervalMs = const Value.absent(),
                Value<int> reminderTimeoutMs = const Value.absent(),
                Value<bool> androidVibrationEnabled = const Value.absent(),
                Value<bool> workReminderEnabled = const Value.absent(),
                Value<bool> restReminderEnabled = const Value.absent(),
                Value<bool> missedRestReminderEnabled = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String> themeModeCode = const Value.absent(),
                Value<bool> pauseWhenLocked = const Value.absent(),
                Value<bool> fixedPortraitEnabled = const Value.absent(),
                Value<bool> minimizeToTrayOnClose = const Value.absent(),
                Value<String> timeoutBehavior = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                workDurationMs: workDurationMs,
                restDurationMs: restDurationMs,
                reminderIntervalMs: reminderIntervalMs,
                reminderTimeoutMs: reminderTimeoutMs,
                androidVibrationEnabled: androidVibrationEnabled,
                workReminderEnabled: workReminderEnabled,
                restReminderEnabled: restReminderEnabled,
                missedRestReminderEnabled: missedRestReminderEnabled,
                localeCode: localeCode,
                themeModeCode: themeModeCode,
                pauseWhenLocked: pauseWhenLocked,
                fixedPortraitEnabled: fixedPortraitEnabled,
                minimizeToTrayOnClose: minimizeToTrayOnClose,
                timeoutBehavior: timeoutBehavior,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workDurationMs,
                required int restDurationMs,
                required int reminderIntervalMs,
                required int reminderTimeoutMs,
                required bool androidVibrationEnabled,
                Value<bool> workReminderEnabled = const Value.absent(),
                Value<bool> restReminderEnabled = const Value.absent(),
                Value<bool> missedRestReminderEnabled = const Value.absent(),
                required String localeCode,
                required String themeModeCode,
                Value<bool> pauseWhenLocked = const Value.absent(),
                Value<bool> fixedPortraitEnabled = const Value.absent(),
                Value<bool> minimizeToTrayOnClose = const Value.absent(),
                Value<String> timeoutBehavior = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                workDurationMs: workDurationMs,
                restDurationMs: restDurationMs,
                reminderIntervalMs: reminderIntervalMs,
                reminderTimeoutMs: reminderTimeoutMs,
                androidVibrationEnabled: androidVibrationEnabled,
                workReminderEnabled: workReminderEnabled,
                restReminderEnabled: restReminderEnabled,
                missedRestReminderEnabled: missedRestReminderEnabled,
                localeCode: localeCode,
                themeModeCode: themeModeCode,
                pauseWhenLocked: pauseWhenLocked,
                fixedPortraitEnabled: fixedPortraitEnabled,
                minimizeToTrayOnClose: minimizeToTrayOnClose,
                timeoutBehavior: timeoutBehavior,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsRow,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$TimerSnapshotsTableTableCreateCompanionBuilder =
    TimerSnapshotsTableCompanion Function({
      Value<int> id,
      required String cycleId,
      required int revision,
      required String phase,
      required String executionStatus,
      required DateTime startedAtUtc,
      Value<DateTime?> deadlineAtUtc,
      Value<DateTime?> nextReminderAtUtc,
      required int workDurationMs,
      required int restDurationMs,
      required int reminderIntervalMs,
      required int reminderTimeoutMs,
      Value<String> timeoutBehavior,
    });
typedef $$TimerSnapshotsTableTableUpdateCompanionBuilder =
    TimerSnapshotsTableCompanion Function({
      Value<int> id,
      Value<String> cycleId,
      Value<int> revision,
      Value<String> phase,
      Value<String> executionStatus,
      Value<DateTime> startedAtUtc,
      Value<DateTime?> deadlineAtUtc,
      Value<DateTime?> nextReminderAtUtc,
      Value<int> workDurationMs,
      Value<int> restDurationMs,
      Value<int> reminderIntervalMs,
      Value<int> reminderTimeoutMs,
      Value<String> timeoutBehavior,
    });

class $$TimerSnapshotsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTableTable> {
  $$TimerSnapshotsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executionStatus => $composableBuilder(
    column: $table.executionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineAtUtc => $composableBuilder(
    column: $table.deadlineAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReminderAtUtc => $composableBuilder(
    column: $table.nextReminderAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerSnapshotsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTableTable> {
  $$TimerSnapshotsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executionStatus => $composableBuilder(
    column: $table.executionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineAtUtc => $composableBuilder(
    column: $table.deadlineAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReminderAtUtc => $composableBuilder(
    column: $table.nextReminderAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerSnapshotsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTableTable> {
  $$TimerSnapshotsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get executionStatus => $composableBuilder(
    column: $table.executionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadlineAtUtc => $composableBuilder(
    column: $table.deadlineAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReminderAtUtc => $composableBuilder(
    column: $table.nextReminderAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workDurationMs => $composableBuilder(
    column: $table.workDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderIntervalMs => $composableBuilder(
    column: $table.reminderIntervalMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeoutMs => $composableBuilder(
    column: $table.reminderTimeoutMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeoutBehavior => $composableBuilder(
    column: $table.timeoutBehavior,
    builder: (column) => column,
  );
}

class $$TimerSnapshotsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerSnapshotsTableTable,
          TimerSnapshotRow,
          $$TimerSnapshotsTableTableFilterComposer,
          $$TimerSnapshotsTableTableOrderingComposer,
          $$TimerSnapshotsTableTableAnnotationComposer,
          $$TimerSnapshotsTableTableCreateCompanionBuilder,
          $$TimerSnapshotsTableTableUpdateCompanionBuilder,
          (
            TimerSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $TimerSnapshotsTableTable,
              TimerSnapshotRow
            >,
          ),
          TimerSnapshotRow,
          PrefetchHooks Function()
        > {
  $$TimerSnapshotsTableTableTableManager(
    _$AppDatabase db,
    $TimerSnapshotsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerSnapshotsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerSnapshotsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TimerSnapshotsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> executionStatus = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime?> deadlineAtUtc = const Value.absent(),
                Value<DateTime?> nextReminderAtUtc = const Value.absent(),
                Value<int> workDurationMs = const Value.absent(),
                Value<int> restDurationMs = const Value.absent(),
                Value<int> reminderIntervalMs = const Value.absent(),
                Value<int> reminderTimeoutMs = const Value.absent(),
                Value<String> timeoutBehavior = const Value.absent(),
              }) => TimerSnapshotsTableCompanion(
                id: id,
                cycleId: cycleId,
                revision: revision,
                phase: phase,
                executionStatus: executionStatus,
                startedAtUtc: startedAtUtc,
                deadlineAtUtc: deadlineAtUtc,
                nextReminderAtUtc: nextReminderAtUtc,
                workDurationMs: workDurationMs,
                restDurationMs: restDurationMs,
                reminderIntervalMs: reminderIntervalMs,
                reminderTimeoutMs: reminderTimeoutMs,
                timeoutBehavior: timeoutBehavior,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cycleId,
                required int revision,
                required String phase,
                required String executionStatus,
                required DateTime startedAtUtc,
                Value<DateTime?> deadlineAtUtc = const Value.absent(),
                Value<DateTime?> nextReminderAtUtc = const Value.absent(),
                required int workDurationMs,
                required int restDurationMs,
                required int reminderIntervalMs,
                required int reminderTimeoutMs,
                Value<String> timeoutBehavior = const Value.absent(),
              }) => TimerSnapshotsTableCompanion.insert(
                id: id,
                cycleId: cycleId,
                revision: revision,
                phase: phase,
                executionStatus: executionStatus,
                startedAtUtc: startedAtUtc,
                deadlineAtUtc: deadlineAtUtc,
                nextReminderAtUtc: nextReminderAtUtc,
                workDurationMs: workDurationMs,
                restDurationMs: restDurationMs,
                reminderIntervalMs: reminderIntervalMs,
                reminderTimeoutMs: reminderTimeoutMs,
                timeoutBehavior: timeoutBehavior,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerSnapshotsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerSnapshotsTableTable,
      TimerSnapshotRow,
      $$TimerSnapshotsTableTableFilterComposer,
      $$TimerSnapshotsTableTableOrderingComposer,
      $$TimerSnapshotsTableTableAnnotationComposer,
      $$TimerSnapshotsTableTableCreateCompanionBuilder,
      $$TimerSnapshotsTableTableUpdateCompanionBuilder,
      (
        TimerSnapshotRow,
        BaseReferences<
          _$AppDatabase,
          $TimerSnapshotsTableTable,
          TimerSnapshotRow
        >,
      ),
      TimerSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$PendingCommandsTableTableCreateCompanionBuilder =
    PendingCommandsTableCompanion Function({
      Value<int> id,
      required String commandId,
      required String action,
      Value<String?> cycleId,
      Value<String?> expectedPhase,
      Value<int?> expectedRevision,
      required DateTime occurredAtUtc,
      required String payloadJson,
      Value<DateTime?> processedAtUtc,
      Value<DateTime?> staleAtUtc,
    });
typedef $$PendingCommandsTableTableUpdateCompanionBuilder =
    PendingCommandsTableCompanion Function({
      Value<int> id,
      Value<String> commandId,
      Value<String> action,
      Value<String?> cycleId,
      Value<String?> expectedPhase,
      Value<int?> expectedRevision,
      Value<DateTime> occurredAtUtc,
      Value<String> payloadJson,
      Value<DateTime?> processedAtUtc,
      Value<DateTime?> staleAtUtc,
    });

class $$PendingCommandsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingCommandsTableTable> {
  $$PendingCommandsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedPhase => $composableBuilder(
    column: $table.expectedPhase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedRevision => $composableBuilder(
    column: $table.expectedRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAtUtc => $composableBuilder(
    column: $table.processedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get staleAtUtc => $composableBuilder(
    column: $table.staleAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingCommandsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingCommandsTableTable> {
  $$PendingCommandsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandId => $composableBuilder(
    column: $table.commandId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedPhase => $composableBuilder(
    column: $table.expectedPhase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedRevision => $composableBuilder(
    column: $table.expectedRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAtUtc => $composableBuilder(
    column: $table.processedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get staleAtUtc => $composableBuilder(
    column: $table.staleAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingCommandsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingCommandsTableTable> {
  $$PendingCommandsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandId =>
      $composableBuilder(column: $table.commandId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get expectedPhase => $composableBuilder(
    column: $table.expectedPhase,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedRevision => $composableBuilder(
    column: $table.expectedRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get processedAtUtc => $composableBuilder(
    column: $table.processedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get staleAtUtc => $composableBuilder(
    column: $table.staleAtUtc,
    builder: (column) => column,
  );
}

class $$PendingCommandsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingCommandsTableTable,
          PendingCommandRow,
          $$PendingCommandsTableTableFilterComposer,
          $$PendingCommandsTableTableOrderingComposer,
          $$PendingCommandsTableTableAnnotationComposer,
          $$PendingCommandsTableTableCreateCompanionBuilder,
          $$PendingCommandsTableTableUpdateCompanionBuilder,
          (
            PendingCommandRow,
            BaseReferences<
              _$AppDatabase,
              $PendingCommandsTableTable,
              PendingCommandRow
            >,
          ),
          PendingCommandRow,
          PrefetchHooks Function()
        > {
  $$PendingCommandsTableTableTableManager(
    _$AppDatabase db,
    $PendingCommandsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingCommandsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingCommandsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingCommandsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> commandId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> cycleId = const Value.absent(),
                Value<String?> expectedPhase = const Value.absent(),
                Value<int?> expectedRevision = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime?> processedAtUtc = const Value.absent(),
                Value<DateTime?> staleAtUtc = const Value.absent(),
              }) => PendingCommandsTableCompanion(
                id: id,
                commandId: commandId,
                action: action,
                cycleId: cycleId,
                expectedPhase: expectedPhase,
                expectedRevision: expectedRevision,
                occurredAtUtc: occurredAtUtc,
                payloadJson: payloadJson,
                processedAtUtc: processedAtUtc,
                staleAtUtc: staleAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String commandId,
                required String action,
                Value<String?> cycleId = const Value.absent(),
                Value<String?> expectedPhase = const Value.absent(),
                Value<int?> expectedRevision = const Value.absent(),
                required DateTime occurredAtUtc,
                required String payloadJson,
                Value<DateTime?> processedAtUtc = const Value.absent(),
                Value<DateTime?> staleAtUtc = const Value.absent(),
              }) => PendingCommandsTableCompanion.insert(
                id: id,
                commandId: commandId,
                action: action,
                cycleId: cycleId,
                expectedPhase: expectedPhase,
                expectedRevision: expectedRevision,
                occurredAtUtc: occurredAtUtc,
                payloadJson: payloadJson,
                processedAtUtc: processedAtUtc,
                staleAtUtc: staleAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingCommandsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingCommandsTableTable,
      PendingCommandRow,
      $$PendingCommandsTableTableFilterComposer,
      $$PendingCommandsTableTableOrderingComposer,
      $$PendingCommandsTableTableAnnotationComposer,
      $$PendingCommandsTableTableCreateCompanionBuilder,
      $$PendingCommandsTableTableUpdateCompanionBuilder,
      (
        PendingCommandRow,
        BaseReferences<
          _$AppDatabase,
          $PendingCommandsTableTable,
          PendingCommandRow
        >,
      ),
      PendingCommandRow,
      PrefetchHooks Function()
    >;
typedef $$ActivityEventsTableTableCreateCompanionBuilder =
    ActivityEventsTableCompanion Function({
      required String eventId,
      required String cycleId,
      required String eventType,
      required DateTime occurredAtUtc,
      required int utcOffsetMinutes,
      required String localDateKey,
      Value<int> durationMs,
      Value<int> countValue,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableTableUpdateCompanionBuilder =
    ActivityEventsTableCompanion Function({
      Value<String> eventId,
      Value<String> cycleId,
      Value<String> eventType,
      Value<DateTime> occurredAtUtc,
      Value<int> utcOffsetMinutes,
      Value<String> localDateKey,
      Value<int> durationMs,
      Value<int> countValue,
      Value<int> rowid,
    });

class $$ActivityEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTableTable> {
  $$ActivityEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countValue => $composableBuilder(
    column: $table.countValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTableTable> {
  $$ActivityEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countValue => $composableBuilder(
    column: $table.countValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTableTable> {
  $$ActivityEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get utcOffsetMinutes => $composableBuilder(
    column: $table.utcOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countValue => $composableBuilder(
    column: $table.countValue,
    builder: (column) => column,
  );
}

class $$ActivityEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTableTable,
          ActivityEventRow,
          $$ActivityEventsTableTableFilterComposer,
          $$ActivityEventsTableTableOrderingComposer,
          $$ActivityEventsTableTableAnnotationComposer,
          $$ActivityEventsTableTableCreateCompanionBuilder,
          $$ActivityEventsTableTableUpdateCompanionBuilder,
          (
            ActivityEventRow,
            BaseReferences<
              _$AppDatabase,
              $ActivityEventsTableTable,
              ActivityEventRow
            >,
          ),
          ActivityEventRow,
          PrefetchHooks Function()
        > {
  $$ActivityEventsTableTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> utcOffsetMinutes = const Value.absent(),
                Value<String> localDateKey = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> countValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsTableCompanion(
                eventId: eventId,
                cycleId: cycleId,
                eventType: eventType,
                occurredAtUtc: occurredAtUtc,
                utcOffsetMinutes: utcOffsetMinutes,
                localDateKey: localDateKey,
                durationMs: durationMs,
                countValue: countValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String cycleId,
                required String eventType,
                required DateTime occurredAtUtc,
                required int utcOffsetMinutes,
                required String localDateKey,
                Value<int> durationMs = const Value.absent(),
                Value<int> countValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsTableCompanion.insert(
                eventId: eventId,
                cycleId: cycleId,
                eventType: eventType,
                occurredAtUtc: occurredAtUtc,
                utcOffsetMinutes: utcOffsetMinutes,
                localDateKey: localDateKey,
                durationMs: durationMs,
                countValue: countValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTableTable,
      ActivityEventRow,
      $$ActivityEventsTableTableFilterComposer,
      $$ActivityEventsTableTableOrderingComposer,
      $$ActivityEventsTableTableAnnotationComposer,
      $$ActivityEventsTableTableCreateCompanionBuilder,
      $$ActivityEventsTableTableUpdateCompanionBuilder,
      (
        ActivityEventRow,
        BaseReferences<
          _$AppDatabase,
          $ActivityEventsTableTable,
          ActivityEventRow
        >,
      ),
      ActivityEventRow,
      PrefetchHooks Function()
    >;
typedef $$ScreenActivityStateTableTableCreateCompanionBuilder =
    ScreenActivityStateTableCompanion Function({
      Value<int> id,
      required DateTime startedAtUtc,
    });
typedef $$ScreenActivityStateTableTableUpdateCompanionBuilder =
    ScreenActivityStateTableCompanion Function({
      Value<int> id,
      Value<DateTime> startedAtUtc,
    });

class $$ScreenActivityStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenActivityStateTableTable> {
  $$ScreenActivityStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreenActivityStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenActivityStateTableTable> {
  $$ScreenActivityStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreenActivityStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenActivityStateTableTable> {
  $$ScreenActivityStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );
}

class $$ScreenActivityStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenActivityStateTableTable,
          ScreenActivityStateRow,
          $$ScreenActivityStateTableTableFilterComposer,
          $$ScreenActivityStateTableTableOrderingComposer,
          $$ScreenActivityStateTableTableAnnotationComposer,
          $$ScreenActivityStateTableTableCreateCompanionBuilder,
          $$ScreenActivityStateTableTableUpdateCompanionBuilder,
          (
            ScreenActivityStateRow,
            BaseReferences<
              _$AppDatabase,
              $ScreenActivityStateTableTable,
              ScreenActivityStateRow
            >,
          ),
          ScreenActivityStateRow,
          PrefetchHooks Function()
        > {
  $$ScreenActivityStateTableTableTableManager(
    _$AppDatabase db,
    $ScreenActivityStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenActivityStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScreenActivityStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScreenActivityStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
              }) => ScreenActivityStateTableCompanion(
                id: id,
                startedAtUtc: startedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAtUtc,
              }) => ScreenActivityStateTableCompanion.insert(
                id: id,
                startedAtUtc: startedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreenActivityStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenActivityStateTableTable,
      ScreenActivityStateRow,
      $$ScreenActivityStateTableTableFilterComposer,
      $$ScreenActivityStateTableTableOrderingComposer,
      $$ScreenActivityStateTableTableAnnotationComposer,
      $$ScreenActivityStateTableTableCreateCompanionBuilder,
      $$ScreenActivityStateTableTableUpdateCompanionBuilder,
      (
        ScreenActivityStateRow,
        BaseReferences<
          _$AppDatabase,
          $ScreenActivityStateTableTable,
          ScreenActivityStateRow
        >,
      ),
      ScreenActivityStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$TimerSnapshotsTableTableTableManager get timerSnapshotsTable =>
      $$TimerSnapshotsTableTableTableManager(_db, _db.timerSnapshotsTable);
  $$PendingCommandsTableTableTableManager get pendingCommandsTable =>
      $$PendingCommandsTableTableTableManager(_db, _db.pendingCommandsTable);
  $$ActivityEventsTableTableTableManager get activityEventsTable =>
      $$ActivityEventsTableTableTableManager(_db, _db.activityEventsTable);
  $$ScreenActivityStateTableTableTableManager get screenActivityStateTable =>
      $$ScreenActivityStateTableTableTableManager(
        _db,
        _db.screenActivityStateTable,
      );
}
