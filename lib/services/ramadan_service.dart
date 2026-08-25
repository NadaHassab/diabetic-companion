import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/targets.dart';

class RamadanGuidance {
  final String title;
  final String body;
  final GuidanceKind kind;

  const RamadanGuidance({
    required this.title,
    required this.body,
    required this.kind,
  });
}

enum GuidanceKind { suhoor, iftar, hypoWatch, medAdjust, general }

class RamadanService {
  static const _hypoWatchWindowMinutes = 30;
  static const _fastingHypoThreshold = 70;
  static const _iftarTimeHour = 18; // approximate, user can adjust
  static const _suhoorTimeHour = 4; // approximate

  /// Check if current time is during typical fasting hours (suhoor to iftar)
  static bool isFastingHour({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    return hour >= _suhoorTimeHour && hour < _iftarTimeHour;
  }

  /// Get time until next iftar or suhoor
  static ({String label, Duration remaining}) nextMeal({DateTime? now}) {
    final dt = now ?? DateTime.now();
    final iftar = DateTime(dt.year, dt.month, dt.day, _iftarTimeHour);
    final suhoor = DateTime(dt.year, dt.month, dt.day + 1, _suhoorTimeHour);

    if (dt.isBefore(iftar)) {
      return (label: 'Iftar', remaining: iftar.difference(dt));
    }
    return (label: 'Suhoor', remaining: suhoor.difference(dt));
  }

  static List<RamadanGuidance> suhoorGuidance({
    required GlycemicTargets targets,
    List<GlucoseEntry>? recentEntries,
  }) {
    final list = <RamadanGuidance>[
      const RamadanGuidance(
        title: 'Suhoor meal',
        body:
            'Eat complex carbs (oats, bulgur, whole-wheat bread) with protein '
            '(eggs, labneh, foul). This combination digests slowly and keeps '
            'glucose steadier through the long fast.',
        kind: GuidanceKind.suhoor,
      ),
      const RamadanGuidance(
        title: 'Hydration',
        body:
            'Drink plenty of water between iftar and suhoor. Dehydration '
            'can raise blood glucose concentration and make you feel worse.',
        kind: GuidanceKind.suhoor,
      ),
    ];

    if (recentEntries != null && recentEntries.isNotEmpty) {
      final lastEntry = recentEntries.last;
      if (lastEntry.mgdl > targets.rangeHigh) {
        list.add(const RamadanGuidance(
          title: 'High fasting reading',
          body:
              'Your last reading was elevated. At suhoor, try a lighter carb '
              'portion with extra protein and vegetables. A short walk after '
              'eating can help too.',
          kind: GuidanceKind.suhoor,
        ));
      }
    }

    return list;
  }

  static List<RamadanGuidance> iftarGuidance({
    required GlycemicTargets targets,
    List<GlucoseEntry>? recentEntries,
  }) {
    final list = <RamadanGuidance>[
      const RamadanGuidance(
        title: 'Breaking the fast',
        body:
            'Start with dates and water (2\u20133 dates = ~15 g carbs). '
            'Then pray/rest 10\u201315 minutes before the main meal. '
            'This prevents a rapid carb spike.',
        kind: GuidanceKind.iftar,
      ),
      const RamadanGuidance(
        title: 'Meal order matters',
        body:
            'Eat soup or salad first, then protein (grilled meat/fish), '
            'then the starchy dish last. This "reverse order" can reduce '
            'your post-meal spike by up to 40%.',
        kind: GuidanceKind.iftar,
      ),
      const RamadanGuidance(
        title: 'Watch your portions',
        body:
            'It is tempting to eat a lot after a long fast, but large meals '
            'cause bigger spikes. Use a normal plate: half vegetables, '
            'quarter protein, quarter carbs.',
        kind: GuidanceKind.iftar,
      ),
      const RamadanGuidance(
        title: 'Walk after iftar',
        body:
            'A 15\u201320 minute walk after iftar is one of the most '
            'effective ways to lower your post-meal reading. Even walking '
            'inside your home counts.',
        kind: GuidanceKind.iftar,
      ),
    ];

    if (recentEntries != null && recentEntries.isNotEmpty) {
      final lastEntry = recentEntries.last;
      if (lastEntry.mgdl < targets.rangeLow) {
        list.add(const RamadanGuidance(
          title: 'Low reading before iftar',
          body:
              'If you feel low before it is time to break your fast, '
              'it is medically acceptable to break early with glucose '
              'tablets or juice. Your safety comes first.',
          kind: GuidanceKind.hypoWatch,
        ));
      }
    }

    return list;
  }

  static RamadanGuidance? hypoWatchAlert({
    required List<GlucoseEntry> entries,
    required GlycemicTargets targets,
  }) {
    if (entries.isEmpty) return null;

    final recent = entries
        .where((e) =>
            DateTime.now().difference(e.recordedAt).inMinutes <=
            _hypoWatchWindowMinutes)
        .toList();

    final lows = recent.where((e) => e.mgdl < _fastingHypoThreshold).toList();
    if (lows.length >= 2) {
      return const RamadanGuidance(
        title: 'Low readings during fast',
        body:
            'You have had multiple low readings recently. If you feel shaky, '
            'sweaty, or confused, break your fast immediately with fast-acting '
            'carbs. Safety comes before fasting. Talk to your care team about '
            'adjusting your medication during Ramadan.',
        kind: GuidanceKind.hypoWatch,
      );
    }

    return null;
  }

  static RamadanGuidance? medAdjustReminder({
    required List<GlucoseEntry> entries,
    required GlycemicTargets targets,
  }) {
    if (entries.isEmpty) return null;

    final lastThreeDays = entries
        .where((e) =>
            DateTime.now().difference(e.recordedAt).inDays <= 3)
        .toList();

    final lows = lastThreeDays.where((e) => e.mgdl < targets.rangeLow).toList();
    if (lows.length >= 3) {
      return const RamadanGuidance(
        title: 'Medication review',
        body:
            'You have had several low readings in the past few days while '
            'fasting. This may mean your medication dose needs adjusting for '
            'Ramadan. Please contact your healthcare provider \u2014 do not '
            'change doses on your own.',
        kind: GuidanceKind.medAdjust,
      );
    }

    return null;
  }

  static RamadanGuidance generalTips() => const RamadanGuidance(
        title: 'Ramadan and diabetes',
        body:
            'Fasting during Ramadan is possible for many people with diabetes, '
            'but it requires extra attention. Key rules:\n'
            '\u2022 Monitor glucose more often (before suhoor, iftar, and bedtime)\n'
            '\u2022 Keep fast-acting carbs with you at all times\n'
            '\u2022 Stay hydrated between iftar and suhoor\n'
            '\u2022 Do not skip meals \u2014 eat at suhoor and iftar\n'
            '\u2022 If you feel unwell, break your fast and seek medical advice',
        kind: GuidanceKind.general,
      );
}
