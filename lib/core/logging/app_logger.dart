abstract interface class AppLogger {
  void info(String message);

  void warning(String message, {Object? error});

  void error(String message, {Object? error, StackTrace? stackTrace});
}

final class ConsoleAppLogger implements AppLogger {
  const ConsoleAppLogger();

  @override
  void info(String message) {
    // ignore: avoid_print
    print('[INFO] $message');
  }

  @override
  void warning(String message, {Object? error}) {
    // ignore: avoid_print
    print('[WARN] $message${error == null ? '' : ' ($error)'}');
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    // ignore: avoid_print
    print('[ERROR] $message${error == null ? '' : ' ($error)'}');
  }
}
