import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../models/context_tag.dart';

enum VoiceIntent {
  logReading,
  logMedication,
  checkTrend,
  checkReminders,
  deleteEntry,
  unknown,
}

enum VoiceState { idle, listening, processing, speaking }

class ParsedCommand {
  final VoiceIntent intent;
  final double? value;
  final ContextTag? tag;
  final String? medicationName;
  final String? deleteScope;

  const ParsedCommand({
    required this.intent,
    this.value,
    this.tag,
    this.medicationName,
    this.deleteScope,
  });
}

class VoiceService {
  static final _stt = stt.SpeechToText();
  static final _tts = FlutterTts();
  static bool _sttInitialized = false;
  static VoiceState _state = VoiceState.idle;
  static String _lastWords = '';
  static String _partialWords = '';
  static Timer? _silenceTimer;

  static VoiceState get state => _state;
  static String get lastWords => _lastWords;
  static String get partialWords => _partialWords;

  static final _stateController = StreamController<VoiceState>.broadcast();
  static final _wordsController = StreamController<String>.broadcast();
  static final _partialController = StreamController<String>.broadcast();

  static Stream<VoiceState> get stateStream => _stateController.stream;
  static Stream<String> get wordsStream => _wordsController.stream;
  static Stream<String> get partialStream => _partialController.stream;

  static Future<void> initialize() async {
    if (_sttInitialized) return;

    _stt.statusListener = (status) {
      if (status == 'notListening' || status == 'done') {
        _stopListening();
      }
    };

    _stt.errorListener = (error) {
      _stopListening();
    };

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);

    _sttInitialized = true;
  }

  static Future<bool> startListening({
    Function(String)? onFinalResult,
    Duration silenceTimeout = const Duration(seconds: 3),
  }) async {
    if (!await _stt.initialize(
      onError: (error) => _stopListening(),
    )) {
      return false;
    }

    _setState(VoiceState.listening);
    _lastWords = '';
    _partialWords = '';
    _partialController.add('');

    _stt.listen(
      onResult: (result) {
        _partialWords = result.recognizedWords;
        _partialController.add(_partialWords);

        if (result.finalResult) {
          _lastWords = result.recognizedWords;
          _wordsController.add(_lastWords);
          _silenceTimer?.cancel();

          if (onFinalResult != null) {
            onFinalResult(_lastWords);
          }
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: silenceTimeout,
        onDevice: false,
        cancelOnError: true,
        partialResults: true,
      ),
    );

    return true;
  }

  static void _stopListening() {
    _silenceTimer?.cancel();
    if (_state == VoiceState.listening) {
      _stt.stop();
      _setState(VoiceState.idle);
    }
  }

  static void stopListening() {
    _stopListening();
  }

  static Future<void> speak(String text) async {
    _setState(VoiceState.speaking);
    await _tts.speak(text);
    await _tts.awaitSpeakCompletion(true);
    _setState(VoiceState.idle);
  }

  static Future<void> stopSpeaking() async {
    await _tts.stop();
    _setState(VoiceState.idle);
  }

  static bool get isAvailable => _stt.isAvailable;
  static bool get isListening => _stt.isListening;

  static void _setState(VoiceState s) {
    _state = s;
    _stateController.add(s);
  }

  static void dispose() {
    _silenceTimer?.cancel();
    _stt.cancel();
    _tts.stop();
    _stateController.close();
    _wordsController.close();
    _partialController.close();
  }

  // ─── NLU Parser ───────────────────────────────────────────────

  static ParsedCommand parse(String text) {
    final lower = text.toLowerCase().trim();

    // Log reading: "log 120 before meal", "log fasting 95", "250 after eating"
    final logMatch = RegExp(
      r'log\s+(\d+)\s*(before\s*(meal|eating)?|after\s*(meal|eating)?|fasting|bedtime|exercise|stress)?',
    ).firstMatch(lower);
    if (logMatch != null) {
      final value = double.tryParse(logMatch.group(1)!);
      ContextTag? tag;
      final tagStr = logMatch.group(2) ?? '';
      if (tagStr.contains('before')) tag = ContextTag.beforeMeal;
      if (tagStr.contains('after')) tag = ContextTag.afterMeal;
      if (tagStr.contains('fasting')) tag = ContextTag.fasting;
      if (tagStr.contains('bedtime')) tag = ContextTag.bedtime;
      if (tagStr.contains('exercise')) tag = ContextTag.exercise;
      if (tagStr.contains('stress')) tag = ContextTag.stress;
      return ParsedCommand(
          intent: VoiceIntent.logReading, value: value, tag: tag);
    }

    // Also handle just a number like "120"
    final numOnly = RegExp(r'^(\d+)$').firstMatch(lower);
    if (numOnly != null) {
      return ParsedCommand(
        intent: VoiceIntent.logReading,
        value: double.tryParse(numOnly.group(1)!),
      );
    }

    // "before meal 120" or "after meal 150"
    final tagFirst = RegExp(
      r'(before|after)\s*(meal|eating)?\s*(\d+)',
    ).firstMatch(lower);
    if (tagFirst != null) {
      final value = double.tryParse(tagFirst.group(3)!);
      final isBefore = tagFirst.group(1) == 'before';
      return ParsedCommand(
        intent: VoiceIntent.logReading,
        value: value,
        tag: isBefore ? ContextTag.beforeMeal : ContextTag.afterMeal,
      );
    }

    // "fasting 95"
    final fastingMatch = RegExp(r'fasting\s+(\d+)').firstMatch(lower);
    if (fastingMatch != null) {
      return ParsedCommand(
        intent: VoiceIntent.logReading,
        value: double.tryParse(fastingMatch.group(1)!),
        tag: ContextTag.fasting,
      );
    }

    // Log medication: "took my metformin", "take metformin"
    final medMatch = RegExp(
      r'(took|taken|take|log)\s+(my\s+)?(.+)',
    ).firstMatch(lower);
    if (medMatch != null) {
      return ParsedCommand(
        intent: VoiceIntent.logMedication,
        medicationName: medMatch.group(3)?.trim(),
      );
    }

    // Check trend
    if (RegExp(r"(what('s| is)\s+)?my\s+(trend|average|summary|fasting)")
        .hasMatch(lower)) {
      return const ParsedCommand(intent: VoiceIntent.checkTrend);
    }

    // Check reminders
    if (RegExp(r'(am i|do i have)\s+(due|anything|reminder|med)')
        .hasMatch(lower)) {
      return const ParsedCommand(intent: VoiceIntent.checkReminders);
    }

    // Delete
    final deleteMatch = RegExp(r'delete\s+(my\s+)?(last|recent|all)')
        .firstMatch(lower);
    if (deleteMatch != null) {
      return ParsedCommand(
        intent: VoiceIntent.deleteEntry,
        deleteScope: deleteMatch.group(2),
      );
    }

    // Help
    if (RegExp(r'(help|what can you|how do i|commands)').hasMatch(lower)) {
      return const ParsedCommand(intent: VoiceIntent.unknown);
    }

    return ParsedCommand(intent: VoiceIntent.unknown);
  }

  static String getConfirmation(ParsedCommand cmd) {
    switch (cmd.intent) {
      case VoiceIntent.logReading:
        final tagText = cmd.tag != null ? ', ${cmd.tag!.label}' : '';
        return 'Log ${cmd.value?.toStringAsFixed(0)} mg/dL$tagText?';
      case VoiceIntent.logMedication:
        return 'Mark ${cmd.medicationName} as taken?';
      case VoiceIntent.checkTrend:
        return 'Checking your trend...';
      case VoiceIntent.checkReminders:
        return 'Checking reminders...';
      case VoiceIntent.deleteEntry:
        return 'Delete ${cmd.deleteScope} entry?';
      case VoiceIntent.unknown:
        return 'Try saying: "Log 120 before meal" or "Took my metformin"';
    }
  }

  static String getCompletionText(ParsedCommand cmd) {
    switch (cmd.intent) {
      case VoiceIntent.logReading:
        return 'Logged ${cmd.value?.toStringAsFixed(0)} mg/dL.';
      case VoiceIntent.logMedication:
        return 'Marked ${cmd.medicationName} as taken.';
      case VoiceIntent.checkTrend:
        return 'Here is your trend summary.';
      case VoiceIntent.checkReminders:
        return 'Checking what is due now.';
      case VoiceIntent.deleteEntry:
        return 'Entry deleted.';
      case VoiceIntent.unknown:
        return 'I can help you log readings, check trends, or manage reminders.';
    }
  }

  static String getVoiceHelpText() {
    return 'You can say commands like:\n'
        '- "Log 120 before meal"\n'
        '- "Log fasting 95"\n'
        '- "Log 250 after eating"\n'
        '- "Took my metformin"\n'
        '- "What\'s my trend?"\n'
        '- "Am I due for anything?"\n'
        '- "Delete my last entry"';
  }
}
