sealed class AppFailure implements Exception {
  const AppFailure(this.code, {this.cause});

  final String code;
  final Object? cause;
}

enum ValidationFailureCode {
  workDurationOutOfRange,
  restDurationOutOfRange,
  reminderIntervalOutOfRange,
  reminderTimeoutOutOfRange,
  reminderTimeoutNotAfterInterval,
  missedWorkReminderIntervalOutOfRange,
  restTimeoutOutOfRange,
  restTimeoutNotAfterInterval,
}

final class ValidationFailure extends AppFailure {
  ValidationFailure(this.validationCode)
    : super('validation.${validationCode.name}');

  final ValidationFailureCode validationCode;
}

final class PersistenceFailure extends AppFailure {
  const PersistenceFailure(super.code, {super.cause});
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure(super.code, {super.cause});
}

final class PlatformFailure extends AppFailure {
  const PlatformFailure(super.code, {super.cause});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.code, {super.cause});
}
