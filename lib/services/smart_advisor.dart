import 'dart:math' as math;

import '../models/glucose_entry.dart';
import '../models/targets.dart';

// ═══════════════════════════════════════════════════════════════════════
// SMART DIABETES NUTRITION ADVISOR
// ═══════════════════════════════════════════════════════════════════════
// Intent classifier + food knowledge graph + context tracker + response generator
// Runs offline, no API needed, feels conversational.

enum AdvisorIntent {
  foodQuestion,
  canIEat,
  whatCanIEat,
  sugarCheck,
  greeting,
  thanks,
  help,
  mood,
  unknown,
}

class AdvisorResponse {
  final AdvisorIntent intent;
  final String text;
  final String? foodName;
  final bool isWarning;
  final String? swapSuggestion;
  final String? followUp;

  const AdvisorResponse({
    required this.intent,
    required this.text,
    this.foodName,
    this.isWarning = false,
    this.swapSuggestion,
    this.followUp,
  });
}

// ─── Conversation Memory ───────────────────────────────────────────────

class Turn {
  final String userMessage;
  final AdvisorResponse response;
  final DateTime timestamp;

  Turn(this.userMessage, this.response) : timestamp = DateTime.now();
}

class ConversationMemory {
  final List<Turn> _turns = [];
  static const int maxTurns = 30;

  List<Turn> get turns => List.unmodifiable(_turns);

  void add(String user, AdvisorResponse response) {
    _turns.insert(0, Turn(user, response));
    if (_turns.length > maxTurns) _turns.removeLast();
  }

  void clear() => _turns.clear();

  /// What food was last discussed?
  String? get lastFoodDiscussed {
    for (final t in _turns) {
      if (t.response.foodName != null) return t.response.foodName;
    }
    return null;
  }

  /// Was the last response a warning?
  bool get lastWasWarning =>
      _turns.isNotEmpty && _turns.first.response.isWarning;

  /// How many times have we discussed a specific food?
  int timesDiscussed(String food) => _turns
      .where((t) =>
          t.response.foodName?.toLowerCase() == food.toLowerCase())
      .length;
}

// ─── Food Knowledge Graph ──────────────────────────────────────────────

class FoodKnowledge {
  final String nameEn;
  final String nameAr;
  final int gi;
  final double carbsPerServing;
  final String category;
  final String giCategory; // low / medium / high
  final List<String> goodWith; // pairs well with
  final List<String> alternatives; // lower-GI swaps
  final List<String> avoidWith; // don't pair with
  final String portionAdvice;

  const FoodKnowledge({
    required this.nameEn,
    required this.nameAr,
    required this.gi,
    required this.carbsPerServing,
    required this.category,
    required this.giCategory,
    this.goodWith = const [],
    this.alternatives = const [],
    this.avoidWith = const [],
    this.portionAdvice = '',
  });
}

class FoodKnowledgeBase {
  static final Map<String, FoodKnowledge> _kb = {};

  static void initialize() {
    if (_kb.isNotEmpty) return;

    final foods = <FoodKnowledge>[
      // ─── Grains & Starches ───
      const FoodKnowledge(
        nameEn: 'white rice',
        nameAr: 'أرز أبيض',
        gi: 73, carbsPerServing: 45, category: 'grain',
        giCategory: 'high',
        goodWith: ['lentils', 'chicken', 'fish', 'vegetables'],
        alternatives: ['basmati rice', 'freekeh', 'burghul', 'cauliflower rice'],
        portionAdvice: 'Use a small portion (half cup) and fill half your plate with vegetables first.',
      ),
      const FoodKnowledge(
        nameEn: 'basmati rice',
        nameAr: 'أرز بسمتي',
        gi: 56, carbsPerServing: 40, category: 'grain',
        giCategory: 'medium',
        goodWith: ['chicken', 'fish', 'dal', 'vegetables'],
        alternatives: ['freekeh', 'burghul'],
        portionAdvice: 'Better than white rice. Still pair with protein and vegetables.',
      ),
      const FoodKnowledge(
        nameEn: 'freekeh',
        nameAr: 'فريك',
        gi: 40, carbsPerServing: 30, category: 'grain',
        giCategory: 'low',
        goodWith: ['chicken', 'lamb', 'vegetables', 'yogurt'],
        alternatives: ['burghul'],
        portionAdvice: 'Great choice — high fiber, lower GI. Enjoy with grilled meat and salad.',
      ),
      const FoodKnowledge(
        nameEn: 'burghul',
        nameAr: 'برغل',
        gi: 48, carbsPerServing: 28, category: 'grain',
        giCategory: 'low',
        goodWith: ['chicken', 'vegetables', 'tomato', 'parsley'],
        alternatives: ['freekeh'],
        portionAdvice: 'Excellent choice — high fiber, pairs beautifully with tabouleh.',
      ),
      const FoodKnowledge(
        nameEn: 'bread',
        nameAr: 'خبز',
        gi: 70, carbsPerServing: 30, category: 'grain',
        giCategory: 'high',
        goodWith: ['hummus', 'ful', 'cheese', 'labneh'],
        alternatives: ['baladi bread', 'whole wheat bread'],
        portionAdvice: 'If having bread, pair it with protein (hummus, ful, cheese) to slow the spike.',
      ),
      const FoodKnowledge(
        nameEn: 'baladi bread',
        nameAr: 'عيش بلدي',
        gi: 55, carbsPerServing: 25, category: 'grain',
        giCategory: 'medium',
        goodWith: ['ful', 'hummus', 'falafel', 'cheese'],
        alternatives: ['whole wheat bread'],
        portionAdvice: 'Better than white bread. Good with foul or hummus.',
      ),
      const FoodKnowledge(
        nameEn: 'pasta',
        nameAr: 'مكرونة',
        gi: 55, carbsPerServing: 40, category: 'grain',
        giCategory: 'medium',
        goodWith: ['chicken', 'vegetables', 'tomato sauce'],
        alternatives: ['burghul', 'whole wheat pasta'],
        portionAdvice: 'Al dente pasta has lower GI than overcooked. Keep portions moderate.',
      ),
      const FoodKnowledge(
        nameEn: 'koshari',
        nameAr: 'كوشري',
        gi: 65, carbsPerServing: 60, category: 'mixed',
        giCategory: 'high',
        goodWith: [],
        alternatives: ['mujaddara (lentils + rice)'],
        portionAdvice: 'Very carb-heavy. Split the portion or have it with a big salad.',
      ),
      const FoodKnowledge(
        nameEn: 'mujaddara',
        nameAr: 'مجدّرة',
        gi: 45, carbsPerServing: 35, category: 'mixed',
        giCategory: 'low',
        goodWith: ['yogurt', 'salad', 'onion'],
        alternatives: [],
        portionAdvice: 'Lentils slow the glucose rise. Great choice with yogurt and salad.',
      ),

      // ─── Proteins ───
      const FoodKnowledge(
        nameEn: 'chicken',
        nameAr: 'دجاج',
        gi: 0, carbsPerServing: 0, category: 'protein',
        giCategory: 'low',
        goodWith: ['rice', 'bread', 'salad', 'vegetables', 'freekeh'],
        alternatives: [],
        portionAdvice: 'Protein does not spike blood sugar. Great base for any meal.',
      ),
      const FoodKnowledge(
        nameEn: 'fish',
        nameAr: 'سمك',
        gi: 0, carbsPerServing: 0, category: 'protein',
        giCategory: 'low',
        goodWith: ['rice', 'vegetables', 'salad', 'lemon'],
        alternatives: [],
        portionAdvice: 'Excellent — no carbs, high protein, healthy fats.',
      ),
      const FoodKnowledge(
        nameEn: 'meat',
        nameAr: 'لحم',
        gi: 0, carbsPerServing: 0, category: 'protein',
        giCategory: 'low',
        goodWith: ['rice', 'bread', 'salad', 'grilled vegetables'],
        alternatives: [],
        portionAdvice: 'No carbs, but watch portion size for overall health.',
      ),
      const FoodKnowledge(
        nameEn: 'eggs',
        nameAr: 'بيض',
        gi: 0, carbsPerServing: 1, category: 'protein',
        giCategory: 'low',
        goodWith: ['bread', 'vegetables', 'cheese'],
        alternatives: [],
        portionAdvice: 'Perfect protein source — no glucose impact.',
      ),

      // ─── Legumes ───
      const FoodKnowledge(
        nameEn: 'hummus',
        nameAr: 'حمص',
        gi: 25, carbsPerServing: 12, category: 'legume',
        giCategory: 'low',
        goodWith: ['bread', 'vegetables', 'chicken', 'falafel'],
        alternatives: [],
        portionAdvice: 'Low GI, high fiber. Great with vegetables instead of bread.',
      ),
      const FoodKnowledge(
        nameEn: 'ful',
        nameAr: 'فول',
        gi: 30, carbsPerServing: 20, category: 'legume',
        giCategory: 'low',
        goodWith: ['bread', 'egg', 'vegetables', 'lemon'],
        alternatives: [],
        portionAdvice: 'Excellent — high fiber, slow-release carbs. One of the best breakfast options.',
      ),
      const FoodKnowledge(
        nameEn: 'falafel',
        nameAr: 'طعمية',
        gi: 35, carbsPerServing: 15, category: 'legume',
        giCategory: 'low',
        goodWith: ['hummus', 'salad', 'pickles', 'baladi bread'],
        alternatives: [],
        portionAdvice: 'Fried but still lower GI than bread alone. Have with salad.',
      ),
      const FoodKnowledge(
        nameEn: 'lentil soup',
        nameAr: 'شوربة عدس',
        gi: 30, carbsPerServing: 18, category: 'legume',
        giCategory: 'low',
        goodWith: ['bread', 'lemon', 'vegetables'],
        alternatives: [],
        portionAdvice: 'One of the best options — high fiber, low GI, filling.',
      ),

      // ─── Dairy ───
      const FoodKnowledge(
        nameEn: 'yogurt',
        nameAr: 'لبن',
        gi: 35, carbsPerServing: 12, category: 'dairy',
        giCategory: 'low',
        goodWith: ['cucumber', 'fruit', 'nuts'],
        alternatives: [],
        portionAdvice: 'Plain yogurt is great. Avoid flavored varieties with added sugar.',
      ),
      const FoodKnowledge(
        nameEn: 'cheese',
        nameAr: 'جبنة',
        gi: 0, carbsPerServing: 1, category: 'dairy',
        giCategory: 'low',
        goodWith: ['bread', 'vegetables', 'eggs'],
        alternatives: [],
        portionAdvice: 'No glucose impact. Good protein source.',
      ),
      const FoodKnowledge(
        nameEn: 'labneh',
        nameAr: 'لبنة',
        gi: 15, carbsPerServing: 4, category: 'dairy',
        giCategory: 'low',
        goodWith: ['bread', 'olives', 'vegetables'],
        alternatives: [],
        portionAdvice: 'Low GI, high protein. Excellent breakfast option.',
      ),

      // ─── Fruits ───
      const FoodKnowledge(
        nameEn: 'mango',
        nameAr: 'مانجو',
        gi: 56, carbsPerServing: 25, category: 'fruit',
        giCategory: 'medium',
        goodWith: ['yogurt', 'nuts'],
        alternatives: ['berries', 'apple', 'pear'],
        portionAdvice: 'Moderate GI. Have a small portion with protein (yogurt) to slow the spike.',
      ),
      const FoodKnowledge(
        nameEn: 'banana',
        nameAr: 'موز',
        gi: 51, carbsPerServing: 27, category: 'fruit',
        giCategory: 'medium',
        goodWith: ['peanut butter', 'yogurt', 'oats'],
        alternatives: ['apple', 'pear', 'berries'],
        portionAdvice: 'Moderate GI. Green (less ripe) bananas have lower GI.',
      ),
      const FoodKnowledge(
        nameEn: 'apple',
        nameAr: 'تفاح',
        gi: 36, carbsPerServing: 25, category: 'fruit',
        giCategory: 'low',
        goodWith: ['peanut butter', 'cheese', 'nuts'],
        alternatives: ['pear', 'berries'],
        portionAdvice: 'Great choice — low GI, high fiber. Eat with skin.',
      ),
      const FoodKnowledge(
        nameEn: 'orange',
        nameAr: 'برتقال',
        gi: 42, carbsPerServing: 22, category: 'fruit',
        giCategory: 'low',
        goodWith: ['nuts', 'yogurt'],
        alternatives: ['apple', 'pear'],
        portionAdvice: 'Lower GI than juice. Whole fruit is always better than juice.',
      ),
      const FoodKnowledge(
        nameEn: 'grapes',
        nameAr: 'عنب',
        gi: 59, carbsPerServing: 27, category: 'fruit',
        giCategory: 'medium',
        goodWith: ['cheese', 'nuts'],
        alternatives: ['berries', 'apple'],
        portionAdvice: 'Medium GI, easy to overeat. Stick to a small handful.',
      ),
      const FoodKnowledge(
        nameEn: 'dates',
        nameAr: 'تمر',
        gi: 70, carbsPerServing: 18, category: 'fruit',
        giCategory: 'high',
        goodWith: ['nuts', 'coffee', 'cheese'],
        alternatives: ['apple', 'pear'],
        portionAdvice: 'High GI but natural sugar. 2-3 dates max. Good for low blood sugar.',
      ),
      const FoodKnowledge(
        nameEn: 'watermelon',
        nameAr: 'بطيخ',
        gi: 76, carbsPerServing: 11, category: 'fruit',
        giCategory: 'high',
        goodWith: ['feta cheese', 'mint'],
        alternatives: ['berries', 'apple'],
        portionAdvice: 'High GI but low carb load per serving. Small portion is ok.',
      ),

      // ─── Vegetables ───
      const FoodKnowledge(
        nameEn: 'salad',
        nameAr: 'سلطة',
        gi: 10, carbsPerServing: 5, category: 'vegetable',
        giCategory: 'low',
        goodWith: ['everything'],
        alternatives: [],
        portionAdvice: 'Always start your meal with salad — it slows glucose absorption.',
      ),
      const FoodKnowledge(
        nameEn: 'vegetables',
        nameAr: 'خضار',
        gi: 15, carbsPerServing: 8, category: 'vegetable',
        giCategory: 'low',
        goodWith: ['everything'],
        alternatives: [],
        portionAdvice: 'Fill half your plate with vegetables. They slow glucose rise.',
      ),

      // ─── Sweets ───
      const FoodKnowledge(
        nameEn: 'cake',
        nameAr: 'كعك',
        gi: 65, carbsPerServing: 45, category: 'sweet',
        giCategory: 'high',
        goodWith: [],
        alternatives: ['dates with nuts', 'fruit with yogurt'],
        portionAdvice: 'High GI, high carbs. If you must, have a tiny piece after a protein-rich meal.',
      ),
      const FoodKnowledge(
        nameEn: 'chocolate',
        nameAr: 'شوكولاتة',
        gi: 49, carbsPerServing: 30, category: 'sweet',
        giCategory: 'medium',
        goodWith: ['nuts', 'coffee'],
        alternatives: ['dark chocolate (70%+)', 'dates'],
        portionAdvice: 'Dark chocolate (70%+) is better. Small square after a meal.',
      ),
      const FoodKnowledge(
        nameEn: 'ice cream',
        nameAr: 'آيس كريم',
        gi: 50, carbsPerServing: 30, category: 'sweet',
        giCategory: 'medium',
        goodWith: [],
        alternatives: ['frozen yogurt', 'fruit sorbet'],
        portionAdvice: 'The fat slows absorption, so GI is moderate. Still high in sugar.',
      ),

      // ─── Drinks ───
      const FoodKnowledge(
        nameEn: 'juice',
        nameAr: 'عصير',
        gi: 65, carbsPerServing: 30, category: 'drink',
        giCategory: 'high',
        goodWith: [],
        alternatives: ['whole fruit', 'water with lemon', 'unsweetened tea'],
        portionAdvice: 'Juice removes fiber and spikes sugar fast. Whole fruit is always better.',
      ),
      const FoodKnowledge(
        nameEn: 'tea',
        nameAr: 'شاي',
        gi: 0, carbsPerServing: 0, category: 'drink',
        giCategory: 'low',
        goodWith: [],
        alternatives: [],
        portionAdvice: 'Unsweetened tea is fine. Avoid adding sugar.',
      ),
      const FoodKnowledge(
        nameEn: 'coffee',
        nameAr: 'قهوة',
        gi: 0, carbsPerServing: 2, category: 'drink',
        giCategory: 'low',
        goodWith: ['dates', 'nuts'],
        alternatives: [],
        portionAdvice: 'Black coffee is fine. Avoid sugary coffee drinks.',
      ),
      const FoodKnowledge(
        nameEn: 'water',
        nameAr: 'مي',
        gi: 0, carbsPerServing: 0, category: 'drink',
        giCategory: 'low',
        goodWith: [],
        alternatives: [],
        portionAdvice: 'Always the best choice. Stay hydrated.',
      ),
    ];

    for (final f in foods) {
      _kb[f.nameEn.toLowerCase()] = f;
      _kb[f.nameAr] = f;
    }
  }

  static FoodKnowledge? find(String query) {
    initialize();
    final lower = query.toLowerCase().trim();

    // Direct match
    if (_kb.containsKey(lower)) return _kb[lower];

    // Partial match — check if query contains a known food name
    for (final entry in _kb.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }

    // Word-level match
    final words = lower.split(RegExp(r'\s+'));
    for (final word in words) {
      if (_kb.containsKey(word)) return _kb[word];
      for (final entry in _kb.entries) {
        if (entry.key.contains(word) || word.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // Fuzzy match (Levenshtein distance)
    FoodKnowledge? bestMatch;
    int bestDistance = 999;
    for (final entry in _kb.entries) {
      final dist = _levenshtein(lower, entry.key);
      if (dist < bestDistance && dist <= 3) {
        bestDistance = dist;
        bestMatch = entry.value;
      }
    }

    return bestMatch;
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = math.min(
          math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[a.length][b.length];
  }
}

// ─── Intent Classifier ─────────────────────────────────────────────────

class IntentClassifier {
  static AdvisorIntent classify(String text) {
    final lower = text.toLowerCase().trim();

    // Greeting
    if (RegExp(r'^(hi|hello|hey|yo|morning|evening|afternoon|مرحبا|السلام|صباح|مساء)')
        .hasMatch(lower)) {
      return AdvisorIntent.greeting;
    }

    // Thanks
    if (RegExp(r'(thanks|thank you|شكرا|مشكور|يعطيك العافية)')
        .hasMatch(lower)) {
      return AdvisorIntent.thanks;
    }

    // Mood / emotional
    if (RegExp(r'(i feel|I feel|i.m\s+(sad|frustrated|tired|stressed|worried|anxious|overwhelmed))')
        .hasMatch(lower)) {
      return AdvisorIntent.mood;
    }

    // Sugar check
    if (RegExp(r'(my\s+(sugar|level|glucose|reading)|check\s+(sugar|level)|how.s?\s+my|what.s?\s+my\s+(sugar|level|number|glucose))')
        .hasMatch(lower)) {
      return AdvisorIntent.sugarCheck;
    }

    // What can I eat
    if (RegExp(r'(what\s+(can|should|do|may)\s+i\s+(eat|have|drink|take))|what.s?\s+(good|safe|ok|better)|what\s+do\s+you\s+suggest|give\s+me\s+(ideas|suggestions|options)')
        .hasMatch(lower)) {
      return AdvisorIntent.whatCanIEat;
    }

    // Can I eat
    if (RegExp(r'(can\s+i|should\s+i|am\s+i\s+(allowed|ok|able)|is\s+(it|this)\s+(ok|safe|fine|good|allowed)|may\s+i|does\s+(this|it)\s+(have|contain)\s+(sugar|carbs))')
        .hasMatch(lower)) {
      return AdvisorIntent.canIEat;
    }

    // Help
    if (RegExp(r'(help|what\s+can\s+you|how\s+do|벨프|guide|tell\s+me\s+what\s+you\s+can)')
        .hasMatch(lower)) {
      return AdvisorIntent.help;
    }

    // Food question (check if any food word is present)
    if (FoodKnowledgeBase.find(lower) != null) {
      return AdvisorIntent.foodQuestion;
    }

    // Check for food-related keywords even if not in KB
    if (RegExp(r'(eat|drink|food|meal|snack|breakfast|lunch|dinner|fruit|vegetable|meat|chicken|rice|bread|sugar|carb|calorie|diet|iftar|suhoor)')
        .hasMatch(lower)) {
      return AdvisorIntent.foodQuestion;
    }

    return AdvisorIntent.unknown;
  }
}

// ─── Main Advisor ──────────────────────────────────────────────────────

class SmartAdvisor {
  static final ConversationMemory memory = ConversationMemory();

  static AdvisorResponse advise({
    required String userMessage,
    required List<GlucoseEntry> recentEntries,
    required GlycemicTargets targets,
  }) {
    final intent = IntentClassifier.classify(userMessage);
    final glucose =
        recentEntries.isNotEmpty ? recentEntries.first.mgdl : null;
    final now = DateTime.now();

    switch (intent) {
      case AdvisorIntent.greeting:
        return _greeting(glucose, now);
      case AdvisorIntent.thanks:
        return _thanks();
      case AdvisorIntent.mood:
        return _mood(userMessage, glucose);
      case AdvisorIntent.sugarCheck:
        return _sugarCheck(glucose, targets);
      case AdvisorIntent.whatCanIEat:
        return _whatCanIEat(glucose, targets);
      case AdvisorIntent.canIEat:
        return _canIEat(userMessage, glucose, targets);
      case AdvisorIntent.foodQuestion:
        return _foodQuestion(userMessage, glucose, targets);
      case AdvisorIntent.help:
        return _help();
      default:
        return _unknown(userMessage);
    }
  }

  // ─── Greeting ─────────────────────────────────────────────────────

  static AdvisorResponse _greeting(double? glucose, DateTime now) {
    final hour = now.hour;
    String timeWord;
    if (hour < 12) {
      timeWord = 'morning';
    } else if (hour < 17) {
      timeWord = 'afternoon';
    } else {
      timeWord = 'evening';
    }

    String text = 'Good $timeWord! ';
    if (glucose != null) {
      if (glucose < 70) {
        text += 'Your last reading was ${_fmt(glucose)} — a bit low. '
            'Have you had something to eat? ';
      } else if (glucose > 200) {
        text += 'Your last reading was ${_fmt(glucose)} — running high. '
            'Let me know if you need food advice. ';
      } else {
        text += 'Your last reading was ${_fmt(glucose)} — looking good. ';
      }
    }
    text += 'Ask me about any food, or say "What can I eat?"';

    return AdvisorResponse(
      intent: AdvisorIntent.greeting,
      text: text,
      followUp: 'What can I eat?',
    );
  }

  static AdvisorResponse _thanks() {
    final responses = [
      'You are welcome! Remember, managing diabetes is a journey, not a test. You are doing great.',
      'Happy to help! Every small choice adds up. Keep going.',
      'Anytime! Your health matters, and asking questions is a sign of strength.',
    ];
    return AdvisorResponse(
      intent: AdvisorIntent.thanks,
      text: responses[math.Random().nextInt(responses.length)],
    );
  }

  static AdvisorResponse _mood(String message, double? glucose) {
    String text;
    if (glucose != null && glucose > 200) {
      text = 'I hear you. High blood sugar can make anyone feel drained. '
          'Your body is working hard right now. '
          'Try a short walk if you can, drink water, and remember this is temporary. '
          'You are not failing — your body is just having a tough moment.';
    } else if (glucose != null && glucose < 70) {
      text = 'Feeling low is scary, but you know what to do — '
          '15 grams of fast carbs, wait 15 minutes, recheck. '
          'You have handled this before and you will handle it again.';
    } else {
      text = 'Diabetes can be emotionally heavy sometimes, and that is completely valid. '
          'You are doing more than most people realize. '
          'Take it one meal, one reading at a time. I am here whenever you need me.';
    }

    return AdvisorResponse(
      intent: AdvisorIntent.mood,
      text: text,
      followUp: 'Do you want me to suggest something to eat?',
    );
  }

  // ─── Sugar Check ──────────────────────────────────────────────────

  static AdvisorResponse _sugarCheck(double? glucose, GlycemicTargets t) {
    if (glucose == null) {
      return const AdvisorResponse(
        intent: AdvisorIntent.sugarCheck,
        text: 'I do not have a recent reading yet. Log one and I will track it for you.',
        followUp: 'Say "Log 120 before meal" to save a reading.',
      );
    }

    String status;
    String advice;
    bool warning = false;

    if (glucose < 54) {
      status = 'critically low';
      advice = 'Follow the 15-15 rule immediately: 15g fast carbs (juice, glucose tablets), '
          'wait 15 minutes, recheck. If you feel confused or cannot treat yourself, '
          'ask someone to help.';
      warning = true;
    } else if (glucose < 70) {
      status = 'low';
      advice = 'Have 15g of fast-acting carbs — a small glass of juice or 4 glucose tablets. '
          'Recheck in 15 minutes. Then have a small snack with protein to prevent another drop.';
      warning = true;
    } else if (glucose < 100) {
      status = 'on the lower side';
      advice = 'You are in range but leaning low. If you are about to exercise, '
          'have a small snack first. Otherwise, you are fine.';
    } else if (glucose <= 140) {
      status = 'in a great range';
      advice = 'This is a good number. Whatever you are doing — keep it up.';
    } else if (glucose <= 180) {
      status = 'slightly elevated';
      advice = 'A bit above the ideal range. A short walk can help bring this down. '
          'If this is after a meal, consider eating vegetables before carbs next time.';
    } else if (glucose <= 250) {
      status = 'elevated';
      advice = 'Running high. Drink water, avoid more carbs for now, and consider a short walk. '
          'If this persists, contact your care team.';
      warning = true;
    } else {
      status = 'significantly elevated';
      advice = 'This is quite high. Drink plenty of water, avoid carbs, '
          'and check for ketones if you feel unwell (nausea, fruity breath, confusion). '
          'Contact your healthcare provider if you feel worse.';
      warning = true;
    }

    return AdvisorResponse(
      intent: AdvisorIntent.sugarCheck,
      text: 'Your reading is ${_fmt(glucose)} mg/dL — $status.\n\n$advice',
      isWarning: warning,
      followUp: glucose > 180 ? 'Do you want low-carb meal ideas?' : 'Ask me about any food.',
    );
  }

  // ─── What Can I Eat ───────────────────────────────────────────────

  static AdvisorResponse _whatCanIEat(double? glucose, GlycemicTargets t) {
    if (glucose == null) {
      return const AdvisorResponse(
        intent: AdvisorIntent.whatCanIEat,
        text: 'I need your latest reading to give the best advice. '
            'Log your sugar first, then ask me "What can I eat?"',
        followUp: 'Say "Log [number] before meal" to save a reading.',
      );
    }

    String text;
    if (glucose < 70) {
      text = 'Your sugar is ${_fmt(glucose)} — a bit low. Here are quick options:\n\n'
          '\u2022 2-3 dates — fast natural sugar\n'
          '\u2022 A small glass of juice\n'
          '\u2022 Banana — moderate GI, easy to eat\n'
          '\u2022 Whole wheat bread with honey\n\n'
          'After you recover, have a balanced snack with protein to stay stable.';
    } else if (glucose < 100) {
      text = 'Your sugar is ${_fmt(glucose)} — on the lower side. Good options:\n\n'
          '\u2022 Apple with peanut butter\n'
          '\u2022 Yogurt with a few nuts\n'
          '\u2022 Hummus with vegetable sticks\n'
          '\u2022 Hard-boiled egg\n\n'
          'These have protein + carbs to keep you steady.';
    } else if (glucose <= 140) {
      text = 'Your sugar is ${_fmt(glucose)} — great range. You have lots of options:\n\n'
          '\u2022 Balanced meal: protein + vegetables + moderate carbs\n'
          '\u2022 Grilled chicken with salad and freekeh\n'
          '\u2022 Fish with vegetables\n'
          '\u2022 Lentil soup with a small piece of bread\n'
          '\u2022 Ful with vegetables and baladi bread\n\n'
          'Start with vegetables or protein before carbs for the best result.';
    } else if (glucose <= 180) {
      text = 'Your sugar is ${_fmt(glucose)} — slightly elevated. Best to go lower-carb:\n\n'
          '\u2022 Grilled chicken or fish with salad (no bread)\n'
          '\u2022 Hummus with cucumber and tomato\n'
          '\u2022 Lentil soup — high fiber, low GI\n'
          '\u2022 Labneh with vegetables\n'
          '\u2022 Egg salad\n\n'
          'Skip the rice, bread, and sweets for now. A 15-minute walk after eating helps too.';
    } else {
      text = 'Your sugar is ${_fmt(glucose)} — running high. Keep it simple:\n\n'
          '\u2022 Water — stay hydrated\n'
          '\u2022 Grilled chicken or fish with non-starchy vegetables\n'
          '\u2022 Salad with olive oil and lemon\n'
          '\u2022 Lentil soup (small portion)\n\n'
          'Avoid: rice, bread, pasta, sweets, juice, fruit. '
          'Focus on protein and vegetables. A short walk will help bring this down.';
    }

    return AdvisorResponse(
      intent: AdvisorIntent.whatCanIEat,
      text: text,
      followUp: 'Ask me about any specific food for more details.',
    );
  }

  // ─── Can I Eat ────────────────────────────────────────────────────

  static AdvisorResponse _canIEat(
      String message, double? glucose, GlycemicTargets t) {
    final food = FoodKnowledgeBase.find(message);
    if (food == null) {
      return AdvisorResponse(
        intent: AdvisorIntent.canIEat,
        text: 'I could not identify the specific food you are asking about. '
            'Try naming it directly — "Can I eat rice?" or "Is bread ok?"',
        followUp: 'I know foods like rice, bread, chicken, fruits, and more.',
      );
    }

    if (glucose == null) {
      return AdvisorResponse(
        intent: AdvisorIntent.canIEat,
        text: 'I do not have a recent reading to check against. '
            'Log your sugar first, then ask me about ${food.nameEn}.\n\n'
            'Meanwhile: ${food.nameAr} (${food.nameEn}) — '
            'GI ~${food.gi}, ${food.carbsPerServing.toStringAsFixed(0)}g carbs per serving.',
        foodName: food.nameEn,
        followUp: 'Log a reading and ask me again.',
      );
    }

    // High glucose
    if (glucose > 250) {
      final alt = _suggestAlternative(food);
      return AdvisorResponse(
        intent: AdvisorIntent.canIEat,
        text: 'Your sugar is ${_fmt(glucose)} — quite high. I would skip ${food.nameAr} for now.\n\n'
            '${food.carbsPerServing > 0 ? '${food.nameEn} has ~${food.carbsPerServing.toStringAsFixed(0)}g carbs.' : ''} '
            'Focus on water, a short walk, and follow your correction protocol.\n\n'
            '$alt',
        foodName: food.nameEn,
        isWarning: true,
        swapSuggestion: alt,
        followUp: 'When your sugar comes down, ask me again.',
      );
    }

    if (glucose > t.rangeHigh) {
      if (food.giCategory == 'high') {
        final alt = _suggestAlternative(food);
        return AdvisorResponse(
          intent: AdvisorIntent.canIEat,
          text: 'Your sugar is ${_fmt(glucose)} — above target. '
              '${food.nameAr} (${food.nameEn}) has GI ~${food.gi} (high) '
              'and ${food.carbsPerServing.toStringAsFixed(0)}g carbs.\n\n'
              'I would wait or choose a lower-GI swap:\n$alt',
          foodName: food.nameEn,
          isWarning: true,
          swapSuggestion: alt,
        );
      }

      return AdvisorResponse(
        intent: AdvisorIntent.canIEat,
        text: 'Your sugar is ${_fmt(glucose)} — slightly above target. '
            '${food.nameAr} (${food.nameEn}) has GI ~${food.gi}, '
            '${food.carbsPerServing.toStringAsFixed(0)}g carbs.\n\n'
            '${food.goodWith.isNotEmpty ? 'Best paired with: ${food.goodWith.join(", ")}.' : ''} '
            '${food.portionAdvice}',
        foodName: food.nameEn,
        followUp: 'Have a small portion with protein and vegetables first.',
      );
    }

    // Low glucose
    if (glucose < t.rangeLow) {
      return AdvisorResponse(
        intent: AdvisorIntent.canIEat,
        text: 'Your sugar is ${_fmt(glucose)} — low. '
            '${food.nameAr} (${food.nameEn}) could actually help bring you up '
            '${food.carbsPerServing > 0 ? '(${food.carbsPerServing.toStringAsFixed(0)}g carbs)' : ''}.\n\n'
            'Have a portion now, then recheck in 15 minutes.',
        foodName: food.nameEn,
        followUp: 'If you feel symptoms, follow the 15-15 rule.',
      );
    }

    // In range
    return AdvisorResponse(
      intent: AdvisorIntent.canIEat,
      text: 'Your sugar is ${_fmt(glucose)} — in your target range. '
          '${food.nameAr} (${food.nameEn}) — GI ~${food.gi}, '
          '${food.carbsPerServing.toStringAsFixed(0)}g carbs.\n\n'
          '${food.giCategory == 'high' ? 'Higher GI — pair with protein or vegetables to slow the spike.' : 'Good choice!'} '
          '${food.portionAdvice}',
      foodName: food.nameEn,
      followUp: 'Want me to suggest what to pair it with?',
    );
  }

  // ─── Food Question ────────────────────────────────────────────────

  static AdvisorResponse _foodQuestion(
      String message, double? glucose, GlycemicTargets t) {
    final food = FoodKnowledgeBase.find(message);
    if (food == null) {
      return AdvisorResponse(
        intent: AdvisorIntent.foodQuestion,
        text: 'I am not sure which food you mean. Can you name it directly? '
            'For example: rice, bread, chicken, mango, hummus, dates...',
        followUp: 'I know grains, proteins, fruits, vegetables, dairy, and more.',
      );
    }

    String giDesc;
    if (food.gi <= 35) {
      giDesc = 'low GI — gentle on blood sugar';
    } else if (food.gi <= 55) {
      giDesc = 'moderate GI — reasonable choice';
    } else if (food.gi <= 70) {
      giDesc = 'medium-high GI — pairing with protein helps';
    } else {
      giDesc = 'high GI — causes a faster spike';
    }

    String text = '${food.nameAr} (${food.nameEn})\n\n'
        '\u2022 GI: ~${food.gi} ($giDesc)\n'
        '\u2022 Carbs: ~${food.carbsPerServing.toStringAsFixed(0)}g per serving\n'
        '\u2022 Category: ${food.category}\n';

    if (food.goodWith.isNotEmpty) {
      text += '\nPairs well with: ${food.goodWith.join(", ")}';
    }

    if (food.alternatives.isNotEmpty) {
      text += '\nLower-GI alternatives: ${food.alternatives.join(", ")}';
    }

    text += '\n\n${food.portionAdvice}';

    // Personalize with glucose
    if (glucose != null) {
      text += '\n\n';
      if (glucose > t.rangeHigh) {
        if (food.giCategory == 'high') {
          text += 'Your sugar is ${_fmt(glucose)} — I would wait on this one.';
        } else {
          text += 'Your sugar is ${_fmt(glucose)} — this is a reasonable choice.';
        }
      } else if (glucose < t.rangeLow) {
        text += 'Your sugar is ${_fmt(glucose)} — this could help bring you up.';
      } else {
        text += 'Your sugar is ${_fmt(glucose)} — you are in a good range for this.';
      }
    }

    return AdvisorResponse(
      intent: AdvisorIntent.foodQuestion,
      text: text,
      foodName: food.nameEn,
      followUp: food.alternatives.isNotEmpty
          ? 'Want to know about ${food.alternatives.first}?'
          : 'Ask me about anything else.',
    );
  }

  // ─── Help ─────────────────────────────────────────────────────────

  static AdvisorResponse _help() {
    return const AdvisorResponse(
      intent: AdvisorIntent.help,
      text: 'I am your diabetes nutrition advisor. Here is what I can do:\n\n'
          '\u2022 Ask about any food: "What about rice?" or "Tell me about mango"\n'
          '\u2022 Check if you can eat: "Can I eat bread?"\n'
          '\u2022 Get meal ideas: "What can I eat?"\n'
          '\u2022 Check your level: "How is my sugar?"\n'
          '\u2022 Log a reading: "Log 120 before meal"\n'
          '\u2022 Mark medication: "Took my metformin"\n\n'
          'I remember your recent readings and give advice based on your current sugar level. '
          'I also suggest smarter alternatives from the Kitchen tab.',
      followUp: 'Try asking about a food!',
    );
  }

  // ─── Unknown ──────────────────────────────────────────────────────

  static AdvisorResponse _unknown(String message) {
    return AdvisorResponse(
      intent: AdvisorIntent.unknown,
      text: 'I am not sure what you mean. I can help with food advice, '
          'sugar checks, and meal suggestions.\n\n'
          'Try: "What about rice?" or "Can I eat bread?" or "What can I eat?"',
      followUp: 'Say "help" to see everything I can do.',
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  static String _fmt(double v) => v.toStringAsFixed(0);

  static String _suggestAlternative(FoodKnowledge food) {
    if (food.alternatives.isNotEmpty) {
      return 'Try instead: ${food.alternatives.join(", ")} — '
          'these have lower GI and are gentler on blood sugar.\n'
          'Check the Kitchen tab for smart dish versions.';
    }

    if (food.category == 'grain') {
      return 'Try freekeh or bulgur instead — much lower GI. '
          'Check the Kitchen tab for smart swaps.';
    }
    if (food.category == 'fruit') {
      return 'Whole fruit is better than juice. '
          'Try apple, pear, or berries — lower GI options.';
    }
    if (food.category == 'sweet') {
      return 'Try dates with nuts — natural sugar with fiber and protein. '
          'Or a small piece of dark chocolate (70%+).';
    }
    if (food.category == 'drink') {
      return 'Water, unsweetened tea, or black coffee are always safe.';
    }

    return 'A smaller portion with protein and vegetables '
        'can help manage the spike.';
  }
}
