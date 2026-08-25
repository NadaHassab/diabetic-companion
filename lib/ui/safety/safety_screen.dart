import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/distress_service.dart';
import '../../services/safety_service.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import 'protocol_screen.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final signals = DistressService.assess(entries: state.entries);
    final overallRisk = DistressService.overallRisk(signals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Text(
            'Protocols are here whenever a number worries you. No judgment '
            '\u2014 just next steps.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (signals.isNotEmpty) ...[
            _DistressCard(signals: signals, risk: overallRisk),
            const SizedBox(height: 14),
          ],
          _NavCard(
            icon: Icons.water_drop_outlined,
            color: kUrgentColor,
            title: 'Low blood sugar (below 70)',
            subtitle: 'The 15-15 rule, fast-carb options, and what does not '
                'work.',
            onTap: () => _push(context, ReadingSeverity.hypo),
          ),
          const SizedBox(height: 10),
          _NavCard(
            icon: Icons.emergency_outlined,
            color: kUrgentColor,
            title: 'Severe low (below 54 or cannot self-treat)',
            subtitle: 'Glucagon steps, emergency guidance, and the kit '
                'checklist.',
            onTap: () => _push(context, ReadingSeverity.severeHypo),
          ),
          const SizedBox(height: 10),
          _NavCard(
            icon: Icons.local_drink_outlined,
            color: kAboveColor,
            title: 'High blood sugar & DKA warning signs',
            subtitle: 'Hydration, retesting, and exactly when to seek care.',
            onTap: () => _push(context, ReadingSeverity.high),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Wear medical ID',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A bracelet, necklace, or phone lock-screen note saying you '
                    'have diabetes helps responders act fast in an emergency.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car_outlined,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Before driving',
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Never drive when your reading is below 70. Check before '
                    'you start, keep fast carbs in the car, and recheck on '
                    'long trips.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, ReadingSeverity severity) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProtocolScreen(severity: severity),
    ));
  }
}

class _DistressCard extends StatelessWidget {
  const _DistressCard({required this.signals, required this.risk});

  final List<RiskSignal> signals;
  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (risk) {
      RiskLevel.high => kUrgentColor,
      RiskLevel.moderate => kAboveColor,
      RiskLevel.low => kInfoColor,
      RiskLevel.none => theme.colorScheme.primary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.self_improvement_outlined, color: accent, size: 20),
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
            'Diabetes asks a lot of you. These patterns are common '
            'and say nothing about your effort or worth.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, height: 1.35),
          ),
          for (final s in signals) ...[
            const SizedBox(height: 12),
            Text(s.title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(s.description,
                style:
                    theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
          ],
          const SizedBox(height: 12),
          Text(
            'If any of these feel relevant, consider sharing them with '
            'your care team \u2014 they can help.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        )),
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
