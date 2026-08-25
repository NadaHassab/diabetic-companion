import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/glucose_entry.dart';
import '../../services/escalation_service.dart';
import '../../services/trend_service.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../widgets/common.dart';
import '../widgets/range_bar.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final summary =
        TrendService.summarize(state.entries, state.targets);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly review',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          CompassionBanner(
              text:
                  'Ten quiet minutes to see the week as information \u2014 '
                  'not a report card.'),
          const SizedBox(height: 16),
          MetricCard(
            title: 'Consistency',
            accent: kInfoColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${summary.countThisWeek} readings this week',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${summary.daysLoggedThisWeek} of 7 days logged'
                  '${summary.countPrevWeek > 0 ? ' \u00b7 ${summary.countPrevWeek} the week before' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'Time in range',
            accent: kInRangeColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(summary.tirThisWeek * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (summary.countPrevWeek > 0) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          'vs ${(summary.tirPrevWeek * 100).toStringAsFixed(0)}% last week',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                RangeBar(
                  below: summary.countThisWeek == 0
                      ? 0
                      : 1 - summary.tirThisWeek,
                  inRange: summary.tirThisWeek,
                  above: 0,
                ),
                const SizedBox(height: 6),
                Text(
                  'Range ${state.targets.rangeLow.toInt()}\u2013${state.targets.rangeHigh.toInt()} mg/dL',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (summary.fastingWeeklyAvg.any((v) => v != null)) ...[
            const SizedBox(height: 12),
            MetricCard(
              title: 'Morning fasting averages',
              subtitle: 'last 4 weeks',
              accent: kInfoColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var k = 3; k >= 0; k--)
                    _FastingCell(
                      label: k == 0 ? 'this wk' : '-$k wk',
                      value: summary.fastingWeeklyAvg[k],
                    ),
                ],
              ),
            ),
          ],
          if (summary.insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final insight in summary.insights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MetricCard(
                  title: insight.title,
                  accent: kAboveColor,
                  child: Text(insight.body,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.35)),
                ),
              ),
          ],
          const SizedBox(height: 12),
          _WellbeingCard(entries: state.entries),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'One change is enough',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(summary.focusSuggestion,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await context.read<AppState>().recordWeeklyReview();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Done \u2014 see you next week'),
          ),
          const SizedBox(height: 16),
          Text(kMedicalDisclaimer,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}

class _FastingCell extends StatelessWidget {
  const _FastingCell({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value == null ? '\u2014' : value!.toStringAsFixed(0),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: value == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _WellbeingCard extends StatelessWidget {
  const _WellbeingCard({required this.entries});

  final List<GlucoseEntry> entries;

  @override
  Widget build(BuildContext context) {
    final signals = EscalationService.assess(entries: entries);
    if (signals.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final rung = EscalationService.overallRung(signals);
    final isCritical = rung == EscalationRung.safetyCritical;
    final accent = isCritical ? kUrgentColor : kInfoColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.self_improvement_outlined, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A gentle check-in',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Diabetes asks a lot of you. Some patterns below are common and '
            'say nothing about your effort or worth.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, height: 1.35),
          ),
          for (final s in signals) ...[
            const SizedBox(height: 12),
            Text(s.title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(s.body,
                style:
                    theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
            if (s.conversationStarter != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Talking point: ${s.conversationStarter}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3)),
              ),
          ],
        ],
      ),
    );
  }
}
