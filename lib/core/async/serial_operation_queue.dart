import 'dart:async';

/// Serializes asynchronous operations: each run starts only after the
/// previous one completed, and every operation's result is delivered to its
/// own caller while the queue keeps draining after failures.
///
/// This replaces the repeated `_tail.then(...)` chaining pattern; the error
/// handling stays at the call site via the per-run [onError] callback, which
/// also keeps the queue's tail from surfacing "unhandled async error" when a
/// caller ignores the returned future.
final class SerialOperationQueue {
  Future<void> _tail = Future.value();

  /// Runs [action] after every previously enqueued operation finished.
  ///
  /// The returned future completes with the action's result or error. If the
  /// caller ignores it, [onError] (when provided) observes the failure so the
  /// queue can keep draining without an unhandled error.
  Future<T> run<T>(
    Future<T> Function() action, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    final operation = _tail.then((_) => action());
    _tail = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        onError?.call(error, stackTrace);
      },
    );
    return operation;
  }

  /// Completes when every enqueued operation has finished; await in dispose.
  Future<void> get idle => _tail;
}
