import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/targets.dart';
import '../../services/compassion_service.dart';
import '../../services/reminders_service.dart';
import '../../services/safety_service.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/time_format.dart';
import '../analytics/analytics_screen.dart';
import '../ramadan/ramadan_screen.dart';
import '../review/weekly_review_screen.dart';
import '../safety/protocol_screen.dart';
import '../widgets/common.dart';
import '../widgets/range_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onQuickAdd});

  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stats = state.overallStats;
    final targets = state.targets;
    final theme = Theme.of(context);
    final latest =
        state.entries.isEmpty ? null : state.entries.first;
    final latestSeverity = latest == null
        ? null
        : SafetyService.classify(latest.mgdl, targets);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        CompassionBanner(text: kCompassionLine),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onQuickAdd,
          icon: const Icon(Icons.add),
          label: const Text('Log a reading'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        if (state.entries.isEmpty) ...[
          _buildEmptyState(theme),
        ] else ...[
          if (latest != null && latestSeverity != null)
            MetricCard(
              title: 'Latest reading',
              subtitle:
                  '${timeAgo(latest.recordedAt)} \u00b7 ${fmtClock(latest.recordedAt)}',
              accent: latestSeverity.color,
              onTap: latestSeverity.needsProtocolCard
                  ? () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProtocolScreen(
                          severity: latestSeverity, value: latest.mgdl)))
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${latest.mgdl.toStringAsFixed(0)} mg/dL',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: latestSeverity.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(latestSeverity.subtitle,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          const SizedBox(height: 12),
          MetricCard(
            title: 'Time in range (${targets.rangeLow.toInt()}\u2013${targets.rangeHigh.toInt()} mg/dL)',
            accent: kInRangeColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(stats.inRangeFraction * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'of ${stats.count} reading${stats.count == 1 ? '' : 's'}\n'
                        'goal \u2265 ${(targets.tirGoalFraction * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RangeBar(
                  below: stats.belowFraction,
                  inRange: stats.inRangeFraction,
                  above: stats.aboveFraction,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _legendDot(kUrgentColor,
                        'below ${(stats.belowFraction * 100).toStringAsFixed(0)}%'),
                    const SizedBox(width: 14),
                    _legendDot(kInRangeColor,
                        'in ${(stats.inRangeFraction * 100).toStringAsFixed(0)}%'),
                    const SizedBox(width: 14),
                    _legendDot(kAboveColor,
                        'above ${(stats.aboveFraction * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'GMI',
                  subtitle: 'estimate from your logs',
                  accent: kInfoColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.gmiPercent == null
                            ? '\u2014'
                            : '${stats.gmiPercent!.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A derived estimate, not a lab A1C.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: 'Average & variability',
                  accent: kInfoColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.meanMgdl.toStringAsFixed(0)} mg/dL',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.cvPercent == null
                            ? 'Log at least 2 readings to see variability.'
                            : 'CV ${stats.cvPercent!.toStringAsFixed(0)}% '
                                '(goal \u2264 ${GlycemicTargets.cvGoalPercent.toStringAsFixed(0)}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DueNowCard(onQuickAdd: onQuickAdd),
          if (_buildFeedbackCard(state, theme) != null) ...[
            const SizedBox(height: 12),
            _buildFeedbackCard(state, theme)!,
          ],
          if (_reviewReady(context, state)) ...[
            const SizedBox(height: 12),
            _buildReviewTeaser(context, theme),
          ],
          const SizedBox(height: 12),
          _VeggieFirstNudge(),
          const SizedBox(height: 12),
          _AnalyticsTeaser(onQuickAdd: onQuickAdd),
          const SizedBox(height: 12),
          _RamadanTeaser(),
        ],
      ],
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11.5)),
        ],
      );

  Widget _buildEmptyState(ThemeData theme) => Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.favorite_outline,
                  size: 44, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'No readings yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Whenever you are ready, log your first blood sugar \u2014 it '
                'takes seconds. Patterns appear after a few days.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );

  bool _reviewReady(BuildContext context, AppState state) {
    if (state.entries.isEmpty) return false;
    final lastReview = state.profile.lastWeeklyReviewAt;
    final now = DateTime.now();
    if (lastReview == null) {
      return now.difference(state.entries.last.recordedAt).inDays >= 7;
    }
    return now.difference(DateTime.parse(lastReview)).inDays >= 7;
  }

  Widget? _buildFeedbackCard(AppState state, ThemeData theme) {
    if (state.entries.isEmpty) return null;
    final latest = state.entries.first;
    final streak = state.currentStreak;
    final learning = CompassionService.learningMoment(
      entry: latest,
      targets: state.targets,
      recentEntries: state.entries.take(10).toList(),
    );
    if (learning != null) {
      return _feedbackCard(theme, learning);
    }
    final compassion = CompassionService.feedbackForEntry(
      entry: latest,
      allEntries: state.entries,
      targets: state.targets,
      streakDays: streak,
    );
    if (compassion != null) {
      return _feedbackCard(theme, compassion);
    }
    return null;
  }

  Widget _feedbackCard(ThemeData theme, FeedbackMessage msg) => Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    msg.kind == FeedbackKind.compassion
                        ? Icons.favorite_outline
                        : msg.kind == FeedbackKind.learning
                            ? Icons.lightbulb_outline
                            : Icons.warning_amber_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(msg.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(msg.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35)),
            ],
          ),
        ),
      );

  Widget _buildReviewTeaser(BuildContext context, ThemeData theme) => Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const WeeklyReviewScreen())),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assessment_outlined,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly review',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        'See this week\u2019s patterns and one change to try',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      );
}

class _VeggieFirstNudge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final isLunch = hour >= 11 && hour <= 14;
    final isDinner = hour >= 17 && hour <= 20;
    if (!isLunch && !isDinner) return const SizedBox.shrink();

    final mealLabel = isLunch ? 'lunch' : 'dinner';
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_outlined, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start your $mealLabel with salad',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    'Eating vegetables or protein before carbs can reduce '
                    'your post-meal spike by up to 40%. No deprivation \u2014 '
                    'just a simple reorder.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTeaser extends StatelessWidget {
  const _AnalyticsTeaser({required this.onQuickAdd});

  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    if (state.entries.length < 3) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AnalyticsScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bar_chart,
                    color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analytics',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      '90-day trends, daily averages, time-of-day patterns',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _RamadanTeaser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const RamadanScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.nightlight_outlined,
                    color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ramadan Mode',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      'Suhoor/iftar guidance, hypo-watch, med reminders',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueNowCard extends StatelessWidget {
  const _DueNowCard({required this.onQuickAdd});

  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final due = RemindersService.dueNow(
      medications: state.medications,
      intakes: state.intakes,
      entries: state.entries,
    );
    if (due.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Due now',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in due)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      item.kind == DueKind.medication
                          ? Icons.medication_outlined
                          : Icons.timelapse,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(item.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (item.kind == DueKind.medication)
                      TextButton(
                        onPressed: () {
                          final medId = item.id.split('|').first;
                          state.markMedicationTaken(medId);
                        },
                        child: const Text('Taken'),
                      )
                    else
                      TextButton(
                        onPressed: onQuickAdd,
                        child: const Text('Log now'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
