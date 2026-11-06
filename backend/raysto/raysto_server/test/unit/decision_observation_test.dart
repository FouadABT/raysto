import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test('seven complete venue days span a DST change without losing a day', () {
    final p = DecisionObservationPeriod(
      DateTime.parse('2026-03-01T17:30:00Z'),
      DateTime.parse('2026-03-09T15:00:00Z'),
      'America/New_York',
    );
    expect(p.beforeStart!.toUtc(), DateTime.parse('2026-02-22T05:00:00Z'));
    expect(p.afterStart!.toUtc(), DateTime.parse('2026-03-02T05:00:00Z'));
    expect(p.afterEnd!.toUtc(), DateTime.parse('2026-03-09T04:00:00Z'));
    expect(p.afterEnd!.difference(p.afterStart!).inHours, 167);
    expect(p.elapsedCompleteDays, 7);
  });
  test(
    'publication day is excluded and incomplete current day is not counted',
    () {
      final same = DecisionObservationPeriod(
        DateTime.parse('2026-11-06T10:00:00Z'),
        DateTime.parse('2026-11-06T23:30:00Z'),
        'Africa/Casablanca',
      );
      expect(same.elapsedCompleteDays, 0);
      expect(same.observedEnd, same.afterStart);
      final next = DecisionObservationPeriod(
        DateTime.parse('2026-11-06T10:00:00Z'),
        DateTime.parse('2026-11-08T10:00:00Z'),
        'Africa/Casablanca',
      );
      expect(next.elapsedCompleteDays, 1);
    },
  );
  test('unpublished decision has no observation period', () {
    final p = DecisionObservationPeriod(null, DateTime.utc(2026, 11, 6), 'UTC');
    expect(p.beforeStart, null);
    expect(p.afterStart, null);
    expect(p.elapsedCompleteDays, 0);
  });
}
