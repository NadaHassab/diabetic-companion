import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/services/escalation_service.dart';

GlucoseEntry _mk(
  double v,
  int daysAgo, {
  Set<ContextTag> tags = const {},
  int hour = 12,
}) {
  final ref = DateTime(2026, 8, 24, 15, 0);
  return GlucoseEntry(
    id: 'e-$v-$daysAgo-$hour-${tags.hashCode}',
    recordedAt: DateTime(ref.year, ref.month, ref.day - daysAgo, hour),
    mgdl: v,
    tags: tags,
  );
}

void main() {
  group('EscalationService.assess', () {
    test('empty entries produce no signals', () {
      final signals = EscalationService.assess(entries: []);
      expect(signals, isEmpty);
      expect(
          EscalationService.overallRung(signals), EscalationRung.baseline);
    });

    test('clean data produces no signals', () {
      final entries = List.generate(
        10,
        (i) => _mk(110, i % 14),
      );
      final signals = EscalationService.assess(entries: entries);
      expect(signals, isEmpty);
    });

    test('3 skipped insulins flag insulin pattern', () {
      final entries = [
        for (var d = 0; d < 14; d++)
          _mk(140, d),
        _mk(180, 1, tags: {ContextTag.insulinSkipped}),
        _mk(200, 4, tags: {ContextTag.insulinSkipped}),
        _mk(190, 8, tags: {ContextTag.insulinSkipped}),
      ];
      final signals = EscalationService.assess(entries: entries);
      expect(
          signals.any((s) => s.title == 'Insulin logging pattern'), isTrue);
      expect(EscalationService.overallRung(signals), EscalationRung.flag);
    });

    test('2 skipped insulins do not trigger', () {
      final entries = [
        _mk(180, 1, tags: {ContextTag.insulinSkipped}),
        _mk(200, 4, tags: {ContextTag.insulinSkipped}),
      ];
      final signals = EscalationService.assess(entries: entries);
      expect(signals.any((s) => s.title == 'Insulin logging pattern'), isFalse);
    });

    test('5 calorie-focus tags flag calorie fixation', () {
      final entries = List.generate(
        5,
        (i) => _mk(100.0 + i, i * 2, tags: {ContextTag.calorieFocus}),
      );
      final signals = EscalationService.assess(entries: entries);
      expect(
          signals.any((s) => s.title == 'Calorie tracking focus'), isTrue);
    });

    test('two patterns escalate to elevated rung with talking points', () {
      final entries = [
        _mk(180, 1, tags: {ContextTag.insulinSkipped}),
        _mk(200, 2, tags: {ContextTag.insulinSkipped}),
        _mk(190, 3, tags: {ContextTag.insulinSkipped}),
        _mk(100, 4, tags: {ContextTag.calorieFocus}),
        _mk(101, 5, tags: {ContextTag.calorieFocus}),
        _mk(102, 6, tags: {ContextTag.calorieFocus}),
        _mk(103, 7, tags: {ContextTag.calorieFocus}),
        _mk(104, 8, tags: {ContextTag.calorieFocus}),
      ];
      final signals = EscalationService.assess(entries: entries);
      expect(
          signals.where((s) => s.rung == EscalationRung.elevated).length,
          greaterThanOrEqualTo(1));
      expect(EscalationService.overallRung(signals), EscalationRung.elevated);
    });

    test('extreme readings are safety-critical regardless of patterns', () {
      final entries = [
        _mk(320, 0),
        _mk(45, 2),
      ];
      final signals = EscalationService.assess(entries: entries);
      expect(EscalationService.overallRung(signals),
          EscalationRung.safetyCritical);
      expect(
          signals.any((s) => s.title == 'Extreme readings detected'), isTrue);
    });

    test('repeated post-meal highs without follow-up flag avoidance', () {
      final entries = [
        _mk(260, 1, hour: 18, tags: {ContextTag.afterMeal}),
        _mk(270, 3, hour: 18, tags: {ContextTag.afterMeal}),
        _mk(265, 5, hour: 18, tags: {ContextTag.afterMeal}),
      ];
      final signals = EscalationService.assess(entries: entries);
      expect(
          signals.any((s) => s.title == 'Post-meal follow-up pattern'),
          isTrue);
    });
  });
}
