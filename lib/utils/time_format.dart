const List<String> _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String two(int v) => v.toString().padLeft(2, '0');

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String fmtClock(DateTime dt) => '${two(dt.hour)}:${two(dt.minute)}';

String fmtDay(DateTime dt) => '${_weekdays[dt.weekday - 1]}, '
    '${_months[dt.month - 1]} ${dt.day}';

String fmtFull(DateTime dt) => '${fmtDay(dt)} \u00b7 ${fmtClock(dt)}';

String timeAgo(DateTime dt, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (isSameDay(dt, ref)) return '${diff.inHours} h ago';
  if (ref.subtract(const Duration(days: 1)).day == dt.day &&
      ref.difference(dt) < const Duration(days: 2)) {
    return 'yesterday';
  }
  return fmtDay(dt);
}
