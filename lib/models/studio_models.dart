enum IngredientRole { starchCore, protein, fatCrunch, sauce, vegShell }

enum DishCategory {
  breakfast,
  lunch,
  dinner,
  mezze,
  soup,
  dessert,
  drink;

  String get labelAr => switch (this) {
        DishCategory.breakfast => 'فطور',
        DishCategory.lunch => 'غداء',
        DishCategory.dinner => 'عشاء',
        DishCategory.mezze => 'مقبلات',
        DishCategory.soup => 'شوربة',
        DishCategory.dessert => 'حلويات',
        DishCategory.drink => 'مشروبات',
      };

  String get labelEn => switch (this) {
        DishCategory.breakfast => 'Breakfast',
        DishCategory.lunch => 'Lunch',
        DishCategory.dinner => 'Dinner',
        DishCategory.mezze => 'Mezze / Appetizers',
        DishCategory.soup => 'Soups',
        DishCategory.dessert => 'Desserts',
        DishCategory.drink => 'Drinks',
      };
}

enum EvidenceTier { measuredA, calculatedB, blogC }

class MethodQuestion {
  final String id;
  final String questionAr;
  final String questionEn;
  final List<MethodOption> options;

  const MethodQuestion({
    required this.id,
    required this.questionAr,
    required this.questionEn,
    required this.options,
  });
}

class MethodOption {
  final String id;
  final String labelAr;
  final String labelEn;
  final String? swapId;

  const MethodOption({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    this.swapId,
  });
}

class Swap {
  final String id;
  final IngredientRole role;
  final String fromAr;
  final String fromEn;
  final String toAr;
  final String toEn;
  final String effect;
  final String source;
  final EvidenceTier tier;

  const Swap({
    required this.id,
    required this.role,
    required this.fromAr,
    required this.fromEn,
    required this.toAr,
    required this.toEn,
    required this.effect,
    required this.source,
    required this.tier,
  });

  String get tierLabel => switch (tier) {
        EvidenceTier.measuredA => 'measured',
        EvidenceTier.calculatedB => 'calculated estimate',
        EvidenceTier.blogC => 'informal estimate',
      };
}

class StudioDish {
  final String id;
  final String nameAr;
  final String nameEn;
  final String region;
  final DishCategory category;
  final int giEstimate;
  final String giSource;
  final EvidenceTier evidenceTier;
  final Map<IngredientRole, String> roles;
  final List<String> defaultSwapIds;

  const StudioDish({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.region,
    required this.category,
    required this.giEstimate,
    required this.giSource,
    this.evidenceTier = EvidenceTier.calculatedB,
    required this.roles,
    this.defaultSwapIds = const [],
  });
}
