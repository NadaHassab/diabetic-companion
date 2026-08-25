import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_item.dart';
import '../../models/meal_log.dart';
import '../../services/food_database.dart';
import '../../state/app_state.dart';

class MealPickerSheet extends StatefulWidget {
  const MealPickerSheet({super.key, required this.glucoseEntryId});

  final String glucoseEntryId;

  static Future<bool> show(BuildContext context, String glucoseEntryId) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MealPickerSheet(glucoseEntryId: glucoseEntryId),
      ).then((v) => v ?? false);

  @override
  State<MealPickerSheet> createState() => _MealPickerSheetState();
}

class _MealPickerSheetState extends State<MealPickerSheet> {
  String _query = '';
  final Map<String, PortionPreset> _selected = <String, PortionPreset>{};

  List<FoodItem> get _filtered {
    if (_query.isEmpty) return defaultFoods;
    final q = _query.toLowerCase();
    return defaultFoods
        .where((f) =>
            f.nameEn.toLowerCase().contains(q) || f.nameAr.contains(q))
        .toList(growable: false);
  }

  double get _totalCarbs => _selected.values
      .fold(0.0, (sum, p) => sum + p.carbGrams);

  bool get _focusMode =>
      context.read<AppState>().profile.focusMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('What did you eat?',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'Optional — pick foods to estimate carbs. Estimates are a '
                'starting point, not exact values.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final food = _filtered[i];
                  final chosen = _selected[food.id];
                  return _foodRow(food, chosen, theme);
                },
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                      top: BorderSide(
                          color: theme.colorScheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_focusMode) ...[
                            Text('Estimated carbs',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                            Text('${_totalCarbs.toStringAsFixed(0)} g',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ] else ...[
                            Text('Focus mode on',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                            Text('${_selected.length} item${_selected.length == 1 ? '' : 's'}',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _selected.isEmpty ? null : _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save meal'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodRow(FoodItem food, PortionPreset? chosen, ThemeData theme) =>
      Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.nameEn,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(food.nameAr,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              for (final p in food.portions)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: chosen?.label == p.label,
                    onSelected: (_) => setState(() {
                      if (chosen?.label == p.label) {
                        _selected.remove(food.id);
                      } else {
                        _selected[food.id] = p;
                      }
                    }),
                  ),
                ),
            ],
          ),
        ),
      );

  Future<void> _save() async {
    final items = _selected.entries
        .map((e) => MealItem(
              foodId: e.key,
              foodName: defaultFoods.firstWhere((f) => f.id == e.key).nameEn,
              portionLabel: e.value.label,
              carbGrams: e.value.carbGrams,
            ))
        .toList();
    await context.read<AppState>().addMealLog(
          glucoseEntryId: widget.glucoseEntryId,
          items: items,
        );
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
