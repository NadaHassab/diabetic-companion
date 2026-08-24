import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';

enum RiskLevel { none, low, moderate, high }

class RiskSignal {
  final String title;
  final String description;
  final RiskLevel level;

  const RiskSignal({
    required this.title,
    required this.description,
    required this.level,
  });
}

class DistressService {
  static const _calorieFocusMinEntries = 5;
  static const _skippedInsulinMinDays = 3;
  static const _highLowAlternationCount = 4;
  static const _veryHighThreshold = 300;
  static const _veryLowThreshold = 54;

  static List<RiskSignal> assess({
    required List<GlucoseEntry> entries,
    int lookbackDays = 14,
  }) {
    if (entries.isEmpty) return const [];

    final now = entries.last.recordedAt;
    final window = entries
        .where((e) => e.recordedAt
            .isAfter(now.subtract(Duration(days: lookbackDays))))
        .toList(growable: false);

    final signals = <RiskSignal>[];

    final calorieEntries =
        window.where((e) => e.tags.contains(ContextTag.calorieFocus)).toList();
    if (calorieEntries.length >= _calorieFocusMinEntries) {
      signals.add(RiskSignal(
        title: 'Calorie tracking pattern',
        description:
            'You have logged several readings with a calorie-focus tag. '
            'This app tracks glucose, not calories. If you find yourself '
            'focusing heavily on calories alongside glucose, consider '
            'speaking with your care team.',
        level: RiskLevel.low,
      ));
    }

    final insulinSkipped =
        window.where((e) => e.tags.contains(ContextTag.insulinSkipped)).toList();
    if (insulinSkipped.length >= _skippedInsulinMinDays) {
      signals.add(RiskSignal(
        title: 'Insulin logging pattern',
        description:
            'You have noted insulin was skipped on several days. Skipping '
            'insulin can be dangerous. If this is intentional, please '
            'discuss with your doctor. If not, consider logging insulin '
            'regularly so your patterns are visible.',
        level: RiskLevel.moderate,
      ));
    }

    var highLowSwings = 0;
    for (var i = 1; i < window.length; i++) {
      final prev = window[i - 1];
      final cur = window[i];
      if ((prev.mgdl > 200 && cur.mgdl < 70) ||
          (prev.mgdl < 70 && cur.mgdl > 200)) {
        highLowSwings++;
      }
    }
    if (highLowSwings >= _highLowAlternationCount) {
      signals.add(RiskSignal(
        title: 'Glucose swings',
        description:
            'Frequent highs and lows alternating can be physically and '
            'emotionally exhausting. This pattern is worth discussing '
            'with your care team — you do not have to manage it alone.',
        level: RiskLevel.moderate,
      ));
    }

    final veryHigh =
        window.where((e) => e.mgdl >= _veryHighThreshold).length;
    final veryLow =
        window.where((e) => e.mgdl <= _veryLowThreshold).length;
    if (veryHigh >= 2 || veryLow >= 2) {
      signals.add(RiskSignal(
        title: 'Extreme readings',
        description:
            'You have had readings above 300 or below 54 mg/dL. These '
            'can be serious. If you are experiencing symptoms, please '
            'contact your care team or seek medical advice.',
        level: RiskLevel.high,
      ));
    }

    final fastingEntries =
        window.where((e) => e.tags.contains(ContextTag.fasting)).toList();
    final fastingLows =
        fastingEntries.where((e) => e.mgdl < 70).length;
    if (fastingLows >= 3 && fastingEntries.length >= 3) {
      signals.add(RiskSignal(
        title: 'Fasting lows',
        description:
            'Multiple low fasting readings may indicate your overnight '
            'or pre-meal insulin is too high, or dinner was insufficient. '
            'This pattern needs attention from your care team.',
        level: RiskLevel.high,
      ));
    }

    return signals;
  }

  static RiskLevel overallRisk(List<RiskSignal> signals) {
    if (signals.any((s) => s.level == RiskLevel.high)) return RiskLevel.high;
    if (signals.any((s) => s.level == RiskLevel.moderate)) {
      return RiskLevel.moderate;
    }
    if (signals.any((s) => s.level == RiskLevel.low)) return RiskLevel.low;
    return RiskLevel.none;
  }
}
