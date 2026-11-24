import 'package:flutter_test/flutter_test.dart';

import 'package:alu_market_place/core/utils/formatters.dart';

void main() {
  group('rwf', () {
    test('formats 25000 as "RWF 25,000"', () {
      expect(rwf(25000), 'RWF 25,000');
    });

    test('formats a small number with no commas', () {
      expect(rwf(500), 'RWF 500');
    });

    test('formats a large number with multiple commas', () {
      expect(rwf(1234567), 'RWF 1,234,567');
    });

    test('formats zero as "RWF 0"', () {
      expect(rwf(0), 'RWF 0');
    });
  });

  group('formatClock', () {
    test('formats time with leading zeros', () {
      expect(formatClock(DateTime(2024, 1, 1, 9, 5)), '09:05');
    });

    test('formats midnight correctly', () {
      expect(formatClock(DateTime(2024, 1, 1, 0, 0)), '00:00');
    });

    test('formats 23:59 correctly', () {
      expect(formatClock(DateTime(2024, 12, 31, 23, 59)), '23:59');
    });
  });

  group('formatWhen', () {
    final now = DateTime(2024, 6, 15, 12, 0, 0);

    test('returns "Just now" for null time', () {
      expect(formatWhen(null), 'Just now');
    });

    test('returns today with clock time', () {
      final t = DateTime(2024, 6, 15, 10, 45);
      expect(formatWhen(t, now: now), '10:45 · Today');
    });

    test('returns "Yesterday" for one day ago', () {
      final t = DateTime(2024, 6, 14, 20, 30);
      expect(formatWhen(t, now: now), 'Yesterday');
    });

    test('returns "DD Mon" for older dates', () {
      final t = DateTime(2024, 5, 10, 14, 20);
      expect(formatWhen(t, now: now), '10 May');
    });

    test('uses current time when [now] is omitted', () {
      final t = DateTime.now();
      final result = formatWhen(t);
      expect(result, contains('Today'));
    });
  });
}
