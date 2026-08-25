import '../models/food_item.dart';
import '../models/glucose_entry.dart';
import '../models/targets.dart';
import '../services/food_database.dart';

enum AdvisorIntent {
  foodQuestion,
  canIEat,
  whatCanIEat,
  sugarCheck,
  greeting,
  help,
  unknown,
}

class AdvisorContext {
  final AdvisorIntent intent;
  final String foodMentioned;
  final String response;
  final String? suggestion;
  final bool isWarning;
  final bool showKitchenSwap;

  const AdvisorContext({
    required this.intent,
    required this.foodMentioned,
    required this.response,
    this.suggestion,
    this.isWarning = false,
    this.showKitchenSwap = false,
  });
}

class VoiceAdvisor {
  static final List<AdvisorContext> _conversationHistory = [];
  static const int _maxHistory = 20;

  static List<AdvisorContext> get history =>
      List.unmodifiable(_conversationHistory);

  static void clearHistory() => _conversationHistory.clear();

  static AdvisorContext advise({
    required String userMessage,
    required List<GlucoseEntry> recentEntries,
    required GlycemicTargets targets,
  }) {
    final lower = userMessage.toLowerCase().trim();
    final latestGlucose =
        recentEntries.isNotEmpty ? recentEntries.first.mgdl : null;

    // Detect intent
    final intent = _detectIntent(lower);

    switch (intent) {
      case AdvisorIntent.foodQuestion:
        return _handleFoodQuestion(lower, latestGlucose, targets);
      case AdvisorIntent.canIEat:
        return _handleCanIEat(lower, latestGlucose, targets);
      case AdvisorIntent.whatCanIEat:
        return _handleWhatCanIEat(latestGlucose, targets);
      case AdvisorIntent.sugarCheck:
        return _handleSugarCheck(latestGlucose, targets);
      case AdvisorIntent.greeting:
        return _handleGreeting(latestGlucose);
      case AdvisorIntent.help:
        return _handleHelp();
      default:
        return _handleUnknown(lower);
    }
  }

  static AdvisorIntent _detectIntent(String lower) {
    // Food question: "mango juice", "what about rice", "tell me about bread"
    if (RegExp(r'(what about|tell me about|how about|info|gi|glycemic)')
        .hasMatch(lower)) {
      return AdvisorIntent.foodQuestion;
    }

    // Can I eat: "can i eat", "should i eat", "am i allowed", "is ok to eat"
    if (RegExp(r'(can\s+i|should\s+i|am\s+i\s+allowed|is\s+(it\s+)?ok|may\s+i)')
        .hasMatch(lower)) {
      return AdvisorIntent.canIEat;
    }

    // What can I eat: "what can i eat", "what should i eat", "what's safe"
    if (RegExp(r'(what\s+(can|should|do)\s+i\s+(eat|have|drink))|what.s?\s+safe')
        .hasMatch(lower)) {
      return AdvisorIntent.whatCanIEat;
    }

    // Sugar check: "my sugar", "check sugar", "how's my level"
    if (RegExp(r'(my\s+(sugar|level|glucose)|check\s+(sugar|level)|how.s?\s+is\s+my)')
        .hasMatch(lower)) {
      return AdvisorIntent.sugarCheck;
    }

    // Greeting
    if (RegExp(r'^(hi|hello|hey|morning|evening|afternoon|مرحبا|السلام)')
        .hasMatch(lower)) {
      return AdvisorIntent.greeting;
    }

    // Help
    if (RegExp(r'(help|what can you|how do|commands|벨프)')
        .hasMatch(lower)) {
      return AdvisorIntent.help;
    }

    return AdvisorIntent.unknown;
  }

  static AdvisorContext _handleFoodQuestion(
      String lower, double? glucose, GlycemicTargets targets) {
    // Try to find a food mention
    final food = _findFood(lower);
    if (food != null) {
      final gi = _estimateGI(food);
      final carbs = food.portions.isNotEmpty
          ? food.portions.first.carbGrams
          : 0;

      String response;
      bool isWarning = false;
      String? suggestion;

      if (glucose != null && glucose > targets.rangeHigh) {
        response =
            '${food.nameAr} (${food.nameEn}) has about ${carbs.toStringAsFixed(0)}g carbs '
            'per portion with a GI around $gi. '
            'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — that is above your target. '
            'I would wait until it comes down before having this.';
        isWarning = true;

        // Find a lower-GI alternative
        suggestion = _findLowerGIAlternative(food);
      } else if (glucose != null && glucose < targets.rangeLow) {
        response =
            'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — a bit low. '
            '${food.nameAr} (${food.nameEn}) has ${carbs.toStringAsFixed(0)}g carbs. '
            'This could actually help bring you up. Have a small portion.';
      } else {
        response =
            '${food.nameAr} (${food.nameEn}): about ${carbs.toStringAsFixed(0)}g carbs '
            'per portion, GI around $gi. '
            '${gi > 70 ? "This is a higher-GI food — pairing it with protein or vegetables can slow the spike." : gi > 55 ? "Moderate GI — a reasonable choice with a balanced meal." : "Lower GI — a gentler option for blood sugar."}';
      }

      final ctx = AdvisorContext(
        intent: AdvisorIntent.foodQuestion,
        foodMentioned: food.nameEn,
        response: response,
        suggestion: suggestion,
        isWarning: isWarning,
        showKitchenSwap: isWarning,
      );
      _addToHistory(ctx);
      return ctx;
    }

    return const AdvisorContext(
      intent: AdvisorIntent.foodQuestion,
      foodMentioned: '',
      response:
          'I could not identify a specific food. Try saying something like '
          '"What about mango juice?" or "Tell me about rice".',
    );
  }

  static AdvisorContext _handleCanIEat(
      String lower, double? glucose, GlycemicTargets targets) {
    final food = _findFood(lower);
    if (food == null) {
      return const AdvisorContext(
        intent: AdvisorIntent.canIEat,
        foodMentioned: '',
        response:
            'I could not identify the food you are asking about. '
            'Try saying "Can I eat rice?" or "Is bread ok for me?"',
      );
    }

    final gi = _estimateGI(food);
    final carbs =
        food.portions.isNotEmpty ? food.portions.first.carbGrams : 0;

    if (glucose == null) {
      return AdvisorContext(
        intent: AdvisorIntent.canIEat,
        foodMentioned: food.nameEn,
        response:
            'I do not have a recent reading to check against. '
            'Log your sugar first, then ask me about ${food.nameEn}. '
            'Meanwhile: ${food.nameAr} has ${carbs.toStringAsFixed(0)}g carbs, GI ~$gi.',
      );
    }

    if (glucose > 250) {
      final alt = _findLowerGIAlternative(food);
      return AdvisorContext(
        intent: AdvisorIntent.canIEat,
        foodMentioned: food.nameEn,
        response:
            'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — quite high. '
            'I would skip ${food.nameAr} (${food.nameEn}) for now. '
            'Focus on water, a short walk, and follow your correction protocol. '
            'We can revisit this when your level comes down.',
        isWarning: true,
        suggestion: alt,
        showKitchenSwap: true,
      );
    }

    if (glucose > targets.rangeHigh) {
      return AdvisorContext(
        intent: AdvisorIntent.canIEat,
        foodMentioned: food.nameEn,
        response:
            'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — slightly above target. '
            '${food.nameAr} has ${carbs.toStringAsFixed(0)}g carbs (GI ~$gi). '
            '${gi > 70 ? "This is high-GI — I would wait or choose a lower-GI swap." : "You can have a small portion, ideally with protein and vegetables first."}',
        suggestion: gi > 70 ? _findLowerGIAlternative(food) : null,
        showKitchenSwap: gi > 70,
      );
    }

    if (glucose < targets.rangeLow) {
      return AdvisorContext(
        intent: AdvisorIntent.canIEat,
        foodMentioned: food.nameEn,
        response:
            'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — low. '
            '${food.nameAr} has ${carbs.toStringAsFixed(0)}g carbs and could help bring you up. '
            'Have a small portion now, then recheck in 15 minutes.',
      );
    }

    // In range
    return AdvisorContext(
      intent: AdvisorIntent.canIEat,
      foodMentioned: food.nameEn,
      response:
          'Your sugar is ${glucose.toStringAsFixed(0)} mg/dL — in your target range. '
          '${food.nameAr} (${food.nameEn}) has ${carbs.toStringAsFixed(0)}g carbs, GI ~$gi. '
          '${gi > 70 ? "Higher GI — have it with protein or veggies to slow the spike." : "Good to go! A balanced portion should be fine."}',
    );
  }

  static AdvisorContext _handleWhatCanIEat(
      double? glucose, GlycemicTargets targets) {
    if (glucose == null) {
      return const AdvisorContext(
        intent: AdvisorIntent.whatCanIEat,
        foodMentioned: '',
        response:
            'I need a recent reading to give you the best advice. '
            'Log your sugar, then ask me "What can I eat?" and I will '
            'suggest foods based on your current level.',
      );
    }

    List<String> suggestions;

    if (glucose > targets.rangeHigh) {
      suggestions = [
        'Grilled chicken or fish with salad',
        'Hummus with vegetables (not bread)',
        'Lentil soup (low GI, high fiber)',
        'Labneh with cucumber',
      ];
    } else if (glucose < targets.rangeLow) {
      suggestions = [
        'Dates (2-3) — fast-acting natural sugar',
        'Fresh fruit juice (small glass)',
        'Whole wheat bread with honey',
        'Banana — moderate GI, easy to eat',
      ];
    } else {
      suggestions = [
        'Balanced meal: protein + veggies + moderate carbs',
        'Fattoush or tabouleh as a starter',
        'Grilled meat withburghul',
        'Any of your Kitchen smart dishes',
      ];
    }

    final response = 'At ${glucose.toStringAsFixed(0)} mg/dL, '
        'here are some good options:\n'
        '${suggestions.map((s) => '\u2022 $s').join('\n')}';

    return AdvisorContext(
      intent: AdvisorIntent.whatCanIEat,
      foodMentioned: '',
      response: response,
    );
  }

  static AdvisorContext _handleSugarCheck(
      double? glucose, GlycemicTargets targets) {
    if (glucose == null) {
      return const AdvisorContext(
        intent: AdvisorIntent.sugarCheck,
        foodMentioned: '',
        response:
            'I do not have any recent readings. Log a reading and I will track it for you.',
      );
    }

    String status;
    if (glucose < targets.rangeLow) {
      status = 'low — follow the 15-15 rule';
    } else if (glucose < 100) {
      status = 'on the lower side of your range';
    } else if (glucose <= targets.rangeHigh) {
      status = 'in your target range';
    } else if (glucose <= 250) {
      status = 'above your target';
    } else {
      status = 'significantly elevated — check for ketones if you feel unwell';
    }

    return AdvisorContext(
      intent: AdvisorIntent.sugarCheck,
      foodMentioned: '',
      response:
          'Your latest reading is ${glucose.toStringAsFixed(0)} mg/dL — $status.',
      isWarning: glucose > 250 || glucose < targets.rangeLow,
    );
  }

  static AdvisorContext _handleGreeting(double? glucose) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    String response = '$timeGreeting! ';
    if (glucose != null) {
      response += 'Your last reading was ${glucose.toStringAsFixed(0)} mg/dL. ';
    }
    response += 'How can I help you today? You can ask me about any food, '
        'or say "What can I eat?"';

    return AdvisorContext(
      intent: AdvisorIntent.greeting,
      foodMentioned: '',
      response: response,
    );
  }

  static AdvisorContext _handleHelp() {
    return const AdvisorContext(
      intent: AdvisorIntent.help,
      foodMentioned: '',
      response:
          'I can help you with:\n'
          '\u2022 Ask about any food: "What about rice?" or "Tell me about mango juice"\n'
          '\u2022 Check if you can eat something: "Can I eat bread?"\n'
          '\u2022 Get suggestions: "What can I eat?"\n'
          '\u2022 Check your level: "How is my sugar?"\n'
          '\u2022 Log a reading: "Log 120 before meal"\n'
          '\nI remember your recent readings and can give personalized advice.',
    );
  }

  static AdvisorContext _handleUnknown(String lower) {
    return const AdvisorContext(
      intent: AdvisorIntent.unknown,
      foodMentioned: '',
      response:
          'I am not sure what you mean. Try asking about a food '
          '("What about rice?"), checking your level ("How is my sugar?"), '
          'or getting meal ideas ("What can I eat?").',
    );
  }

  // ─── Food Lookup ──────────────────────────────────────────────────

  static FoodItem? _findFood(String lower) {
    // Search in English and Arabic names
    for (final food in defaultFoods) {
      if (lower.contains(food.nameEn.toLowerCase()) ||
          lower.contains(food.nameAr) ||
          lower.contains(food.nameEn.toLowerCase().split(' ').first)) {
        return food;
      }
    }

    // Common food aliases
    final aliases = {
      'juice': 'Fresh Juice (Mixed)',
      'عصير': 'Fresh Juice (Mixed)',
      'bread': 'Baladi Bread',
      'خبز': 'Baladi Bread',
      'rice': 'White Rice',
      'أرز': 'White Rice',
      'chicken': 'Grilled Chicken',
      'دجاج': 'Grilled Chicken',
      'meat': 'Red Meat (Beef/Lamb)',
      'لحم': 'Red Meat (Beef/Lamb)',
      'fish': 'Grilled Fish',
      'سمك': 'Grilled Fish',
      'egg': 'Eggs ( boiled)',
      'بيض': 'Eggs ( boiled)',
      'milk': 'Whole Milk',
      'حليب': 'Whole Milk',
      'cheese': 'White Cheese',
      'جبنة': 'White Cheese',
      'salad': 'Mixed Salad',
      'سلطة': 'Mixed Salad',
      'soup': 'Lentil Soup',
      'شوربة': 'Lentil Soup',
      'hummus': 'Hummus (Chickpea Dip)',
      'حمص': 'Hummus (Chickpea Dip)',
      'yogurt': 'Full-Fat Yogurt',
      'لبن': 'Full-Fat Yogurt',
      'banana': 'Banana',
      'موز': 'Banana',
      'apple': 'Apple',
      'تفاح': 'Apple',
      'orange': 'Orange',
      'برتقال': 'Orange',
      'mango': 'Mango',
      'مانجو': 'Mango',
      'grapes': 'Grapes',
      'عنب': 'Grapes',
      'dates': 'Dates (Raw)',
      'تمر': 'Dates (Raw)',
      'foul': 'Foul Medames',
      'فول': 'Foul Medames',
      'falafel': 'Ta\'ameya (Falafel)',
      'طعمية': 'Ta\'ameya (Falafel)',
      'koshari': 'Koshari',
      'كوشري': 'Koshari',
      'pasta': 'White Pasta',
      'مكرونة': 'White Pasta',
      'noodles': 'White Pasta',
      'pizza': 'Pizza',
      'فستو': 'Pizza',
      'burger': 'Beef Burger',
      'برجر': 'Beef Burger',
      'fries': 'French Fries',
      '𝙑ries': 'French Fries',
      '薯条': 'French Fries',
      'cake': 'Sponge Cake',
      'كعك': 'Sponge Cake',
      'chocolate': 'Milk Chocolate',
      'شوكولاتة': 'Milk Chocolate',
      'ice cream': 'Vanilla Ice Cream',
      'آيس كريم': 'Vanilla Ice Cream',
      'tea': 'Tea (Unsweetened)',
      'شاي': 'Tea (Unsweetened)',
      'coffee': 'Arabic Coffee',
      'قهوة': 'Arabic Coffee',
      'water': 'Water',
      'مي': 'Water',
    };

    for (final entry in aliases.entries) {
      if (lower.contains(entry.key)) {
        for (final food in defaultFoods) {
          if (food.nameEn == entry.value || food.nameAr == entry.value) {
            return food;
          }
        }
      }
    }

    return null;
  }

  static int _estimateGI(FoodItem food) {
    // GI estimates based on food category and type
    final name = food.nameEn.toLowerCase();
    final cat = food.category.toLowerCase();

    // Very high GI (70+)
    if (name.contains('white rice') || name.contains('white bread') ||
        name.contains('white pasta') || name.contains('baguette') ||
        name.contains('cornflakes') || name.contains('watermelon')) {
      return 75;
    }

    // High GI (65-70)
    if (name.contains('potato') || name.contains('french fries') ||
        name.contains('bread') || name.contains('pizza') ||
        name.contains('juice') || name.contains('melon')) {
      return 68;
    }

    // Medium-high GI (55-65)
    if (name.contains('banana') || name.contains('pineapple') ||
        name.contains('mango') || name.contains('grapes') ||
        cat.contains('fruit') || name.contains('couscous')) {
      return 58;
    }

    // Medium GI (45-55)
    if (name.contains('oat') || name.contains('brown rice') ||
        name.contains('sweet potato') || name.contains('yogurt') ||
        name.contains('ice cream') || name.contains('honey')) {
      return 50;
    }

    // Low-medium GI (35-45)
    if (name.contains('apple') || name.contains('orange') ||
        name.contains('pear') || name.contains('milk') ||
        name.contains('cheese') || name.contains('basmati')) {
      return 40;
    }

    // Low GI (20-35)
    if (name.contains('cherry') || name.contains('grapefruit') ||
        name.contains('lentil') || name.contains('chickpea') ||
        name.contains('hummus') || name.contains('bean') ||
        name.contains('lentil')) {
      return 30;
    }

    // Very low GI (<20)
    if (name.contains('vegetable') || name.contains('salad') ||
        name.contains('cucumber') || name.contains('tomato') ||
        name.contains('leafy') || name.contains('meat') ||
        name.contains('fish') || name.contains('chicken') ||
        name.contains('egg') || cat.contains('protein')) {
      return 15;
    }

    return 50; // default medium
  }

  static String? _findLowerGIAlternative(FoodItem food) {
    final name = food.nameEn.toLowerCase();

    // Smart suggestions based on what they wanted
    if (name.contains('rice')) {
      return 'Try freekeh or bulgur instead — much lower GI. '
          'Check the Kitchen tab for smart rice dishes.';
    }
    if (name.contains('bread') || name.contains('baguette')) {
      return 'Try baladi bread or whole wheat — lower GI. '
          'Or skip the bread and have a salad-first meal.';
    }
    if (name.contains('juice')) {
      return 'Whole fruit is better than juice (fiber slows absorption). '
          'If you want juice, have a small glass with a meal.';
    }
    if (name.contains('pasta')) {
      return 'Try al dente pasta (lower GI than overcooked) '
          'or switch to burghul. Check the Kitchen for smart swaps.';
    }
    if (name.contains('potato') || name.contains('fries')) {
      return 'Sweet potato has a lower GI. '
          'Or try the cauliflower-rice swap in the Kitchen.';
    }
    if (name.contains('cake') || name.contains('chocolate') ||
        name.contains('ice cream')) {
      return 'Try a small portion of dates with nuts — '
          'natural sugar with fiber and protein to slow absorption.';
    }

    // Generic advice
    final gi = _estimateGI(food);
    if (gi > 70) {
      return 'This is a high-GI food. Consider: '
          'protein first, smaller portion, or check the Kitchen for a smarter version.';
    }

    return 'A smaller portion with protein and vegetables '
        'can help manage the spike.';
  }

  static void _addToHistory(AdvisorContext ctx) {
    _conversationHistory.insert(0, ctx);
    if (_conversationHistory.length > _maxHistory) {
      _conversationHistory.removeLast();
    }
  }
}
