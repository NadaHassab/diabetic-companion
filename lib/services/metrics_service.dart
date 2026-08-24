import 'dart:math' as math;

import '../models/glucose_entry.dart';
import '../models/targets.dart';

class GlucoseStats {
  const GlucoseStats({
    required this.count,
    required this.meanMgdl,
    required this.gmiPercent,
    required this.cvPercent,
    required this.inRangeFraction,
    required this.belowFraction,
    required this.severeLowFraction,
    required this.aboveFraction,
    required this.urgentHighFraction,
  });

  final int count;
  final double meanMgdl;
  final double? gmiPercent;
  final double? cvPercent;
  final double inRangeFraction;
  final double belowFraction;
  final double severeLowFraction;
  final double aboveFraction;
  final double urgentHighFraction;

  factory GlucoseStats.empty() => const GlucoseStats(
        count: 0,
        meanMgdl: 0,
        gmiPercent: null,
        cvPercent: null,
        inRangeFraction: 0,
        belowFraction: 0,
        severeLowFraction: 0,
        aboveFraction: 0,
        urgentHighFraction: 0,
      );

  static GlucoseStats compute(List<GlucoseEntry> entries, GlycemicTargets t) {
    if (entries.isEmpty) return GlucoseStats.empty();
    final vals = entries.map((e) => e.mgdl).toList(growable: false);
    final n = vals.length;
    final mean = vals.reduce((a, b) => a + b) / n;

    var below = 0;
    var severeLow = 0;
    var above = 0;
    var urgentHigh = 0;
    for (final v in vals) {
      if (v < t.rangeLow) below++;
      if (v < GlycemicTargets.hypoLevel2) severeLow++;
      if (v > t.rangeHigh) above++;
      if (v >= GlycemicTargets.ketoneAlert) urgentHigh++;
    }

    double? cv;
    if (n >= 2 && mean > 0) {
      final varSum =
          vals.fold<double>(0, (acc, v) => acc + (v - mean) * (v - mean));
      final sd = math.sqrt(varSum / (n - 1));
      cv = sd / mean * 100;
    }

    final gmi = 3.31 + 0.02392 * mean;

    return GlucoseStats(
      count: n,
      meanMgdl: mean,
      gmiPercent: gmi,
      cvPercent: cv,
      inRangeFraction: (n - below - above) / n,
      belowFraction: below / n,
      severeLowFraction: severeLow / n,
      aboveFraction: above / n,
      urgentHighFraction: urgentHigh / n,
    );
  }
}

class MetricsService {
  MetricsService._();

  static GlucoseStats statsFor(
    List<GlucoseEntry> entries,
    GlycemicTargets targets,
  ) =>
      GlucoseStats.compute(entries, targets);

  static List<GlucoseEntry> inLast(
    List<GlucoseEntry> entries,
    Duration d, {
    DateTime? now,
  }) =>
      entries
          .where((e) => (now ?? DateTime.now()).difference(e.recordedAt) <= d)
          .toList();
}
