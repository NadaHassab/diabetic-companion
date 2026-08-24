import '../models/context_tag.dart';
import '../models/glucose_entry.dart';
import '../models/medication.dart';

enum DueKind { medication, retest }

class DueItem {
  const DueItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final DueKind kind;
  final String id;
  final String title;
  final String subtitle;
}

class RemindersService {
  RemindersService._();

  static List<DueItem> dueNow({
    required List<Medication> medications,
    required List<MedIntake> intakes,
    required List<GlucoseEntry> entries,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final items = <DueItem>[];

    for (final med in medications) {
      for (final t in med.times) {
        final slot = _slotToday(t, ref);
        if (slot == null) continue;
        if (ref.isBefore(slot)) continue;
        final taken = intakes.any(
          (i) => i.medicationId == med.id && !i.takenAt.isBefore(slot),
        );
        if (taken) continue;
        items.add(DueItem(
          kind: DueKind.medication,
          id: '${med.id}|$t',
          title: med.name,
          subtitle: 'Scheduled for $t \u00b7 due since ${_fmt(slot)}',
        ));
      }
    }

    final preMeal = _latestPreMeal(entries);
    if (preMeal != null) {
      final age = ref.difference(preMeal.recordedAt);
      if (!age.isNegative &&
          age >= const Duration(minutes: 90) &&
          age <= const Duration(minutes: 240)) {
        final hasLater = entries.any(
          (e) => e.recordedAt.isAfter(preMeal.recordedAt),
        );
        if (!hasLater) {
          final hours = age.inMinutes ~/ 60;
          final mins = age.inMinutes % 60;
          items.add(DueItem(
            kind: DueKind.retest,
            id: 'retest-${preMeal.id}',
            title: 'Post-meal check-in',
            subtitle: 'Your pre-meal reading was '
                '${hours}h ${mins.toString().padLeft(2, '0')}m ago \u2014 a '
                '2-hour check shows how that meal landed.',
          ));
        }
      }
    }

    return items;
  }

  static DateTime? _slotToday(String hhmm, DateTime ref) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return DateTime(ref.year, ref.month, ref.day, h, m);
  }

  static GlucoseEntry? _latestPreMeal(List<GlucoseEntry> entries) {
    for (final e in entries) {
      if (e.tags.contains(ContextTag.beforeMeal)) return e;
    }
    return null;
  }

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
