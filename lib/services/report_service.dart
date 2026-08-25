import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/medication.dart';
import 'package:diabetic_companion/models/targets.dart';
import 'package:diabetic_companion/services/trend_service.dart';

class ReportData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int count;
  final double? mean;
  final double? gmi;
  final double? cv;
  final double tirPercent;
  final double tbrPercent;
  final double tarPercent;
  final int hypoEvents;
  final int hyperEvents;
  final int severeHypoEvents;
  final int fastingCount;
  final double? fastingMean;
  final int daysLogged;
  final int totalDays;
  final String stratumLabel;
  final List<Insight> insights;
  final String focusSuggestion;
  final List<String> medicationAdherence;
  final List<MapEntry<String, int>> tagCounts;

  const ReportData({
    required this.periodStart,
    required this.periodEnd,
    required this.count,
    this.mean,
    this.gmi,
    this.cv,
    required this.tirPercent,
    required this.tbrPercent,
    required this.tarPercent,
    required this.hypoEvents,
    required this.hyperEvents,
    required this.severeHypoEvents,
    required this.fastingCount,
    this.fastingMean,
    required this.daysLogged,
    required this.totalDays,
    required this.stratumLabel,
    required this.insights,
    required this.focusSuggestion,
    required this.medicationAdherence,
    required this.tagCounts,
  });
}

class ReportService {
  static ReportData generate({
    required List<GlucoseEntry> entries,
    required GlycemicTargets targets,
    required List<Medication> medications,
    required List<MedIntake> intakes,
    DateTime? now,
    int periodDays = 14,
  }) {
    final ref = now ?? DateTime.now();
    final start = ref.subtract(Duration(days: periodDays));
    final window =
        entries.where((e) => e.recordedAt.isAfter(start)).toList(growable: false);

    window.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (window.isEmpty) {
      return ReportData(
        periodStart: start,
        periodEnd: ref,
        count: 0,
        tirPercent: 0,
        tbrPercent: 0,
        tarPercent: 0,
        hypoEvents: 0,
        hyperEvents: 0,
        severeHypoEvents: 0,
        fastingCount: 0,
        daysLogged: 0,
        totalDays: periodDays,
        stratumLabel: targets.stratumLabel,
        insights: const [],
        focusSuggestion: 'Start logging to build your report.',
        medicationAdherence: const [],
        tagCounts: const [],
      );
    }

    final vals = window.map((e) => e.mgdl).toList();
    final mean = vals.reduce((a, b) => a + b) / vals.length;
    final gmi = 3.31 + 0.02392 * mean;
    final cv = (mean > 0) ? (stdDev(vals) / mean) * 100 : 0.0;

    final inRange =
        vals.where((v) => v >= targets.rangeLow && v <= targets.rangeHigh).length;
    final below = vals.where((v) => v < targets.rangeLow).length;
    final above = vals.where((v) => v > targets.rangeHigh).length;

    final hypoEvents =
        window.where((e) => e.mgdl < 70).length;
    final severeHypoEvents =
        window.where((e) => e.mgdl < 54).length;
    final hyperEvents =
        window.where((e) => e.mgdl > 250).length;

    final fastingEntries =
        window.where((e) => e.tags.contains(ContextTag.fasting)).toList();
    final fastingVals = fastingEntries.map((e) => e.mgdl).toList();
    final fastingMean = fastingVals.isNotEmpty
        ? fastingVals.reduce((a, b) => a + b) / fastingVals.length
        : null;

    final days = <String>{};
    for (final e in window) {
      days.add('${e.recordedAt.year}-${e.recordedAt.month}-${e.recordedAt.day}');
    }

    final tagMap = <String, int>{};
    for (final e in window) {
      for (final t in e.tags) {
        tagMap[t.label] = (tagMap[t.label] ?? 0) + 1;
      }
    }
    final tagCounts = tagMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final medAdherence = <String>[];
    for (final med in medications) {
      final medIntakes =
          intakes.where((i) => i.medicationId == med.id).toList();
      if (medIntakes.isEmpty) {
        medAdherence.add('${med.name}: no doses logged');
      } else {
        medAdherence.add('${med.name}: ${medIntakes.length} doses logged');
      }
    }

    final summary = TrendService.summarize(window, targets, now: ref);

    return ReportData(
      periodStart: start,
      periodEnd: ref,
      count: window.length,
      mean: mean,
      gmi: gmi,
      cv: cv,
      tirPercent: (inRange / window.length) * 100,
      tbrPercent: (below / window.length) * 100,
      tarPercent: (above / window.length) * 100,
      hypoEvents: hypoEvents,
      hyperEvents: hyperEvents,
      severeHypoEvents: severeHypoEvents,
      fastingCount: fastingEntries.length,
      fastingMean: fastingMean,
      daysLogged: days.length,
      totalDays: periodDays,
      stratumLabel: targets.stratumLabel,
      insights: summary.insights,
      focusSuggestion: summary.focusSuggestion,
      medicationAdherence: medAdherence,
      tagCounts: tagCounts,
    );
  }

  static double stdDev(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            (values.length - 1);
    return _sqrt(variance);
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    var guess = x / 2;
    for (var i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static String toText(ReportData r) {
    final buf = StringBuffer();
    buf.writeln('GLUCOSE REPORT');
    buf.writeln(
        'Period: ${_fmtDate(r.periodStart)} – ${_fmtDate(r.periodEnd)}');
    buf.writeln('Target stratum: ${r.stratumLabel}');
    buf.writeln('Readings: ${r.count} over ${r.daysLogged}/${r.totalDays} days');
    buf.writeln();

    buf.writeln('GLYCEMIC METRICS');
    if (r.mean != null) buf.writeln('  Mean glucose: ${r.mean!.toStringAsFixed(0)} mg/dL');
    if (r.gmi != null) buf.writeln('  GMI: ${r.gmi!.toStringAsFixed(1)}%');
    if (r.cv != null) buf.writeln('  CV: ${r.cv!.toStringAsFixed(1)}%');
    buf.writeln(
        '  TIR: ${r.tirPercent.toStringAsFixed(1)}%  |  TBR: ${r.tbrPercent.toStringAsFixed(1)}%  |  TAR: ${r.tarPercent.toStringAsFixed(1)}%');
    buf.writeln();

    buf.writeln('CLINICAL EVENTS');
    buf.writeln('  Hypo (<70): ${r.hypoEvents} events');
    buf.writeln('  Severe hypo (<54): ${r.severeHypoEvents} events');
    buf.writeln('  Hyper (>250): ${r.hyperEvents} events');
    buf.writeln();

    if (r.fastingCount > 0) {
      buf.writeln('FASTING GLUCOSE');
      buf.writeln('  Fasting readings: ${r.fastingCount}');
      if (r.fastingMean != null) {
        buf.writeln(
            '  Fasting mean: ${r.fastingMean!.toStringAsFixed(0)} mg/dL');
      }
      buf.writeln();
    }

    if (r.medicationAdherence.isNotEmpty) {
      buf.writeln('MEDICATION ADHERENCE');
      for (final line in r.medicationAdherence) {
        buf.writeln('  $line');
      }
      buf.writeln();
    }

    if (r.insights.isNotEmpty) {
      buf.writeln('TREND INSIGHTS');
      for (final insight in r.insights) {
        buf.writeln('  • ${insight.title}');
        buf.writeln('    ${insight.body}');
      }
      buf.writeln();
    }

    buf.writeln('FOCUS');
    buf.writeln('  ${r.focusSuggestion}');
    buf.writeln();

    buf.writeln('---');
    buf.writeln('Generated by Diabetic Companion');
    buf.writeln(
        'This report is informational. Share with your care team.');

    return buf.toString();
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
