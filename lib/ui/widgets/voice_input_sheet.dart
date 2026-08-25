import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/context_tag.dart';
import '../../state/app_state.dart';
import '../../services/voice_service.dart';
import '../../services/voice_advisor.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  ParsedCommand? _parsed;
  AdvisorContext? _advisorResponse;
  bool _confirmed = false;
  bool _processing = false;
  VoiceState _voiceState = VoiceState.idle;
  late AnimationController _pulseController;
  StreamSubscription? _stateSub;
  StreamSubscription? _partialSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _stateSub = VoiceService.stateStream.listen((s) {
      if (mounted) {
        setState(() => _voiceState = s);
        if (s == VoiceState.listening) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    });
    _partialSub = VoiceService.partialStream.listen((partial) {
      if (mounted && partial.isNotEmpty) {
        _controller.text = partial;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _onTextChanged(partial);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stateSub?.cancel();
    _partialSub?.cancel();
    VoiceService.stopListening();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final voiceCmd = VoiceService.parse(text);
    // Check if it's a simple log command first
    if (voiceCmd.intent == VoiceIntent.logReading ||
        voiceCmd.intent == VoiceIntent.logMedication) {
      setState(() {
        _parsed = voiceCmd;
        _advisorResponse = null;
        _confirmed = false;
      });
    } else {
      // Use the AI advisor for everything else
      final state = context.read<AppState>();
      final advisorCtx = VoiceAdvisor.advise(
        userMessage: text,
        recentEntries: state.entries,
        targets: state.targets,
      );
      setState(() {
        _parsed = null;
        _advisorResponse = advisorCtx;
        _confirmed = false;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_voiceState == VoiceState.listening) {
      VoiceService.stopListening();
      return;
    }

    final recognized = await VoiceService.startListening(
      onFinalResult: (words) {
        if (mounted) {
          _onTextChanged(words);
        }
      },
    );

    if (!recognized && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Speech recognition not available. Please type your command.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _confirm() async {
    if (_parsed == null || _parsed!.intent == VoiceIntent.unknown) return;

    setState(() => _processing = true);

    final state = context.read<AppState>();

    switch (_parsed!.intent) {
      case VoiceIntent.logReading:
        if (_parsed!.value != null) {
          final tags = <ContextTag>{};
          if (_parsed!.tag != null) tags.add(_parsed!.tag!);
          await state.addReading(mgdl: _parsed!.value!, tags: tags);
        }
        break;
      case VoiceIntent.logMedication:
        final meds = state.medications;
        if (meds.isNotEmpty) {
          final match = meds.firstWhere(
            (m) => m.name.toLowerCase().contains(
                _parsed!.medicationName?.toLowerCase() ?? ''),
            orElse: () => meds.first,
          );
          await state.markMedicationTaken(match.id);
        }
        break;
      default:
        break;
    }

    final completionText = VoiceService.getCompletionText(_parsed!);

    if (mounted) {
      setState(() {
        _confirmed = true;
        _processing = false;
      });
    }

    await VoiceService.speak(completionText);

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop(_parsed);
  }

  Future<void> _speakAdvisorResponse() async {
    if (_advisorResponse == null) return;
    await VoiceService.speak(_advisorResponse!.response);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cmd = _parsed;
    final advisor = _advisorResponse;
    final isListening = _voiceState == VoiceState.listening;
    final isSpeaking = _voiceState == VoiceState.speaking;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('AI Nutrition Advisor',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ask about any food, check your sugar, or get meal ideas',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Mic button with pulse animation
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale =
                    1.0 + (_pulseController.value * 0.15);
                final opacity =
                    isListening ? 0.3 + (_pulseController.value * 0.3) : 0.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isListening)
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary
                                .withValues(alpha: opacity),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _processing ? null : _toggleListening,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (isListening
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isListening
                  ? 'Listening... tap to stop'
                  : isSpeaking
                      ? 'Speaking...'
                      : 'Tap mic or type your question',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isListening
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isListening ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Text input
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ask about any food... (e.g. "What about rice?")',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.chat_outlined),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onTextChanged('');
                      },
                    )
                  : null,
            ),
            onChanged: _onTextChanged,
            onSubmitted: (_) => _confirm(),
          ),

          // Voice command result (log reading/medication)
          if (cmd != null && cmd.intent != VoiceIntent.unknown) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_confirmed) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            VoiceService.getCompletionText(cmd),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      VoiceService.getConfirmation(cmd),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _processing ? null : _confirm,
                          icon: _processing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.check, size: 18),
                          label: const Text('Confirm'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // AI Advisor response
          if (advisor != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: advisor.isWarning
                    ? theme.colorScheme.errorContainer.withValues(alpha: .35)
                    : theme.colorScheme.primaryContainer
                        .withValues(alpha: .4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: advisor.isWarning
                      ? theme.colorScheme.error.withValues(alpha: .3)
                      : theme.colorScheme.primary.withValues(alpha: .2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        advisor.isWarning
                            ? Icons.warning_amber_rounded
                            : Icons.smart_toy_outlined,
                        size: 18,
                        color: advisor.isWarning
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advisor.foodMentioned.isNotEmpty
                              ? 'About ${advisor.foodMentioned}'
                              : 'Advisor',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 18),
                        onPressed: _speakAdvisorResponse,
                        tooltip: 'Listen',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    advisor.response,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  if (advisor.suggestion != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.swap_horiz, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              advisor.suggestion!,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (advisor.showKitchenSwap) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Check the Kitchen tab for smart dish alternatives.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline, size: 16),
            label: const Text('What can I say?'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Nutrition Advisor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'I remember your recent readings and can give you personalized advice.\n\n'
              'Try saying:\n'
              '\u2022 "What about rice?" — I will check its GI and advise based on your sugar\n'
              '\u2022 "Can I eat bread?" — I will tell you if it is ok right now\n'
              '\u2022 "What can I eat?" — I will suggest foods for your current level\n'
              '\u2022 "How is my sugar?" — I will check your latest reading\n'
              '\u2022 "Log 120 before meal" — I will save a reading\n'
              '\u2022 "Took my metformin" — I will mark your medication\n\n'
              'I also suggest smarter alternatives from the Kitchen when needed.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
