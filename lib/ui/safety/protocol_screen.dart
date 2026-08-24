import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../services/safety_service.dart';
import '../../theme.dart';

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({
    super.key,
    required this.severity,
    this.value,
  });

  final ReadingSeverity severity;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showLowCards = severity.isLow;
    final showHighCards = severity.isHigh;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What to do now'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: severity.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: severity.color.withValues(alpha: .4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, color: severity.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        severity.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: severity.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(severity.subtitle,
                    style: theme.textTheme.bodyMedium),
                if (value != null) ...[
                  const SizedBox(height: 6),
                  Text('${value!.toStringAsFixed(0)} mg/dL',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
          if (showLowCards) ...[
            const SizedBox(height: 16),
            _HypoLevel1Card(),
            const SizedBox(height: 14),
            _SevereHypoCard(
                highlight: severity == ReadingSeverity.severeHypo),
          ],
          if (showHighCards) ...[
            const SizedBox(height: 16),
            _HyperCard(),
          ],
          const SizedBox(height: 24),
          Text(kMedicalDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              )),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.bullets,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final List<String> bullets;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlight
            ? BorderSide(color: kUrgentColor.withValues(alpha: .55), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final b in bullets)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HypoLevel1Card extends StatelessWidget {
  const _HypoLevel1Card();

  @override
  Widget build(BuildContext context) => _Section(
        icon: Icons.water_drop_outlined,
        title: 'Below 70 mg/dL \u2014 treat with the 15-15 rule',
        bullets: const [
          'Eat 15 g of fast-acting carbs right away.',
          'Wait 15 minutes, then recheck. Repeat until you are above 70.',
          'Fast options: 4 glucose tablets \u00b7 \u00bd cup juice \u00b7 6 oz regular '
              'soda \u00b7 1 tbsp honey or sugar \u00b7 3\u20134 hard candies.',
          'Not effective: chocolate, ice cream, donuts \u2014 fat slows sugar '
              'absorption.',
          'After recovering, eat a small snack with protein to prevent a '
              'second drop.',
          'Tell your clinician if you have 2 or more lows in a week.',
          'Never drive while low. Wait until you have rechecked and are fully '
              'back above range before driving.',
        ],
      );
}

class _SevereHypoCard extends StatelessWidget {
  const _SevereHypoCard({this.highlight = false});

  final bool highlight;

  @override
  Widget build(BuildContext context) => _Section(
        highlight: highlight,
        icon: Icons.emergency_outlined,
        title: 'Below 54 mg/dL, or cannot self-treat',
        bullets: const [
          'If able: take fast carbs immediately and recheck every 15 minutes.',
          'If very low, confused, or unconscious: give glucagon (needle-free '
              'nasal powder or ready-to-use injection) and turn the person on '
              'their side.',
          'Call emergency services if unconscious or no glucagon is '
              'available.',
          'Never give food or drink to someone who is unconscious.',
          'Checklist: do you have an in-date glucagon kit where you live and '
              'where you travel? If not, ask your clinician at your next '
              'visit.',
        ],
      );
}

class _HyperCard extends StatelessWidget {
  const _HyperCard();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _Section(
            icon: Icons.local_drink_outlined,
            title: 'Above range \u2014 steady care beats alarm',
            bullets: const [
              'Drink water and move gently if that is part of your routine.',
              'Retest in about 2 hours to see the direction.',
              'A single high reading is information, not failure.',
            ],
          ),
          const SizedBox(height: 14),
          _Section(
            icon: Icons.warning_amber_rounded,
            title: 'Seek care now if any of these apply',
            bullets: const [
              'Vomiting, fruity-smelling breath, belly pain, confusion, or '
                  'rapid breathing.',
              '250 mg/dL or higher together with ketone symptoms \u2014 possible '
                  'DKA (diabetic ketoacidosis).',
              'Readings repeatedly above 300 mg/dL in the same day \u2014 contact '
                  'your care team today.',
            ],
            highlight: true,
          ),
        ],
      );
}
