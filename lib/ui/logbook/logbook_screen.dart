import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/context_tag.dart';
import '../../models/glucose_entry.dart';
import '../../models/targets.dart';
import '../../services/safety_service.dart';
import '../../state/app_state.dart';
import '../../utils/time_format.dart';
import '../safety/protocol_screen.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logbook',
              style: TextStyle(fontWeight: FontWeight.w600)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DailyView(),
            _WeeklyView(),
          ],
        ),
      ),
    );
  }
}

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final targets = state.targets;
    if (state.entries.isEmpty) {
      return const _EmptyHint();
    }

    final days = <DateTime>[];
    for (final e in state.entries) {
      final d = DateTime(e.recordedAt.year, e.recordedAt.month, e.recordedAt.day);
      if (days.isEmpty || !days.contains(d)) days.add(d);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final dayEntries = state.entries
            .where((e) => isSameDay(e.recordedAt, day))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 4 : 18, bottom: 8),
              child: Text(
                '${fmtDay(day)} \u00b7 ${dayEntries.length} reading${dayEntries.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            for (final e in dayEntries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EntryTile(entry: e, targets: targets),
              ),
          ],
        );
      },
    );
  }
}

class _WeeklyView extends StatelessWidget {
  const _WeeklyView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final targets = state.targets;
    if (state.entries.isEmpty) return const _EmptyHint();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        for (var back = 0; back < 7; back++)
          Builder(builder: (context) {
            final day = today.subtract(Duration(days: back));
            final dayEntries = state.entries
                .where((e) => isSameDay(e.recordedAt, day))
                .toList();
            final avg = dayEntries.isEmpty
                ? null
                : dayEntries.map((e) => e.mgdl).reduce((a, b) => a + b) /
                    dayEntries.length;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            back == 0 ? 'Today' : fmtDay(day),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            dayEntries.isEmpty
                                ? 'no readings'
                                : 'avg ${avg!.toStringAsFixed(0)} mg/dL',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        alignment: WrapAlignment.end,
                        children: [
                          for (final e in dayEntries)
                            Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: SafetyService.classify(e.mgdl, targets)
                                    .color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 6),
        Text(
          'Each dot is one reading, colored by your personal range.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.targets});

  final GlucoseEntry entry;
  final GlycemicTargets targets;

  @override
  Widget build(BuildContext context) {
    final severity = SafetyService.classify(entry.mgdl, targets);
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => _showDetail(context, severity),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: severity.color.withValues(alpha: 0.12),
          child: Text(
            entry.mgdl.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: severity.color,
            ),
          ),
        ),
        title: Text(fmtClock(entry.recordedAt)),
        subtitle: entry.tags.isEmpty
            ? null
            : Text(entry.tags.map((t) => t.label).join(' \u00b7 '),
                maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  void _showDetail(BuildContext context, ReadingSeverity severity) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${entry.mgdl.toStringAsFixed(0)} mg/dL',
                style: Theme.of(sheetContext).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: severity.color,
                    ),
              ),
            ),
            Center(child: Text(severity.subtitle)),
            const SizedBox(height: 10),
            Center(
              child: Text(fmtFull(entry.recordedAt),
                  style: Theme.of(sheetContext).textTheme.bodySmall),
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags
                    .map((t) => Chip(label: Text(t.label), visualDensity: VisualDensity.compact))
                    .toList(),
              ),
            ],
            ..._mealSection(context, sheetContext),
            if (entry.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('\u201c${entry.note}\u201d',
                  style: Theme.of(sheetContext).textTheme.bodyMedium),
            ],
            const SizedBox(height: 20),
            if (severity.needsProtocolCard)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ProtocolScreen(severity: severity, value: entry.mgdl),
                    ));
                  },
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: const Text('What to do'),
                ),
              ),
            FilledButton.tonalIcon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: sheetContext,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete this reading?'),
                    content: const Text(
                        'This removes the reading from your logbook on this '
                        'device.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Keep it')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true && sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                  await context.read<AppState>().deleteEntry(entry.id);
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete reading'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _mealSection(BuildContext context, BuildContext sheetContext) {
    final appState = context.read<AppState>();
    final meal = appState.mealLogForEntry(entry.id);
    if (meal == null) return const [];
    final focusMode = appState.profile.focusMode;
    final theme = Theme.of(sheetContext);
    return [
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_outlined,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(focusMode
                    ? 'Meal logged'
                    : 'Meal — ${meal.totalCarbs.toStringAsFixed(0)} g carbs',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            for (final item in meal.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  focusMode
                      ? '${item.foodName} (${item.portionLabel})'
                      : '${item.foodName} (${item.portionLabel}) · ${item.carbGrams.toStringAsFixed(0)} g',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    ];
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_list_bulleted,
                size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Your logbook fills in as you go',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Every reading adds to the picture. Consistency counts more '
              'than perfection.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
