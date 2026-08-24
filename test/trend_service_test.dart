import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/targets.dart';
import 'package:diabetic_companion/models/user_profile.dart';
import 'package:diabetic_companion/services/trend_service.dart';

GlucoseEntry _mk(double v, int daysAgo,
    {int hour = 12, Set<ContextTag> tags = const {}, DateTime? now}) {
  final ref = now ?? DateTime(2026, 8, 24, 15, 0);
  return GlucoseEntry(
    id: 'e-$daysAgo-$hour',
    recordedAt: DateTime(ref.year, ref.month, ref.day - daysAgo, hour),
    mgdl: v,
    tags: tags,
  );
}

void main() {
  final ref = DateTime(2026, 8, 24, 15, 0);
  final targets = GlycemicTargets.forProfile(const UserProfile());

  group('TrendService.summarize', () {
    test('empty data returns zeroed summary', () {
      final s = TrendService.summarize([], targets, now: ref);
      expect(s.countThisWeek, 0);
      expect(s.insights, isEmpty);
    });

    test('fasting values rising 3 weeks triggers insight', () {
      final entries = [
        _mk(130, 0, hour: 6, tags: {ContextTag.fasting}, now: ref),
        _mk(115, 7, hour: 6, tags: {ContextTag.fasting}, now: ref),
        _mk(100, 14, hour: 6, tags: {ContextTag.fasting}, now: ref),
      ];
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.insights.any((i) => i.title.contains('Morning')), isTrue);
    });

    test('evening highs trigger insight', () {
      final entries = List.generate(
        4,
        (i) => _mk(220, i, hour: 22, tags: {ContextTag.bedtime}, now: ref),
      );
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.insights.any((i) => i.title.contains('Evening')), isTrue);
    });

    test('post-meal spikes trigger insight', () {
      final entries = List.generate(
        5,
        (i) => _mk(210, i, tags: {ContextTag.afterMeal}, now: ref),
      );
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.insights.any((i) => i.title.contains('meal')), isTrue);
    });

    test('daysLoggedThisWeek counts unique days', () {
      final entries = [
        _mk(100, 0, hour: 8, now: ref),
        _mk(110, 0, hour: 20, now: ref),
        _mk(120, 1, hour: 8, now: ref),
      ];
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.daysLoggedThisWeek, 2);
    });

    test('fasting weekly averages computed correctly', () {
      final entries = [
        _mk(100, 3, hour: 6, tags: {ContextTag.fasting}, now: ref),
        _mk(120, 10, hour: 6, tags: {ContextTag.fasting}, now: ref),
      ];
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.fastingWeeklyAvg.length, 4);
      expect(s.fastingWeeklyAvg[0], closeTo(100, 0.01));
      expect(s.fastingWeeklyAvg[1], closeTo(120, 0.01));
      expect(s.fastingWeeklyAvg[2], isNull);
      expect(s.fastingWeeklyAvg[3], isNull);
    });

    test('focus gives consistency nudge when count is low', () {
      final entries = [_mk(100, 0, hour: 8, now: ref)];
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.focusSuggestion.toLowerCase(), contains('one more reading'));
    });

    test('post-meal insight maps to meal sequencing focus', () {
      final entries = List.generate(
        5,
        (i) => _mk(210, i, tags: {ContextTag.afterMeal}, now: ref),
      );
      final s = TrendService.summarize(entries, targets, now: ref);
      expect(s.focusSuggestion.toLowerCase(), contains('vegetables'));
    });
  });
}
