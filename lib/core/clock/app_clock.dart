abstract interface class AppClock {
  DateTime get utcNow;

  Duration get elapsed;
}
