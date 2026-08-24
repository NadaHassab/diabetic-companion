# Voice Assistant — Plan

## Vision
A compassionate, diabetes-aware voice assistant that helps users log readings, check reminders, and understand patterns — hands-free. Privacy-first: all processing on-device where possible.

## Core Capabilities

### 1. Quick Log (Priority 1)
- "Log 120 before meal" → creates GlucoseEntry with tag
- "Log 250 after eating" → creates entry with afterMeal tag
- "Log fasting 95" → creates fasting entry
- "Took my metformin" → logs MedIntake
- Numbers only — no free-text health advice

### 2. Quick Check (Priority 2)
- "What's my trend?" → reads last 7-day summary in plain language
- "Am I due for anything?" → checks dueNow reminders
- "What was my last reading?" → reads latest entry
- "How's my fasting this week?" → reads fasting average

### 3. Entry Management (Priority 3)
- "Delete my last entry" → removes most recent
- "What did I log today?" → lists today's entries

### 4. Compassionate Check-in (Priority 4)
- After detecting a low: "Are you feeling okay? If you need help, follow the 15-15 rule"
- After logging 5+ days: "You've been consistent this week — that's the real win"
- Never judges numbers — only acknowledges tracking effort

## Technical Architecture

### Speech-to-Text (STT)
- **Web**: Web Speech API (`SpeechRecognition`)
- **Mobile**: `speech_to_text` package (uses native speech recognition)
- **Offline fallback**: `speech_recognition` or manual text input

### Text Understanding (NLU)
- **Lightweight regex parser** for MVP — no cloud dependency
- Patterns: `log <number> <tag>`, `took <med>`, `what's my <metric>`, `delete <scope>`
- Later: `intent` + `entity` extraction via on-device ML

### Text-to-Speech (TTS)
- **Web**: Web Speech API (`SpeechSynthesis`)
- **Mobile**: `flutter_tts` package
- Default: warm, calm, non-clinical tone

### Privacy
- No audio leaves the device (Web Speech API runs locally)
- No cloud LLM calls for voice processing
- All NLU done locally with regex patterns
- Optional: on-device tiny LLM for natural language understanding (Phase 5)

## Implementation Plan

### Phase A: Basic STT + NLU (1-2 days)
1. Add `speech_to_text` package (mobile) + Web Speech API (web)
2. Create `VoiceService` with `listen()` and `speak()` methods
3. Build regex parser for log/check intents
4. Wire to AppState for reading/writing

### Phase B: Voice UI (1 day)
5. Floating action button with mic icon on dashboard
6. Listening overlay with waveform animation
7. Confirmation card before committing logged values

### Phase C: Compassionate Voice (1 day)
8. Contextual TTS responses (not just "done" — "Logged 120, before meal. Pattern noted.")
9. Post-low safety check voice prompt
10. Weekly consistency acknowledgment

## Regex Patterns (MVP)

```dart
// Log reading
r'log\s+(\d+)\s*(before|after|fasting|bedtime|exercise|stress)?\s*(meal|eating)?'

// Log medication
r'(took|taken|log)\s+(my\s+)?(.+)'

// Check trend
r"(what('s| is)\s+)?my\s+(trend|average|summary|fasting)"

// Check reminders
r'(am i|do i have)\s+(due|anything|reminder|med)'

// Delete
r'delete\s+(my\s+)?(last|recent|all)'
```

## UI Pattern
```
[🎤 Mic Button]
    ↓
[Listening overlay: "I'm listening..."]
    ↓
[Transcribed text: "Log 120 before meal"]
    ↓
[Confirmation card: "Log 120 mg/dL, Before meal? [✓ Yes] [✗ Cancel]"]
    ↓
[TTS: "Logged 120, before meal."]
```

## Safety Rules
1. Never give medical advice via voice
2. Never interpret glucose values — only report them
3. Always confirm before committing a log
4. If user says "I feel sick" or "help" → trigger safety protocol
5. Voice responses use compassionate language only
