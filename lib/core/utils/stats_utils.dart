// Utilities for simple financial stats like week-over-week calculations.

DateTime startOfWeek(DateTime dt, {int weekStartsOn = DateTime.monday}) {
  // Normalize to date only
  final d = DateTime(dt.year, dt.month, dt.day);
  // DateTime.weekday: Monday=1..Sunday=7
  final current = d.weekday;
  final delta = (current - weekStartsOn + 7) % 7; // ensure non-negative
  return d.subtract(Duration(days: delta));
}

double sumForWeek<T>(
  List<T> items,
  DateTime weekStart,
  DateTime Function(T) getDate,
  num Function(T) getAmount,
) {
  final weekEnd = weekStart.add(const Duration(days: 7));
  double total = 0.0;
  for (final item in items) {
    final d = getDate(item);
    final inRange = (d.isAtSameMomentAs(weekStart) || d.isAfter(weekStart)) && d.isBefore(weekEnd);
    if (inRange) total += getAmount(item).toDouble();
  }
  return total;
}

double percentageChange(double current, double previous) {
  if (previous == 0) {
    if (current == 0) return 0;
    return 100; // avoid division by zero: treat as +100%
  }
  return ((current - previous) / previous) * 100.0;
}

// Convenience: compute WoW percent for any list with date and amount
// now: allows deterministic testing; defaults to DateTime.now()
double weekOverWeekPercent<T>(
  List<T> items,
  DateTime Function(T) getDate,
  num Function(T) getAmount, {
  DateTime? now,
  int weekStartsOn = DateTime.monday,
}) {
  final ref = now ?? DateTime.now();
  final thisWeekStart = startOfWeek(ref, weekStartsOn: weekStartsOn);
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final sumThis = sumForWeek<T>(items, thisWeekStart, getDate, getAmount);
  final sumLast = sumForWeek<T>(items, lastWeekStart, getDate, getAmount);
  return percentageChange(sumThis, sumLast);
}
