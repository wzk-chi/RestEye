import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:rest_eye/core/config/app_build.dart';
import 'package:rest_eye/infrastructure/database/tables/activity_events_table.dart';
import 'package:rest_eye/infrastructure/database/tables/app_settings_table.dart';
import 'package:rest_eye/infrastructure/database/tables/pending_commands_table.dart';
import 'package:rest_eye/infrastructure/database/tables/timer_snapshots_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AppSettingsTable,
    TimerSnapshotsTable,
    PendingCommandsTable,
    ActivityEventsTable,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open()
    : super(
        driftDatabase(
          name: AppBuild.databaseName,
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.timeoutBehavior,
        );
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.timeoutBehavior,
        );
      }
      // screen_activity_state (v3) left the managed schema when lit-screen
      // tracking was removed; existing databases keep the physical table as a
      // harmless orphan and historical screenOnInterval event rows are kept.
      if (from < 4) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.pauseWhenLocked,
        );
      }
      if (from < 5) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.fixedPortraitEnabled,
        );
      }
      if (from < 6) {
        if (from >= 4) {
          await migrator.renameColumn(
            appSettingsTable,
            'pause_when_screen_off',
            appSettingsTable.pauseWhenLocked,
          );
        }
        if (from >= 5) {
          await migrator.renameColumn(
            appSettingsTable,
            'fixed_landscape_enabled',
            appSettingsTable.fixedPortraitEnabled,
          );
        }
      }
      if (from < 7) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.minimizeToTrayOnClose,
        );
      }
      if (from < 8) {
        await migrator.dropColumn(appSettingsTable, 'auto_mode_enabled');
      }
      if (from < 9) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.workReminderEnabled,
        );
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.restReminderEnabled,
        );
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.missedRestReminderEnabled,
        );
      }
      if (from < 10) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'activity_events_local_date_key_idx '
          'ON activity_events_table (local_date_key)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'activity_events_occurred_at_idx '
          'ON activity_events_table (occurred_at_utc)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'pending_commands_status_idx '
          'ON pending_commands_table '
          '(processed_at_utc, stale_at_utc, occurred_at_utc)',
        );
      }
      if (from < 11) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.restCompletionBehavior,
        );
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.restCompletionBehavior,
        );
      }
      if (from < 12) {
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.lastHeartbeatAtUtc,
        );
      }
      if (from < 13) {
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.missedWorkReminderIntervalMs,
        );
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.restTimeoutMs,
        );
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.missedWorkReminderEnabled,
        );
        await migrator.addColumn(
          appSettingsTable,
          appSettingsTable.restTimeoutBehavior,
        );
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.missedWorkReminderIntervalMs,
        );
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.restTimeoutMs,
        );
        await migrator.addColumn(
          timerSnapshotsTable,
          timerSnapshotsTable.restTimeoutBehavior,
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
