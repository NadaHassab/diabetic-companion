import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/glucose_entry.dart';
import '../../models/targets.dart';
import '../../services/metrics_service.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../widgets/common.dart';
import '../widgets/range_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final entries = state.entries;
    final targets = state.targets;

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart,
                    size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('No data yet',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Log a few readings to see patterns and trends here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final d90 = now.subtract(const Duration(days: 90));
    final d30 = now.subtract(const Duration(days: 30));
    final d7 = now.subtract(const Duration(days: 7));

    final entries90 = entries.where((e) => e.recordedAt.isAfter(d90)).toList();
    final entries30 = entries.where((e) => e.recordedAt.isAfter(d30)).toList();
    final entries7 = entries.where((e) => e.recordedAt.isAfter(d7)).toList();

    final stats90 = state.statsFor(entries90);
    final stats30 = state.statsFor(entries30);
    final stats7 = state.statsFor(entries7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          CompassionBanner(
              text:
                  'Numbers show patterns \u2014 not your worth. Use them to '
                  'have better conversations with your care team.'),
          const SizedBox(height: 16),

          // --- Period comparison ---
          _SectionTitle(title: 'At a glance'),
          const SizedBox(height: 8),
          _PeriodComparison(
            label7: '7 days',
            label30: '30 days',
            label90: '90 days',
            stats7: stats7,
            stats30: stats30,
            stats90: stats90,
            targets: targets,
          ),

          const SizedBox(height: 20),

          // --- Daily averages bar chart ---
          _SectionTitle(title: 'Daily averages (last 30 days)'),
          const SizedBox(height: 8),
          _DailyAverageChart(
            entries: entries.where((e) => e.recordedAt.isAfter(d30)).toList(),
            targets: targets,
          ),

          const SizedBox(height: 20),

          // --- Time-of-day pattern ---
          _SectionTitle(title: 'Time of day patterns'),
          const SizedBox(height: 8),
          _TimeOfDayChart(entries: entries90, targets: targets),

          const SizedBox(height: 20),

          // --- Day of week pattern ---
          _SectionTitle(title: 'Day of week averages'),
          const SizedBox(height: 8),
          _DayOfWeekChart(entries: entries90, targets: targets),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _PeriodComparison extends StatelessWidget {
  const _PeriodComparison({
    required this.label7,
    required this.label30,
    required this.label90,
    required this.stats7,
    required this.stats30,
    required this.stats90,
    required this.targets,
  });

  final String label7, label30, label90;
  final GlucoseStats stats7, stats30, stats90;
  final GlycemicTargets targets;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PeriodRow(
              label: label7,
              stats: stats7,
              targets: targets,
              isHighlight: true,
            ),
            const Divider(height: 20),
            _PeriodRow(label: label30, stats: stats30, targets: targets),
            const Divider(height: 20),
            _PeriodRow(label: label90, stats: stats90, targets: targets),
          ],
        ),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.label,
    required this.stats,
    required this.targets,
    this.isHighlight = false,
  });

  final String label;
  final GlucoseStats stats;
  final GlycemicTargets targets;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isHighlight
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: style),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RangeBar(
            below: stats.belowFraction,
            inRange: stats.inRangeFraction,
            above: stats.aboveFraction,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stats.count == 0 ? '\u2014' : '${(stats.inRangeFraction * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: stats.inRangeFraction >= targets.tirGoalFraction
                      ? kInRangeColor
                      : kAboveColor,
                ),
              ),
              Text('${stats.count} readings',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyAverageChart extends StatelessWidget {
  const _DailyAverageChart({required this.entries, required this.targets});

  final List<GlucoseEntry> entries;
  final GlycemicTargets targets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final byDay = <String, List<GlucoseEntry>>{};
    for (final e in entries) {
      final key = '${e.recordedAt.month}-${e.recordedAt.day}';
      byDay.putIfAbsent(key, () => []).add(e);
    }

    final avgs = <double>[];
    for (final dayEntries in byDay.values) {
      final sum = dayEntries.fold<double>(0, (s, e) => s + e.mgdl);
      avgs.add(sum / dayEntries.length);
    }

    if (avgs.isEmpty) return const SizedBox.shrink();
    avgs.sort();

    final maxVal = avgs.last;
    final minVal = avgs.first;
    final range = maxVal - minVal > 0 ? maxVal - minVal : 1.0;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${avgs.length} days',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text(
                    'avg ${avgs.fold<double>(0, (s, v) => s + v) / avgs.length ~/ 1} mg/dL',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final avg in avgs) ...[
                    Expanded(
                      child: Tooltip(
                        message: '${avg.toStringAsFixed(0)} mg/dL',
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: avg > targets.rangeHigh
                                ? kAboveColor.withValues(alpha: .7)
                                : avg < targets.rangeLow
                                    ? kUrgentColor.withValues(alpha: .7)
                                    : kInRangeColor.withValues(alpha: .7),
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                          height: ((avg - minVal) / range) * 100 + 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendDot(kInRangeColor, 'In range'),
                const SizedBox(width: 12),
                _legendDot(kAboveColor, 'High'),
                const SizedBox(width: 12),
                _legendDot(kUrgentColor, 'Low'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );
}

class _TimeOfDayChart extends StatelessWidget {
  const _TimeOfDayChart({required this.entries, required this.targets});

  final List<GlucoseEntry> entries;
  final GlycemicTargets targets;

  static const _periods = [
    ('Night\n0\u20136', 0, 6),
    ('Morning\n6\u201312', 6, 12),
    ('Afternoon\n12\u201318', 12, 18),
    ('Evening\n18\u201324', 18, 24),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final periodAvgs = _periods.map((p) {
      final periodEntries = entries
          .where((e) =>
              e.recordedAt.hour >= p.$2 && e.recordedAt.hour < p.$3)
          .toList();
      if (periodEntries.isEmpty) return null;
      return periodEntries.fold<double>(0, (s, e) => s + e.mgdl) /
          periodEntries.length;
    }).toList();

    final maxAvg =
        periodAvgs.whereType<double>().fold<double>(0, (m, v) => v > m ? v : m);
    if (maxAvg == 0) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _periods.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    if (periodAvgs[i] != null)
                      Text(periodAvgs[i]!.toStringAsFixed(0),
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 11))
                    else
                      const Text('\u2014',
                          style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      height: periodAvgs[i] != null
                          ? (periodAvgs[i]! / maxAvg) * 80 + 10
                          : 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: periodAvgs[i] == null
                            ? theme.colorScheme.surfaceContainerHighest
                            : periodAvgs[i]! > targets.rangeHigh
                                ? kAboveColor.withValues(alpha: .6)
                                : periodAvgs[i]! < targets.rangeLow
                                    ? kUrgentColor.withValues(alpha: .6)
                                    : kInRangeColor.withValues(alpha: .6),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_periods[i].$1,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (i < _periods.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayOfWeekChart extends StatelessWidget {
  const _DayOfWeekChart({required this.entries, required this.targets});

  final List<GlucoseEntry> entries;
  final GlycemicTargets targets;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dayAvgs = List.generate(7, (dayIndex) {
      final dayEntries = entries
          .where((e) => (e.recordedAt.weekday - 1) == dayIndex)
          .toList();
      if (dayEntries.isEmpty) return null;
      return dayEntries.fold<double>(0, (s, e) => s + e.mgdl) /
          dayEntries.length;
    });

    final maxAvg =
        dayAvgs.whereType<double>().fold<double>(0, (m, v) => v > m ? v : m);
    if (maxAvg == 0) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 7; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    if (dayAvgs[i] != null)
                      Text(dayAvgs[i]!.toStringAsFixed(0),
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 11))
                    else
                      const Text('\u2014',
                          style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      height: dayAvgs[i] != null
                          ? (dayAvgs[i]! / maxAvg) * 80 + 10
                          : 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: dayAvgs[i] == null
                            ? theme.colorScheme.surfaceContainerHighest
                            : dayAvgs[i]! > targets.rangeHigh
                                ? kAboveColor.withValues(alpha: .6)
                                : dayAvgs[i]! < targets.rangeLow
                                    ? kUrgentColor.withValues(alpha: .6)
                                    : kInRangeColor.withValues(alpha: .6),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_days[i],
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              if (i < 6) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
