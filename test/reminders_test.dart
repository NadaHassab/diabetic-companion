import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/medication.dart';
import 'package:diabetic_companion/services/reminders_service.dart';

GlucoseEntry _mk(double v, int minutesAgo,
    {Set<ContextTag> tags = const {}, DateTime? now}) {
  final ref = now ?? DateTime(2026, 8, 24, 15, 0);
  return GlucoseEntry(
    id: 'e$minutesAgo',
    recordedAt: ref.subtract(Duration(minutes: minutesAgo)),
    mgdl: v,
    tags: tags,
  );
}

Medication _med(String id, String name, List<String> times) =>
    Medication(id: id, name: name, times: times);

MedIntake _intake(String medId, {int minutesAgo = 0, DateTime? now}) {
  final ref = now ?? DateTime(2026, 8, 24, 15, 0);
  return MedIntake(
    id: 'i-$medId-$minutesAgo',
    medicationId: medId,
    takenAt: ref.subtract(Duration(minutes: minutesAgo)),
  );
}

void main() {
  final ref = DateTime(2026, 8, 24, 15, 0);

  group('RemindersService.dueNow', () {
    test('medication due when past slot and not taken', () {
      final meds = [_med('m1', 'Metformin', ['08:00', '20:00'])];
      final due = RemindersService.dueNow(
        medications: meds,
        intakes: const [],
        entries: const [],
        now: ref,
      );
      expect(due.length, 1);
      expect(due.first.title, 'Metformin');
      expect(due.first.kind, DueKind.medication);
    });

    test('medication not due before slot', () {
      final meds = [_med('m1', 'Metformin', ['20:00'])];
      final due = RemindersService.dueNow(
        medications: meds,
        intakes: const [],
        entries: const [],
        now: ref,
      );
      expect(due, isEmpty);
    });

    test('medication not due when already taken', () {
      final meds = [_med('m1', 'Metformin', ['08:00'])];
      final intakes = [_intake('m1', now: ref)];
      final due = RemindersService.dueNow(
        medications: meds,
        intakes: intakes,
        entries: const [],
        now: ref,
      );
      expect(due, isEmpty);
    });

    test('retest due when pre-meal entry is 2h ago', () {
      final entries = [_mk(120, 120, tags: {ContextTag.beforeMeal}, now: ref)];
      final due = RemindersService.dueNow(
        medications: const [],
        intakes: const [],
        entries: entries,
        now: ref,
      );
      expect(due.length, 1);
      expect(due.first.kind, DueKind.retest);
    });

    test('retest not due when pre-meal entry is 30min ago', () {
      final entries = [_mk(120, 30, tags: {ContextTag.beforeMeal}, now: ref)];
      final due = RemindersService.dueNow(
        medications: const [],
        intakes: const [],
        entries: entries,
        now: ref,
      );
      expect(due, isEmpty);
    });

    test('retest not due when later entry exists', () {
      final entries = [
        _mk(120, 150, tags: {ContextTag.beforeMeal}, now: ref),
        _mk(150, 60, tags: {ContextTag.afterMeal}, now: ref),
      ];
      final due = RemindersService.dueNow(
        medications: const [],
        intakes: const [],
        entries: entries,
        now: ref,
      );
      expect(due, isEmpty);
    });

    test('multiple meds and retest combine', () {
      final meds = [_med('m1', 'Metformin', ['08:00'])];
      final entries = [_mk(120, 120, tags: {ContextTag.beforeMeal}, now: ref)];
      final due = RemindersService.dueNow(
        medications: meds,
        intakes: const [],
        entries: entries,
        now: ref,
      );
      expect(due.length, 2);
    });
  });
}
