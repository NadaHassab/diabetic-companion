import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/context_tag.dart';
import '../../state/app_state.dart';
import '../../services/voice_service.dart';

class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  ParsedCommand? _parsed;
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
    setState(() {
      _parsed = VoiceService.parse(text);
      _confirmed = false;
    });
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
      case VoiceIntent.checkTrend:
      case VoiceIntent.checkReminders:
      case VoiceIntent.deleteEntry:
      case VoiceIntent.unknown:
        break;
    }

    final completionText = VoiceService.getCompletionText(_parsed!);

    if (mounted) {
      setState(() {
        _confirmed = true;
        _processing = false;
      });
    }

    // TTS response
    await VoiceService.speak(completionText);

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop(_parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cmd = _parsed;
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
              Icon(Icons.mic, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Voice input',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the mic and say a command, or type below',
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
                    // Pulse ring
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
                    // Mic button
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
          // Listening status text
          Center(
            child: Text(
              isListening
                  ? 'Listening... tap to stop'
                  : isSpeaking
                      ? 'Speaking...'
                      : 'Tap mic to start speaking',
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
              hintText: 'Type or speak your command...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.keyboard_outlined),
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
          if (cmd != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cmd.intent == VoiceIntent.unknown
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      VoiceService.getConfirmation(cmd),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600),
                    ),
                    if (cmd.intent != VoiceIntent.unknown) ...[
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
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Help text
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
            Text('Voice Commands',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(VoiceService.getVoiceHelpText(),
                style: Theme.of(context).textTheme.bodyMedium),
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
