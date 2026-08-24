import '../models/context_tag.dart';
import '../models/glucose_entry.dart';
import '../models/targets.dart';

class Insight {
  const Insight(this.title, this.body);

  final String title;
  final String body;
}

class WeeklySummary {
  const WeeklySummary({
    required this.countThisWeek,
    required this.countPrevWeek,
    required this.daysLoggedThisWeek,
    required this.tirThisWeek,
    required this.tirPrevWeek,
    required this.fastingWeeklyAvg,
    required this.insights,
    required this.focusSuggestion,
  });

  final int countThisWeek;
  final int countPrevWeek;
  final int daysLoggedThisWeek;
  final double tirThisWeek;
  final double tirPrevWeek;
  final List<double?> fastingWeeklyAvg;
  final List<Insight> insights;
  final String focusSuggestion;
}

class TrendService {
  TrendService._();

  static bool _isFasting(GlucoseEntry e) =>
      e.tags.contains(ContextTag.fasting) ||
      (e.recordedAt.hour >= 5 && e.recordedAt.hour <= 9);

  static bool _isEvening(GlucoseEntry e) =>
      e.tags.contains(ContextTag.bedtime) || e.recordedAt.hour >= 21;

  static WeeklySummary summarize(
    List<GlucoseEntry> entries,
    GlycemicTargets t, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();

    int daysAgo(DateTime dt) {
      final d = DateTime(ref.year, ref.month, ref.day);
      return d.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    }

    bool inWindow(DateTime at, int weeksAgoStart, int weeksAgoEnd) {
      final da = daysAgo(at);
      return da >= 7 * weeksAgoStart && da < 7 * weeksAgoEnd;
    }

    final thisWeek = entries
        .where((e) => inWindow(e.recordedAt, 0, 1))
        .toList(growable: false);
    final prevWeek = entries
        .where((e) => inWindow(e.recordedAt, 1, 2))
        .toList(growable: false);

    double tirOf(List<GlucoseEntry> list) {
      if (list.isEmpty) return 0;
      final inRange =
          list.where((e) => e.inRange(t.rangeLow, t.rangeHigh)).length;
      return inRange / list.length;
    }

    final days = <String>{};
    for (final e in thisWeek) {
      days.add(
          '${e.recordedAt.year}-${e.recordedAt.month}-${e.recordedAt.day}');
    }

    final fastingAvg = <double?>[];
    for (var k = 0; k < 4; k++) {
      final wk = entries
          .where((e) => inWindow(e.recordedAt, k, k + 1))
          .where(_isFasting)
          .map((e) => e.mgdl)
          .toList(growable: false);
      fastingAvg.add(
          wk.isEmpty ? null : wk.reduce((a, b) => a + b) / wk.length);
    }

    final insights = <Insight>[];

    var risingStreak = 0;
    for (var k = 0; k + 1 < fastingAvg.length; k++) {
      final cur = fastingAvg[k];
      final prev = fastingAvg[k + 1];
      if (cur != null && prev != null && cur > prev + _minRise) {
        risingStreak++;
      } else {
        break;
      }
    }
    if (risingStreak >= 2) {
      insights.add(const Insight(
        'Morning pattern',
        'Your fasting numbers have crept up several weeks in a row. Morning '
            'values often respond to what happens the evening before \u2014 '
            'later dinners, heavier carbs, or less movement.',
      ));
    }

    final eveningHighs = thisWeek.where(_isEvening).toList();
    if (eveningHighs.length >= 3) {
      final above = eveningHighs
          .where((e) => e.mgdl > t.rangeHigh)
          .length;
      if (above / eveningHighs.length >= 0.5) {
        insights.add(Insight(
          'Evening pattern',
          'Most of your evening or bedtime readings this week were above '
              '${t.rangeHigh.toInt()} mg/dL. An after-dinner walk or shifting '
              'the last snack earlier often helps.',
        ));
      }
    }

    final postMeal = thisWeek
        .where((e) => e.tags.contains(ContextTag.afterMeal))
        .toList();
    if (postMeal.length >= 4) {
      final high = postMeal.where((e) => e.mgdl > t.rangeHigh).length;
      if (high / postMeal.length >= 0.6) {
        insights.add(const Insight(
          'After meals',
          'Most post-meal checks landed above range this week. Eating '
              'vegetables or protein first and carbs last can flatten the '
              'spike at the same meal.',
        ));
      }
    }

    if (insights.length > 3) {
      insights.removeRange(3, insights.length);
    }

    return WeeklySummary(
      countThisWeek: thisWeek.length,
      countPrevWeek: prevWeek.length,
      daysLoggedThisWeek: days.length,
      tirThisWeek: tirOf(thisWeek),
      tirPrevWeek: tirOf(prevWeek),
      fastingWeeklyAvg: fastingAvg,
      insights: insights,
      focusSuggestion: _focusFor(insights, thisWeek.length),
    );
  }

  static const int _minRise = 5;

  static String _focusFor(List<Insight> insights, int countThisWeek) {
    for (final i in insights) {
      switch (i.title) {
        case 'After meals':
          return 'One change to try: start each meal with vegetables or '
              'protein, and save the rice or bread for last.';
        case 'Evening pattern':
          return 'One change to try: a 10-minute walk after dinner this week.';
        case 'Morning pattern':
          return 'One change to try: move dinner a little earlier and add a '
              'short evening walk \u2014 then compare fasting numbers next '
              'week.';
      }
    }
    if (countThisWeek < 10) {
      return 'One change to try: add one more reading to your day. Patterns '
          'appear once there is enough data \u2014 consistency beats '
          'perfection.';
    }
    return 'One change to try: keep going exactly as you are \u2014 steady '
        'tracking is itself the win this week.';
  }
}
