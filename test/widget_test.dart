import 'package:flutter_test/flutter_test.dart';

import 'package:alu_market_place/core/utils/formatters.dart';

void main() {
  testWidgets('formatters are exercised via widget test smoke test',
      (WidgetTester tester) async {
    // Smoke test: ensure the formatter functions are reachable and correct.
    expect(rwf(25000), 'RWF 25,000');
    expect(formatClock(DateTime(2024, 1, 1, 9, 5)), '09:05');
    expect(
      formatWhen(DateTime(2024, 6, 15, 10, 45), now: DateTime(2024, 6, 15, 12, 0)),
      '10:45 · Today',
    );
  });
}
