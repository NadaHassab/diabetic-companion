import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';

enum EscalationRung { baseline, flag, elevated, safetyCritical }

class EscalationSignal {
  final EscalationRung rung;
  final String title;
  final String body;
  final String? resourceLink;
  final String? conversationStarter;

  const EscalationSignal({
    required this.rung,
    required this.title,
    required this.body,
    this.resourceLink,
    this.conversationStarter,
  });
}

class EscalationService {
  static const _insulinSkippedThreshold = 3;
  static const _calorieFixationThreshold = 5;
  static const _missedLoggingDays = 3;
  static const _postMealAvoidanceCount = 3;

  static List<EscalationSignal> assess({
    required List<GlucoseEntry> entries,
    int lookbackDays = 28,
  }) {
    if (entries.isEmpty) return const [];

    final now = entries.last.recordedAt;
    final window = entries
        .where((e) => e.recordedAt
            .isAfter(now.subtract(Duration(days: lookbackDays))))
        .toList(growable: false);

    final signals = <EscalationSignal>[];
    var patternCount = 0;

    final insulinSkipped =
        window.where((e) => e.tags.contains(ContextTag.insulinSkipped)).toList();
    if (insulinSkipped.length >= _insulinSkippedThreshold) {
      patternCount++;
      signals.add(EscalationSignal(
        rung: EscalationRung.flag,
        title: 'Insulin logging pattern',
        body:
            'You have noted insulin was skipped on ${insulinSkipped.length} occasions. '
            'This is common and not a failure — many people with diabetes experience this. '
            'Skipping insulin can be dangerous over time. If this is intentional, please '
            'discuss with your care team. You do not have to manage this alone.',
        resourceLink: 'diabulimia-helpline',
        conversationStarter:
            'How to tell your doctor: "I have been skipping insulin sometimes and I '
            'need help figuring out why."',
      ));
    }

    final calorieEntries =
        window.where((e) => e.tags.contains(ContextTag.calorieFocus)).toList();
    if (calorieEntries.length >= _calorieFixationThreshold) {
      patternCount++;
      signals.add(EscalationSignal(
        rung: EscalationRung.flag,
        title: 'Calorie tracking focus',
        body:
            'You have logged several readings with a calorie-focus tag. This app tracks '
            'glucose, not calories. If you find yourself focusing heavily on calories '
            'alongside glucose, this may be worth discussing with your care team. '
            'You are not alone in this.',
        resourceLink: 'ned-helpline',
      ));
    }

    final loggedDates =
        window.map((e) => DateTime(e.recordedAt.year, e.recordedAt.month,
            e.recordedAt.day)).toSet();
    if (loggedDates.isNotEmpty) {
      final first = loggedDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final last = loggedDates.reduce((a, b) => a.isAfter(b) ? a : b);
      var missedDays = 0;
      for (var d = first.add(const Duration(days: 1));
          d.isBefore(last);
          d = d.add(const Duration(days: 1))) {
        if (!loggedDates.contains(d)) missedDays++;
      }
      if (missedDays >= _missedLoggingDays) {
        patternCount++;
        signals.add(EscalationSignal(
          rung: EscalationRung.flag,
          title: 'Logging gap',
          body:
              'There were $missedDays quiet days between your readings. '
              'This is information, not a judgment. Consistency helps your care team '
              'see patterns, but missing days is human. What matters is coming back.',
        ));
      }
    }

    final afterMeal =
        window.where((e) => e.tags.contains(ContextTag.afterMeal)).toList();
    final veryHigh = afterMeal.where((e) => e.mgdl > 250).toList();
    final noFollowUp = <GlucoseEntry>[];
    for (final high in veryHigh) {
      final later = window.where((e) =>
          e.recordedAt.isAfter(high.recordedAt) &&
          e.recordedAt.isBefore(high.recordedAt.add(const Duration(hours: 4))));
      if (later.isEmpty) noFollowUp.add(high);
    }
    if (noFollowUp.length >= _postMealAvoidanceCount) {
      patternCount++;
      signals.add(EscalationSignal(
        rung: EscalationRung.flag,
        title: 'Post-meal follow-up pattern',
        body:
            'You have had several high readings after meals without a follow-up check. '
            'Retesting helps you and your care team understand your response. '
            'This is not about perfection — it is about having enough information.',
      ));
    }

    final veryHighReadings =
        window.where((e) => e.mgdl >= 300).length;
    final veryLowReadings =
        window.where((e) => e.mgdl <= 54).length;
    if (veryLowReadings >= 1 || veryHighReadings >= 2) {
      signals.add(EscalationSignal(
        rung: EscalationRung.safetyCritical,
        title: 'Extreme readings detected',
        body:
            'You have had readings above 300 or below 54 mg/dL recently. These can be '
            'medically serious. If you are experiencing symptoms, please contact your '
            'care team or seek medical advice immediately.',
      ));
    }

    if (patternCount >= 2) {
      for (final s in signals) {
        if (s.rung == EscalationRung.flag) {
          signals.remove(s);
          signals.add(EscalationSignal(
            rung: EscalationRung.elevated,
            title: s.title,
            body:
                '${s.body}\n\nSince multiple patterns have been noticed, it may be '
                'helpful to speak with both your doctor and a diabetes psychologist. '
                'Here are some conversation starters:\n'
                '${s.conversationStarter ?? "I have noticed some patterns I would like to discuss."}',
            resourceLink: s.resourceLink,
            conversationStarter: s.conversationStarter,
          ));
        }
      }
    }

    return signals;
  }

  static EscalationRung overallRung(List<EscalationSignal> signals) {
    if (signals.any((s) => s.rung == EscalationRung.safetyCritical)) {
      return EscalationRung.safetyCritical;
    }
    if (signals.any((s) => s.rung == EscalationRung.elevated)) {
      return EscalationRung.elevated;
    }
    if (signals.any((s) => s.rung == EscalationRung.flag)) {
      return EscalationRung.flag;
    }
    return EscalationRung.baseline;
  }
}
