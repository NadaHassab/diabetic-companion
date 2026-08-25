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
            'You have logged $streakDays days in a row. Tracking itself is the win \u2014 '
            'not any particular number. Blood sugar is information, not a grade.',
        kind: FeedbackKind.compassion,
      );
    }

    return null;
  }

  static FeedbackMessage? learningMoment({
    required GlucoseEntry entry,
    required GlycemicTargets targets,
    List<GlucoseEntry>? recentEntries,
  }) {
    // --- Post-meal high ---
    if (entry.mgdl > targets.rangeHigh &&
        entry.tags.contains(ContextTag.afterMeal)) {
      return FeedbackMessage(
        title: 'Post-meal spike',
        body:
            'A higher reading after a meal is common \u2014 it does not mean you failed. '
            'Two things to try:\n'
            '\u2022 Eat vegetables or protein before carbs (the "salad first" trick).\n'
            '\u2022 A 10-minute walk after eating can lower the spike.',
        kind: FeedbackKind.learning,
      );
    }

    if (entry.mgdl > targets.rangeHigh) {
      return FeedbackMessage(
        title: 'Higher reading',
        body:
            'A reading above your range is information, not a verdict. '
            'Common reasons: less activity than usual, stress, a larger portion, '
            'or illness starting. If you see this pattern repeatedly, '
            'your care team can help adjust.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Low reading ---
    if (entry.mgdl < targets.rangeLow) {
      return FeedbackMessage(
        title: 'Low reading',
        body:
            'A reading below ${targets.rangeLow.toInt()} mg/dL is your body telling you '
            'it needs fuel. If you feel symptoms, follow the 15-15 rule: '
            '15 g fast-acting carbs (juice, glucose tablets), wait 15 minutes, re-check. '
            'After recovery, a small snack with protein helps prevent another drop.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Exercise effect ---
    if (entry.tags.contains(ContextTag.exercise)) {
      return FeedbackMessage(
        title: 'Activity and glucose',
        body:
            'Physical activity can lower glucose for several hours after '
            'you stop. If you have a lower-than-usual reading after exercise, '
            'this is likely a normal response. A small snack before activity '
            'can help if you tend to drop.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Stress effect ---
    if (entry.tags.contains(ContextTag.stress)) {
      return FeedbackMessage(
        title: 'Stress and glucose',
        body:
            'Stress hormones can raise blood sugar \u2014 a higher reading during '
            'a stressful time is your body\'s normal response, not a failure. '
            'Focus on managing the stress; the glucose often follows.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Fasting low pattern ---
    if (entry.tags.contains(ContextTag.fasting) &&
        entry.mgdl < targets.rangeLow) {
      return FeedbackMessage(
        title: 'Fasting low',
        body:
            'A low fasting reading may mean your overnight or pre-meal '
            'insulin/medication is a bit much, or dinner was lighter than usual. '
            'This is a pattern to discuss with your care team, not a failure.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Sick day ---
    if (entry.tags.contains(ContextTag.sickDay)) {
      return FeedbackMessage(
        title: 'Illness and glucose',
        body:
            'Being sick can raise blood sugar unpredictably, even if you '
            'are eating less. Check more often, stay hydrated, and contact '
            'your care team if readings stay above 250 or you have ketone symptoms.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Insulin skipped ---
    if (entry.tags.contains(ContextTag.insulinSkipped)) {
      return FeedbackMessage(
        title: 'Insulin and glucose',
        body:
            'Missing a dose can cause readings to climb. If this is intentional, '
            'that is okay \u2014 your reasons are valid. If it keeps happening, '
            'talking to your care team about what makes it hard can help.',
        kind: FeedbackKind.learning,
      );
    }

    // --- Rising pattern over multiple entries ---
    if (recentEntries != null && recentEntries.length >= 5) {
      final last5 = recentEntries.take(5).toList();
      final allRising = last5.asMap().entries.every((e) {
        if (e.key == 0) return true;
        return e.value.mgdl > last5[e.key - 1].mgdl;
      });
      if (allRising) {
        return FeedbackMessage(
          title: 'Rising trend noticed',
          body:
              'Your last few readings have been climbing. This can happen '
              'with illness, stress, medication changes, or a food pattern. '
              'It is not a judgment \u2014 it is a signal your care team '
              'can help you interpret.',
          kind: FeedbackKind.learning,
        );
      }
    }

    return null;
  }
}
