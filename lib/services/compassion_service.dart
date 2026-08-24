import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/targets.dart';

class FeedbackMessage {
  final String title;
  final String body;
  final FeedbackKind kind;

  const FeedbackMessage({
    required this.title,
    required this.body,
    required this.kind,
  });
}

enum FeedbackKind { compassion, learning, distressCheck }

class CompassionService {
  static const _consistentDaysThreshold = 3;
  static const _lowReadingDays = 3;

  static FeedbackMessage? feedbackForEntry({
    required GlucoseEntry entry,
    required List<GlucoseEntry> allEntries,
    required GlycemicTargets targets,
    required int streakDays,
  }) {
    final recent = allEntries
        .where((e) => e.recordedAt.isAfter(
            entry.recordedAt.subtract(const Duration(days: 2))))
        .toList();

    final lowCount =
        recent.where((e) => e.mgdl < targets.rangeLow).length;

    if (lowCount >= _lowReadingDays) {
      return FeedbackMessage(
        title: 'Pattern noticed',
        body:
            'You have had several low readings recently. This is information, '
            'not a judgment. Consider reviewing your meals or activity with your care team.',
        kind: FeedbackKind.distressCheck,
      );
    }

    if (streakDays >= _consistentDaysThreshold) {
      return FeedbackMessage(
        title: 'Consistency noticed',
        body:
            'You have logged $streakDays days in a row. Tracking itself is the win — '
            'not any particular number. Blood sugar is information, not a grade.',
        kind: FeedbackKind.compassion,
      );
    }

    return null;
  }

  static FeedbackMessage? learningMoment({
    required GlucoseEntry entry,
    required GlycemicTargets targets,
  }) {
    if (entry.mgdl > targets.rangeHigh) {
      return FeedbackMessage(
        title: 'After-meal pattern',
        body:
            'A higher reading after a meal is common and does not mean you failed. '
            'Consider: did you eat carbohydrates first? Eating vegetables or protein '
            'before carbs may help reduce spikes. This is one experiment, not a rule.',
        kind: FeedbackKind.learning,
      );
    }

    if (entry.mgdl < targets.rangeLow) {
      return FeedbackMessage(
        title: 'Low reading',
        body:
            'A reading below ${targets.rangeLow} mg/dL is your body telling you '
            'it needs fuel. If you feel symptoms, follow the 15-15 rule: '
            '15 g fast-acting carbs, wait 15 minutes, re-check.',
        kind: FeedbackKind.learning,
      );
    }

    if (entry.tags.contains(ContextTag.exercise)) {
      return FeedbackMessage(
        title: 'Activity and glucose',
        body:
            'Physical activity can lower glucose for several hours after. '
            'If you have a lower-than-usual reading after exercise, this may '
            'be the reason — it is a normal response.',
        kind: FeedbackKind.learning,
      );
    }

    if (entry.tags.contains(ContextTag.stress)) {
      return FeedbackMessage(
        title: 'Stress and glucose',
        body:
            'Stress hormones can raise blood sugar. A higher reading during '
            'a stressful time is your body\'s normal response, not a failure. '
            'Focus on managing the stress — the glucose often follows.',
        kind: FeedbackKind.learning,
      );
    }

    return null;
  }
}
