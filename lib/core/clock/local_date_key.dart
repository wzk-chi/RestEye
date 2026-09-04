/// Local 'yyyy-MM-dd' key identifying a calendar day for statistics and
/// activity events. Callers pass a local (not UTC) date-time.
String localDateKey(DateTime localDateTime) {
  final month = localDateTime.month.toString().padLeft(2, '0');
  final day = localDateTime.day.toString().padLeft(2, '0');
  return '${localDateTime.year}-$month-$day';
}
