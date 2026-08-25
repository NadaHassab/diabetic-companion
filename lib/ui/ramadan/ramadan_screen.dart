import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../state/app_state.dart';
import '../../services/ramadan_service.dart';
import '../widgets/common.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.entries;
    final targets = state.targets;

    final nextMeal = RamadanService.nextMeal();
    final isFasting = RamadanService.isFastingHour();

    final hypoAlert =
        RamadanService.hypoWatchAlert(entries: entries, targets: targets);
    final medAlert =
        RamadanService.medAdjustReminder(entries: entries, targets: targets);
    final suhoor = RamadanService.suhoorGuidance(
      targets: targets,
      recentEntries: entries,
    );
    final iftar = RamadanService.iftarGuidance(
      targets: targets,
      recentEntries: entries,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan Mode',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          CompassionBanner(
              text:
                  'Ramadan is personal. These tips are general guidance \u2014 '
                  'your care team can tailor them to your specific situation.'),

          const SizedBox(height: 16),

          // --- Fasting status card ---
          _FastingStatusCard(
            isFasting: isFasting,
            nextMealLabel: nextMeal.label,
            remaining: nextMeal.remaining,
          ),

          const SizedBox(height: 14),

          // --- Alerts ---
          if (hypoAlert != null) ...[
            _AlertCard(guidance: hypoAlert),
            const SizedBox(height: 14),
          ],
          if (medAlert != null) ...[
            _AlertCard(guidance: medAlert),
            const SizedBox(height: 14),
          ],

          // --- Suhoor guidance ---
          if (suhoor.isNotEmpty) ...[
            _SectionHeader(icon: Icons.nightlight_outlined, title: 'Suhoor'),
            const SizedBox(height: 8),
            for (final g in suhoor) ...[
              _GuidanceCard(guidance: g),
              const SizedBox(height: 8),
            ],
          ],

          // --- Iftar guidance ---
          if (iftar.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SectionHeader(
                icon: Icons.wb_sunny_outlined, title: 'Iftar'),
            const SizedBox(height: 8),
            for (final g in iftar) ...[
              _GuidanceCard(guidance: g),
              const SizedBox(height: 8),
            ],
          ],

          // --- General tips ---
          const SizedBox(height: 8),
          _GuidanceCard(guidance: RamadanService.generalTips()),
        ],
      ),
    );
  }
}

class _FastingStatusCard extends StatelessWidget {
  const _FastingStatusCard({
    required this.isFasting,
    required this.nextMealLabel,
    required this.remaining,
  });

  final bool isFasting;
  final String nextMealLabel;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFasting
              ? [
                  theme.colorScheme.primary.withValues(alpha: .12),
                  theme.colorScheme.primary.withValues(alpha: .06),
                ]
              : [
                  kInRangeColor.withValues(alpha: .12),
                  kInRangeColor.withValues(alpha: .06),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFasting
              ? theme.colorScheme.primary.withValues(alpha: .3)
              : kInRangeColor.withValues(alpha: .3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isFasting ? Icons.nightlight_round : Icons.wb_sunny,
            size: 36,
            color: isFasting
                ? theme.colorScheme.primary
                : kInRangeColor,
          ),
          const SizedBox(height: 10),
          Text(
            isFasting ? 'Fasting hours' : 'Not fasting now',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '$nextMealLabel in ${hours}h ${minutes}m',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check your glucose before $nextMealLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.guidance});

  final RamadanGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guidance.title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(guidance.body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.guidance});

  final RamadanGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kUrgentColor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kUrgentColor.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: kUrgentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(guidance.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(guidance.body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}
