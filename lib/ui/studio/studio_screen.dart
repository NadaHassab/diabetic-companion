import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/smart_dish.dart';
import '../../models/studio_models.dart';
import '../../services/meals_studio_service.dart';
import '../../services/studio_catalog.dart';
import '../../state/app_state.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  String _query = '';
  DishCategory? _selectedCategory;
  String? _selectedRegion;

  static const _allRegions = ['Egypt', 'Levant', 'Gulf', 'Maghreb'];

  List<StudioDish> get _filtered {
    var list = studioDishes;
    if (_selectedCategory != null) {
      list = list.where((d) => d.category == _selectedCategory).toList();
    }
    if (_selectedRegion != null) {
      list = list.where((d) => d.region == _selectedRegion).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((d) =>
              d.nameEn.toLowerCase().contains(q) ||
              d.nameAr.contains(q) ||
              d.region.toLowerCase().contains(q))
          .toList(growable: false);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('mealsStudio'),
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Info banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Keep your favorite dishes — smarter versions of them. '
                'Every estimate is honest about its certainty, and your own '
                'readings decide what works for you.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
              ),
            ),
          ),

          // Smart versions
          if (state.smartVersions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('My smart versions',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.smartVersions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final v = state.smartVersions[i];
                  return _versionChip(v, theme);
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dishes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          const SizedBox(height: 8),

          // Category tabs
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _categoryChip(null, 'All'),
                for (final cat in DishCategory.values)
                  _categoryChip(cat, '${cat.labelAr} · ${cat.labelEn}'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Region chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _regionChip(null, 'All regions'),
                for (final r in _allRegions) _regionChip(r, r),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Dish count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} dish${_filtered.length == 1 ? '' : 'es'}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Dish list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No dishes found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _dishCard(_filtered[i], theme),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(DishCategory? cat, String label) {
    final selected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) =>
            setState(() => _selectedCategory = selected ? null : cat),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _regionChip(String? region, String label) {
    final selected = _selectedRegion == region;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) =>
            setState(() => _selectedRegion = selected ? null : region),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _dishCard(StudioDish dish, ThemeData theme) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => _openInterview(dish),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor:
                theme.colorScheme.primaryContainer.withValues(alpha: .6),
            child: Text(
              dish.giEstimate.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: Text(dish.nameEn,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(
              '${dish.nameAr} · ${dish.region} · ${dish.category.labelEn}',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          trailing: const Icon(Icons.chevron_right),
        ),
      );

  Widget _versionChip(SmartDishVersion v, ThemeData theme) {
    final dish = studioDishes.firstWhere((d) => d.id == v.dishId);
    final matched = MealsStudioService.matchedSamples(
        samples: context.read<AppState>().dishSamples, versionId: v.id);
    final response = MealsStudioService.responseFor(matched);
    return GestureDetector(
      onTap: () => _openVersionDetail(v, dish),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: .3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart ${dish.nameEn} · ${v.label}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(MealsStudioService.display(response),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<void> _openInterview(StudioDish dish) async {
    final answers = <String, String>{};
    for (final q in studioMethodQuestions) {
      final picked = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(q.questionEn),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in q.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, o.id),
                    child: Text('${o.labelEn} · ${o.labelAr}'),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Skip')),
          ],
        ),
      );
      if (!mounted) return;
      if (picked != null) answers[q.id] = picked;
    }
    if (!mounted) return;
    await _openFixes(dish, answers);
  }

  Future<void> _openFixes(
      StudioDish dish, Map<String, String> methodAnswers) async {
    var applied = <String>{};
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, ctrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Smart ${dish.nameEn} — suggested fixes',
                    style: Theme.of(ctx).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final card in MealsStudioService.fixCards(
                        dish: dish,
                        methodAnswers: methodAnswers,
                        appliedSwaps: applied))
                      _fixTile(card, setSheet, applied),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(ctx, applied.isNotEmpty),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(applied.isEmpty
                        ? 'Apply at least one fix'
                        : 'Save my smart version (${applied.length} fix${applied.length == 1 ? '' : 'es'})'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final state = context.read<AppState>();
    final count =
        state.smartVersions.where((v) => v.dishId == dish.id).length + 1;
    await state.saveSmartVersion(SmartDishVersion(
      id: 'sv-${DateTime.now().microsecondsSinceEpoch}',
      dishId: dish.id,
      label: 'v$count',
      appliedSwapIds: applied.toList(),
      methodAnswers: methodAnswers,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Smart ${dish.nameEn} saved — try it and log how you feel')));
  }

  Widget _fixTile(StudioFixCard card,
          void Function(void Function()) setSheet, Set<String> applied) =>
      CheckboxListTile(
        value: card.applied,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
            '${card.swap.fromEn} → ${card.swap.toEn}\n${card.swap.toAr}',
            style: const TextStyle(fontSize: 13.5, height: 1.3)),
        subtitle: Text(
            '${card.swap.effect}\nSource: ${card.swap.source} · ${card.swap.tierLabel}',
            style: const TextStyle(fontSize: 11.5, height: 1.3)),
        isThreeLine: true,
        onChanged: (_) => setSheet(() {
          card.applied
              ? applied.remove(card.swap.id)
              : applied.add(card.swap.id);
        }),
      );

  void _openVersionDetail(SmartDishVersion v, StudioDish dish) {
    final state = context.read<AppState>();
    final focusMode = state.profile.focusMode;
    final matched = MealsStudioService.matchedSamples(
        samples: state.dishSamples, versionId: v.id);
    final response = MealsStudioService.responseFor(matched);
    final swaps = v.appliedSwapIds
        .map((id) => studioSwaps.firstWhere((s) => s.id == id))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text('Smart ${dish.nameEn} · ${v.label}',
                style: Theme.of(sheetCtx).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(sheetCtx)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(MealsStudioService.eatingOrderCard(dish.nameEn),
                  style: Theme.of(sheetCtx).textTheme.bodySmall
                      ?.copyWith(height: 1.35)),
            ),
            const SizedBox(height: 16),
            Text('Applied fixes',
                style: Theme.of(sheetCtx).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            for (final s in swaps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                    '• ${s.fromEn} → ${s.toEn} (${s.effect})',
                    style: Theme.of(sheetCtx).textTheme.bodySmall),
              ),
            const SizedBox(height: 16),
            Text('Your response so far',
                style: Theme.of(sheetCtx).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              '${response.confidenceLabel} · ${response.matchedSamples} matched sample${response.matchedSamples == 1 ? '' : 's'}'
              '${focusMode ? '' : MealsStudioService.display(response).replaceFirst(RegExp(r'^[a-z ]+ · '), ' · ')}',
              style: Theme.of(sheetCtx).textTheme.bodyMedium,
            ),
            if (response.confidence == DishConfidence.stillLearning)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'A single reading is never a verdict. After 3 matched '
                  'post-meal readings (same portion, no illness/stress tags), '
                  'a pattern starts to appear.',
                  style: Theme.of(sheetCtx).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(sheetCtx).colorScheme.onSurfaceVariant,
                      height: 1.35),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: () async {
                Navigator.pop(sheetCtx);
                await _logSample(v);
              },
              icon: const Icon(Icons.add),
              label: const Text('Log a post-meal result'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logSample(SmartDishVersion v) async {
    final preCtrl = TextEditingController();
    final postCtrl = TextEditingController();
    var portion = 'M';
    final confounders = <String>{};
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Log post-meal result',
                    style: Theme.of(ctx).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: preCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Pre-meal mg/dL'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: postCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: '+2h mg/dL'))),
                ]),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'S', label: Text('S')),
                    ButtonSegment(value: 'M', label: Text('M')),
                    ButtonSegment(value: 'L', label: Text('L')),
                  ],
                  selected: {portion},
                  onSelectionChanged: (s) =>
                      setSheet(() => portion = s.first),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in [
                      'exercise',
                      'stress',
                      'illness',
                      'poorSleep'
                    ])
                      FilterChip(
                        label: Text(c),
                        selected: confounders.contains(c),
                        onSelected: (on) => setSheet(() =>
                            on
                                ? confounders.add(c)
                                : confounders.remove(c)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Samples with confounders are kept but never counted '
                  'toward the pattern — that keeps comparisons fair.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(ctx).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save sample'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    final state = context.read<AppState>();
    final pre = double.tryParse(preCtrl.text.trim());
    final post = double.tryParse(postCtrl.text.trim());
    if (pre == null || post == null || pre <= 0 || post <= 0) return;
    await state.addReading(mgdl: pre, tags: const {});
    await state.addReading(mgdl: post, tags: const {});
    await state.addDishSample(DishSample(
          id: 'ds-${DateTime.now().microsecondsSinceEpoch}',
          versionId: v.id,
          preMealMgdl: pre,
          postMealMgdl: post,
          portionLabel: portion,
          confounders: confounders,
          loggedAt: DateTime.now(),
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sample saved — patterns appear after a few')));
  }
}
