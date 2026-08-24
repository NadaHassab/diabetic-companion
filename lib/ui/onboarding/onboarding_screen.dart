import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
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
        title: const Text('Welcome',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
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
                  TextButton(onPressed: _back, child: const Text('Back')),
                const Spacer(),
                FilledButton(
                  onPressed: _canAdvance ? _next : null,
                  child:
                      Text(_page == _totalPages - 1 ? 'Get started' : 'Next'),
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
      title: 'Your companion, not your judge',
      body:
          'A calm place to log blood sugar and understand patterns. '
          '$kCompassionLine',
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
                      Text('Important',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(kMedicalDisclaimer,
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
            title: const Text(
                'I understand this app does not replace medical advice.'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep(BuildContext context) => _stepScaffold(
        context,
        title: 'What type of diabetes?',
        body: 'This personalizes your targets and safety content. You can '
            'change it anytime in Settings.',
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
        title: 'Your medication',
        body: 'Used only to tailor safety guidance. The app never calculates '
            'or suggests doses.',
        child: Column(
          children: [
            SwitchListTile(
              value: _draft.usesInsulin,
              onChanged: (v) => setState(() {
                _draft = _draft.copyWith(usesInsulin: v);
                if (!v) _draft = _draft.copyWith(hasGlucagonKit: false);
              }),
              title: const Text('I take insulin'),
              subtitle: const Text('Includes pens or pumps'),
            ),
            if (_draft.usesInsulin)
              SwitchListTile(
                value: _draft.hasGlucagonKit,
                onChanged: (v) =>
                    setState(() => _draft = _draft.copyWith(hasGlucagonKit: v)),
                title: const Text('I have a glucagon kit at home'),
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
      title: 'A bit about you',
      body: 'Age and special situations adjust your personal glucose goals.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            title: const Text('Pregnant'),
            subtitle: const Text(
                'Applies pregnancy glucose targets automatically with '
                'gestational diabetes'),
          ),
          SwitchListTile(
            value: _draft.olderAdultComplexHealth,
            onChanged: (v) => setState(
                () => _draft = _draft.copyWith(olderAdultComplexHealth: v)),
            title: const Text('Use relaxed older-adult goals'),
            subtitle: const Text(
                'For 65+ with complex health, where avoiding lows matters most',
                style: TextStyle(fontSize: 12.5)),
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
      title: 'Your personal targets',
      body: 'Based on ADA Standards of Care 2026 for: ${targets.stratumLabel}.',
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
                  Text('your target range',
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
    const options = [
      'Wait until the next meal and recheck later.',
      'Take 15 g of fast sugar now \u2014 juice or 4 glucose tablets '
          '\u2014 then recheck in 15 minutes.',
      'Take an extra dose of insulin to bring it down.',
    ];
    final chosenCorrect = _quizChoice == _kQuizCorrectIndex;
    final answeredWrong =
        _quizChoice >= 0 && _quizChoice != _kQuizCorrectIndex;

    String wrongHint(int idx) {
      if (idx == 0) {
        return 'Waiting lets a low go lower. Fast sugar works within minutes.';
      }
      return 'Insulin would push it lower \u2014 that is dangerous during a low.';
    }

    return _stepScaffold(
      context,
      title: 'One quick safety check',
      body:
          'You read 55 mg/dL and feel shaky and sweaty. What do you do first?',
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
                child: const Text(
                  'That\u2019s right. This 15-15 habit is the core of staying '
                  'safe \u2014 the app will show it whenever a reading goes low.',
                ),
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
                child: Text(wrongHint(_quizChoice)),
              ),
          ],
        ),
      ),
    );
  }
}
