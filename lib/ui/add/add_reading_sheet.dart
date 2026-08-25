import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/context_tag.dart';
import '../../models/glucose_entry.dart';
import '../../services/safety_service.dart';
import '../../state/app_state.dart';
import 'meal_picker_sheet.dart';

class AddReadingSheet extends StatefulWidget {
  const AddReadingSheet({super.key});

  @override
  State<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<AddReadingSheet> {
  String _buffer = '';
  final Set<ContextTag> _tags = <ContextTag>{};
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double? get _parsed => double.tryParse(_buffer);

  bool get _canSave {
    final v = _parsed;
    return v != null && v > 0 && v <= 600;
  }

  void _press(String key) {
    setState(() {
      if (key == '<') {
        if (_buffer.isNotEmpty) _buffer = _buffer.substring(0, _buffer.length - 1);
        return;
      }
      if (key == '.') {
        if (_buffer.contains('.')) return;
        _buffer = _buffer.isEmpty ? '' : '$_buffer.';
        return;
      }
      final intPart = _buffer.split('.').first;
      if (!(_buffer.contains('.')) && intPart.length >= 3) return;
      if (_buffer.contains('.') && _buffer.split('.')[1].isNotEmpty) return;
      if (_buffer == '' && key == '0') return;
      _buffer += key;
    });
  }

  Future<void> _save() async {
    final v = _parsed;
    if (v == null || v <= 0) return;

    if (SafetyService.isUnusualValue(v)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('That value looks unusual'),
          content: Text(
            'Blood sugar meters usually read between about 20 and 600 mg/dL. '
            'Is ${_formatVal(v)} mg/dL really what the meter showed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Go back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, it is correct'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    if (!mounted) return;
    final state = context.read<AppState>();
    final saved = await state.addReading(
      mgdl: v,
      tags: Set<ContextTag>.of(_tags),
      note: _noteCtrl.text.trim(),
      confirmedUnusual: SafetyService.isUnusualValue(v),
    );
    if (!mounted) return;

    final mealRelated = _tags.contains(ContextTag.beforeMeal) ||
        _tags.contains(ContextTag.afterMeal);
    var mealSaved = false;
    if (mealRelated) {
      mealSaved = await MealPickerSheet.show(context, saved.id);
      if (!mounted) return;
    }

    Navigator.of(context).pop(GlucoseEntry(
      id: saved.id,
      recordedAt: saved.recordedAt,
      mgdl: v,
      tags: Set<ContextTag>.of(_tags),
      note: _noteCtrl.text.trim(),
      confirmedUnusual: SafetyService.isUnusualValue(v),
    ));
    if (mealSaved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Meal saved with your reading')));
    }
  }

  String _formatVal(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New reading',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _buffer.isEmpty ? '\u2014' : _buffer,
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text('mg/dL',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildKeypad(theme),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ContextTag.values.map((t) {
                  final selected = _tags.contains(t);
                  return FilterChip(
                    selected: selected,
                    onSelected: (on) =>
                        setState(() => on ? _tags.add(t) : _tags.remove(t)),
                    avatar: Icon(t.icon,
                        size: 17,
                        color: selected ? theme.colorScheme.primary : null),
                    label: Text(t.label),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save reading'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) => Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['.', '0', '<'],
          ])
            Row(
              children: row
                  .map((k) => Expanded(child: _keyBtn(k, theme)))
                  .toList(),
            ),
        ],
      );

  Widget _keyBtn(String k, ThemeData theme) => Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _press(k),
            child: SizedBox(
              height: 56,
              child: Center(
                child: k == '<'
                    ? const Icon(Icons.backspace_outlined)
                    : Text(k,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
}
