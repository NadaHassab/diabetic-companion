import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../report/report_screen.dart';
import '../food/food_database_screen.dart';
import '../studio/studio_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final targets = state.targets;
    final theme = Theme.of(context);
    final p = state.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
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
                      Expanded(
                        child: Text('Your profile',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        tooltip: 'Edit profile',
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _kv(theme, 'Diabetes type', p.diabetesType.label),
                  _kv(theme, 'Insulin', p.usesInsulin ? 'yes' : 'no'),
                  if (p.usesInsulin)
                    _kv(theme, 'Glucagon kit at home', p.hasGlucagonKit ? 'yes' : 'not yet \u2014 ask your clinician'),
                  _kv(theme, 'Age', '${p.ageYears}'),
                  _kv(
                    theme,
                    'Target stratum',
                    p.pregnant || p.diabetesType == DiabetesType.gestational
                        ? 'Pregnancy'
                        : (p.olderAdultComplexHealth
                            ? 'Older adult \u00b7 complex health'
                            : 'Standard adult'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildMedsSection(context, theme),
          const SizedBox(height: 14),
          _buildSafetySection(context, theme, p),
          const SizedBox(height: 14),
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
                  Text('Your targets (${targets.stratumLabel})',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...targets.guidanceLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 17, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(line)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(targets.individualizedNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  Text('Data & privacy',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Everything stays on this device. No accounts, no cloud, '
                    'no ads.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _exportData(context),
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Export all data as JSON'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: () => _deleteAll(context),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Delete all data'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  Text('Tools',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.assessment_outlined),
                    title: const Text('Doctor-Ready Report'),
                    subtitle: const Text('Share your glucose summary with your care team'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant_outlined),
                    title: const Text('Food & Carb Database'),
                    subtitle: const Text('Browse foods with carb values and portions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FoodDatabaseScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.soup_kitchen_outlined),
                    title: const Text('Meals Studio · مطبخ آمن'),
                    subtitle: const Text('Smarter versions of your favorite dishes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudioScreen())),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.visibility_off_outlined),
                    title: const Text('Focus mode'),
                    subtitle: const Text(
                        'Hide carb numbers in meal views. Your data is never '
                        'deleted \u2014 only hidden while you need it.'),
                    value: p.focusMode,
                    onChanged: (v) => context
                        .read<AppState>()
                        .updateProfile(p.copyWith(focusMode: v)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    subtitle: const Text(
                        'Switch to a darker color scheme'),
                    value: p.darkMode,
                    onChanged: (v) => context
                        .read<AppState>()
                        .updateProfile(p.copyWith(darkMode: v)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Language'),
                    subtitle: Text(p.languageCode == 'ar' ? 'العربية' : 'English'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  Text('About',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('$kAppName $kAppVersion',
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Text(kMedicalDisclaimer,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(ThemeData theme, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(k, style: theme.textTheme.bodyMedium)),
            Text(v,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _buildSafetySection(
      BuildContext context, ThemeData theme, UserProfile p) {
    String? glucagonExpiryText;
    final expiry = p.glucagonExpiresAt;
    if (expiry != null) {
      final d = DateTime.parse(expiry);
      final days = d.difference(DateTime.now()).inDays;
      if (days < 0) {
        glucagonExpiryText = 'EXPIRED ${d.year}-${d.month}-${d.day} — replace it';
      } else if (days < 60) {
        glucagonExpiryText =
            'expires in $days days (${d.year}-${d.month}-${d.day}) — ask for a renewal';
      } else {
        glucagonExpiryText = 'expires ${d.year}-${d.month}-${d.day}';
      }
    }
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Safety extras',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_emergency_outlined),
              title: Text(p.emergencyContactName == null
                  ? 'Add emergency contact'
                  : p.emergencyContactName!),
              subtitle: Text(p.emergencyContactPhone ?? 'Name and phone number'),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _editEmergencyContact(context),
            ),
            if (p.usesInsulin && p.hasGlucagonKit)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medication_liquid_outlined),
                title: const Text('Glucagon kit'),
                subtitle: Text(glucagonExpiryText ??
                    'Tap to add the expiration date so we can remind you'),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => _editGlucagonExpiry(context),
              ),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.badge_outlined),
              title: const Text('I wear a medical ID'),
              subtitle: const Text(
                  'Bracelets or phone lock-screen notes help responders in an emergency'),
              value: p.hasMedicalId,
              onChanged: (v) => context.read<AppState>().updateProfile(
                    p.copyWith(hasMedicalId: v),
                  ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_car_outlined),
              title: const Text('Before driving'),
              subtitle: const Text(
                  'Check your glucose first — never drive below your target low. '
                  'Keep fast carbs in the car.'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editEmergencyContact(BuildContext context) async {
    final state = context.read<AppState>();
    final nameCtrl = TextEditingController(text: state.profile.emergencyContactName ?? '');
    final phoneCtrl = TextEditingController(text: state.profile.emergencyContactPhone ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    await state.updateProfile(state.profile.copyWith(
      emergencyContactName: nameCtrl.text.trim(),
      emergencyContactPhone: phoneCtrl.text.trim(),
    ));
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final state = context.read<AppState>();
    final current = state.profile.languageCode;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Language'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'en'),
            child: Row(
              children: [
                if (current == 'en')
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                const Text('English'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'ar'),
            child: Row(
              children: [
                if (current == 'ar')
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                const Text('العربية'),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null && picked != current && context.mounted) {
      await state.updateProfile(state.profile.copyWith(languageCode: picked));
    }
  }

  Future<void> _editGlucagonExpiry(BuildContext context) async {
    final state = context.read<AppState>();
    final current = state.profile.glucagonExpiresAt;
    final initial = current != null ? DateTime.parse(current) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      helpText: 'Glucagon kit expiration',
    );
    if (picked == null) return;
    await state.updateProfile(state.profile.copyWith(
      glucagonExpiresAt: picked.toIso8601String(),
    ));
  }

  Widget _buildMedsSection(BuildContext context, ThemeData theme) {
    final state = context.watch<AppState>();
    final meds = state.medications;
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
                Expanded(
                  child: Text('Medications & reminders',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'Add medication',
                  onPressed: () => _openMedsEditor(context),
                  icon: const Icon(Icons.add_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (meds.isEmpty)
              Text(
                'No medications yet. Tap + to add one.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              )
            else
              for (final med in meds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.medication_outlined,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.name,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              med.times.join(' \u00b7 '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete ${med.name}',
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete ${med.name}?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            state.removeMedication(med.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMedsEditor(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MedsEditorSheet(),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ProfileEditorSheet(),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final state = context.read<AppState>();
    final path = await state.exportAllData();
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Data exported'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved to:'),
            const SizedBox(height: 8),
            SelectableText(path,
                style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  Future<void> _deleteAll(BuildContext context) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
            'This permanently erases every reading and your profile from this '
            'device. It cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep my data')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content:
            const Text('Last chance \u2014 export a copy first if you might '
                'want it later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Erase everything'),
          ),
        ],
      ),
    );
    if (second != true || !context.mounted) return;
    await context.read<AppState>().deleteAllData();
  }
}

class _ProfileEditorSheet extends StatefulWidget {
  const _ProfileEditorSheet();

  @override
  State<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<_ProfileEditorSheet> {
  late UserProfile _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<AppState>().profile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit profile',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            DropdownButtonFormField<DiabetesType>(
              initialValue: _draft.diabetesType,
              decoration: const InputDecoration(
                labelText: 'Diabetes type',
                border: OutlineInputBorder(),
              ),
              items: DiabetesType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _draft = _draft.copyWith(
                    diabetesType: v,
                    pregnant: v == DiabetesType.gestational));
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _draft.usesInsulin,
              onChanged: (v) => setState(() {
                _draft = _draft.copyWith(usesInsulin: v);
                if (!v) _draft = _draft.copyWith(hasGlucagonKit: false);
              }),
              contentPadding: EdgeInsets.zero,
              title: const Text('I take insulin'),
            ),
            if (_draft.usesInsulin)
              SwitchListTile(
                value: _draft.hasGlucagonKit,
                onChanged: (v) =>
                    setState(() => _draft = _draft.copyWith(hasGlucagonKit: v)),
                contentPadding: EdgeInsets.zero,
                title: const Text('Glucagon kit at home'),
              ),
            SwitchListTile(
              value: _draft.pregnant ||
                  _draft.diabetesType == DiabetesType.gestational,
              onChanged: _draft.diabetesType == DiabetesType.gestational
                  ? null
                  : (v) =>
                      setState(() => _draft = _draft.copyWith(pregnant: v)),
              contentPadding: EdgeInsets.zero,
              title: const Text('Pregnant'),
            ),
            SwitchListTile(
              value: _draft.olderAdultComplexHealth,
              onChanged: (v) => setState(
                  () => _draft = _draft.copyWith(olderAdultComplexHealth: v)),
              contentPadding: EdgeInsets.zero,
              title: const Text('Relaxed older-adult goals'),
              subtitle: const Text('65+ with complex health'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _draft.ageYears.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final age = int.tryParse(v);
                if (age != null && age >= 1 && age <= 120) {
                  _draft = _draft.copyWith(ageYears: age);
                }
              },
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await context.read<AppState>().updateProfile(_draft);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedsEditorSheet extends StatefulWidget {
  const _MedsEditorSheet();

  @override
  State<_MedsEditorSheet> createState() => _MedsEditorSheetState();
}

class _MedsEditorSheetState extends State<_MedsEditorSheet> {
  final _nameCtrl = TextEditingController();
  final List<String> _times = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty && _times.isNotEmpty;

  void _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _times.add(formatted));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add medication',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Medication name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            Text('Scheduled times',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _times)
                  Chip(
                    label: Text(t),
                    onDeleted: () => setState(() => _times.remove(t)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add time'),
                  onPressed: _addTime,
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _canSave
                  ? () async {
                      await context
                          .read<AppState>()
                          .addMedication(_nameCtrl.text.trim(), _times);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Add medication'),
            ),
          ],
        ),
      ),
    );
  }
}
