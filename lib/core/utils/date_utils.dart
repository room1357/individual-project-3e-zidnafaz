// Pure date-related helpers for transaction grouping and labels

// Month mapping for parsing (English abbreviations -> month index)
const Map<String, int> monthAbbrToIndex = {
  'Jan': 1,
  'Feb': 2,
  'Mar': 3,
  'Apr': 4,
  'May': 5,
  'Jun': 6,
  'Jul': 7,
  'Aug': 8,
  'Sep': 9,
  'Oct': 10,
  'Nov': 11,
  'Dec': 12,
};

// Month names in Indonesian for display
const List<String> bulanId = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime parseTransactionDateTime(Map<String, dynamic> t) {
  // Expected formats: date like 'Sun, 03 Aug', time like '06:24'
  final now = DateTime.now();
  final String dateStr = (t['date'] ?? '').toString();
  final String timeStr = (t['time'] ?? '00:00').toString();

  // Extract '03 Aug' from 'Sun, 03 Aug' or fallback
  String dayMonthPart = dateStr;
  final parts = dateStr.split(', ');
  if (parts.length > 1) {
    dayMonthPart = parts[1];
  }
  final dm = dayMonthPart.trim().split(RegExp(r"\s+"));
  int day = now.day;
  int month = now.month;
  if (dm.isNotEmpty) {
    final d = int.tryParse(dm[0]);
    if (d != null) day = d;
  }
  if (dm.length > 1) {
    month = monthAbbrToIndex[dm[1]] ?? month;
  }

  // Parse time
  int hour = 0;
  int minute = 0;
  final tp = timeStr.split(':');
  if (tp.isNotEmpty) hour = int.tryParse(tp[0]) ?? 0;
  if (tp.length > 1) minute = int.tryParse(tp[1]) ?? 0;

  // Assume current year if not provided
  final year = now.year;
  return DateTime(year, month, day, hour, minute);
}

String sectionTitleForDate(DateTime date) {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  if (isSameDate(date, today)) return 'Today';
  if (isSameDate(date, yesterday)) return 'Yesterday';
  if (date.year == today.year) {
    return '${date.day} ${bulanId[date.month - 1]}';
  }
  return '${date.day} ${bulanId[date.month - 1]} ${date.year}';
}
