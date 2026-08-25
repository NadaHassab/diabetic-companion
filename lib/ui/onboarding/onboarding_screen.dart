import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/targets.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _disclaimerAccepted = false;

  UserProfile _draft = const UserProfile();

  static const int _totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _tr(BuildContext context, String key) =>
      AppLocalizations.of(context).translate(key);

  bool get _canAdvance {
    switch (_page) {
      case 0:
        return _disclaimerAccepted;
      case 1:
        return true;
      case 2:
        return true;
      case 3:
        return _draft.ageYears >= 1 && _draft.ageYears <= 120;
      case 4:
        return true;
      case 5:
        return _quizChoice == _kQuizCorrectIndex;
    }
    return false;
  }

  Future<void> _next() async {
    if (!_canAdvance) return;
    if (_page < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      await context.read<AppState>().updateProfile(
            _draft.copyWith(
              onboarded: true,
              acceptedDisclaimer: true,
              passedSafetyQuiz: true,
            ),
          );
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  int _quizChoice = -1;
  static const int _kQuizCorrectIndex = 1;

  @override
  Widget build(BuildContext context) {
    final targets = GlycemicTargets.forProfile(_draft);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr(context, 'appTitle'),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          // Language toggle always visible in app bar
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'ar', label: Text('عربي')),
              ],
              selected: {_draft.languageCode},
              onSelectionChanged: (v) {
                final lang = v.first;
                setState(() => _draft = _draft.copyWith(languageCode: lang));
                // Persist immediately so the whole widget tree rebuilds with new locale
                context.read<AppState>().updateProfile(
                      _draft.copyWith(
                        onboarded: false,
                        acceptedDisclaimer: _disclaimerAccepted,
                      ),
                    );
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(_totalPages, (i) {
                final active = i == _page;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _buildDisclaimerStep(context),
                _buildTypeStep(context),
                _buildInsulinStep(context),
                _buildAboutYouStep(context),
                _buildTargetsStep(context, targets),
                _buildQuizStep(context),
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                if (_page > 0)
                  TextButton(
                      onPressed: _back,
                      child: Text(_tr(context, 'cancel'))),
                const Spacer(),
                FilledButton(
                  onPressed: _canAdvance ? _next : null,
                  child: Text(_page == _totalPages - 1
                      ? _tr(context, 'onbGetStarted')
                      : _tr(context, 'save')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepScaffold(
    BuildContext context, {
    required String title,
    required String body,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDisclaimerStep(BuildContext context) {
    final theme = Theme.of(context);
    return _stepScaffold(
      context,
      title: _tr(context, 'onbWelcome'),
      body: _tr(context, 'onbWelcomeBody'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(_tr(context, 'onbImportant'),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_tr(context, 'onbDisclaimer'),
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _disclaimerAccepted,
            onChanged: (v) => setState(() => _disclaimerAccepted = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(_tr(context, 'onbDisclaimerCheck')),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep(BuildContext context) => _stepScaffold(
        context,
        title: _tr(context, 'onbDiabetesType'),
        body: _tr(context, 'onbDiabetesTypeBody'),
        child: RadioGroup<DiabetesType>(
          groupValue: _draft.diabetesType,
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _draft = _draft.copyWith(
                diabetesType: v,
                pregnant: v == DiabetesType.gestational,
              );
            });
          },
          child: Column(
            children: DiabetesType.values.map((t) {
              final selected = _draft.diabetesType == t;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<DiabetesType>(
                    value: t,
                    title: Text(t.label,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(t.detail),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );

  Widget _buildInsulinStep(BuildContext context) => _stepScaffold(
        context,
        title: _tr(context, 'onbMedication'),
        body: _tr(context, 'onbMedicationBody'),
        child: Column(
          children: [
            SwitchListTile(
              value: _draft.usesInsulin,
              onChanged: (v) => setState(() {
                _draft = _draft.copyWith(usesInsulin: v);
                if (!v) _draft = _draft.copyWith(hasGlucagonKit: false);
              }),
              title: Text(_tr(context, 'insulinTaking')),
              subtitle: const Text('Includes pens or pumps'),
            ),
            if (_draft.usesInsulin)
              SwitchListTile(
                value: _draft.hasGlucagonKit,
                onChanged: (v) =>
                    setState(() => _draft = _draft.copyWith(hasGlucagonKit: v)),
                title: Text(_tr(context, 'glucagonAtHome')),
                subtitle: const Text('Nasal or injection, in date'),
              ),
            if (_draft.usesInsulin && !_draft.hasGlucagonKit)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  'If you use insulin, ask your clinician whether glucagon is '
                  'right for you. It treats severe lows.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      );

  Widget _buildAboutYouStep(BuildContext context) {
    final theme = Theme.of(context);
    return _stepScaffold(
      context,
      title: _tr(context, 'onbAboutYou'),
      body: _tr(context, 'onbAboutYouBody'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: _draft.ageYears.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _tr(context, 'onbAge'),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              final age = int.tryParse(v);
              if (age != null && age >= 1 && age <= 120) {
                _draft = _draft.copyWith(ageYears: age);
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _draft.pregnant ||
                _draft.diabetesType == DiabetesType.gestational,
            onChanged: _draft.diabetesType == DiabetesType.gestational
                ? null
                : (v) => setState(() => _draft = _draft.copyWith(pregnant: v)),
            title: Text(_tr(context, 'pregnancy')),
            subtitle: Text(
                'Applies pregnancy glucose targets automatically with '
                'gestational diabetes',
                style: theme.textTheme.bodySmall),
          ),
          SwitchListTile(
            value: _draft.olderAdultComplexHealth,
            onChanged: (v) => setState(
                () => _draft = _draft.copyWith(olderAdultComplexHealth: v)),
            title: Text(_tr(context, 'olderAdult')),
            subtitle: Text(
                'For 65+ with complex health, where avoiding lows matters most',
                style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          Text(
            'Goals always remain individualizable \u2014 confirm yours with '
            'your care team.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsStep(BuildContext context, GlycemicTargets targets) {
    final theme = Theme.of(context);
    return _stepScaffold(
      context,
      title: _tr(context, 'onbYourTargets'),
      body: '${_tr(context, 'onbTargetsBody')}\n'
          'ADA 2026: ${targets.stratumLabel}.',
      child: Column(
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${targets.rangeLow.toInt()}\u2013${targets.rangeHigh.toInt()} mg/dL',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(_tr(context, 'onbTimeInRange'),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const Divider(height: 24),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(targets.individualizedNote,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildQuizStep(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      _tr(context, 'onbQuizOpt1'),
      _tr(context, 'onbQuizOpt2'),
      _tr(context, 'onbQuizOpt3'),
    ];
    final chosenCorrect = _quizChoice == _kQuizCorrectIndex;
    final answeredWrong =
        _quizChoice >= 0 && _quizChoice != _kQuizCorrectIndex;

    return _stepScaffold(
      context,
      title: _tr(context, 'onbSafetyQuiz'),
      body: _tr(context, 'onbQuizQuestion'),
      child: RadioGroup<int>(
        groupValue: _quizChoice,
        onChanged: (v) => setState(() => _quizChoice = v ?? -1),
        child: Column(
          children: [
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _quizChoice == i
                          ? (i == _kQuizCorrectIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: i,
                    title: Text(options[i]),
                  ),
                ),
              ),
            if (chosenCorrect)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_tr(context, 'onbQuizCorrect')),
              ),
            if (answeredWrong)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.errorContainer.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_tr(context, 'onbQuizWrong')),
              ),
          ],
        ),
      ),
    );
  }
}
