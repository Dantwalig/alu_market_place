/// Formats a whole number of Rwandan francs, e.g. 25000 -> "RWF 25,000".
String rwf(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return 'RWF $b';
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatClock(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

const _months = [
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
  'Dec'
];

/// "10:45 · Today", "Yesterday" or "12 Nov". [now] is injectable for tests.
String formatWhen(DateTime? t, {DateTime? now}) {
  if (t == null) return 'Just now';
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '${formatClock(t)} · Today';
  if (diff == 1) return 'Yesterday';
  return '${t.day} ${_months[t.month - 1]}';
}
