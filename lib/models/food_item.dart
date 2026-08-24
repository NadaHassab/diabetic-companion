class FoodItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String category;
  final List<PortionPreset> portions;
  final List<CarbSource> sources;

  const FoodItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.portions,
    required this.sources,
  });

  FoodItem copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? category,
    List<PortionPreset>? portions,
    List<CarbSource>? sources,
  }) =>
      FoodItem(
        id: id ?? this.id,
        nameAr: nameAr ?? this.nameAr,
        nameEn: nameEn ?? this.nameEn,
        category: category ?? this.category,
        portions: portions ?? this.portions,
        sources: sources ?? this.sources,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'category': category,
        'portions': portions.map((p) => p.toJson()).toList(),
        'sources': sources.map((s) => s.toJson()).toList(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        id: j['id'] as String,
        nameAr: j['nameAr'] as String,
        nameEn: j['nameEn'] as String,
        category: j['category'] as String,
        portions: (j['portions'] as List)
            .map((p) => PortionPreset.fromJson(p as Map<String, dynamic>))
            .toList(),
        sources: (j['sources'] as List)
            .map((s) => CarbSource.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class PortionPreset {
  final String label;
  final double grams;
  final double carbGrams;

  const PortionPreset({
    required this.label,
    required this.grams,
    required this.carbGrams,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'grams': grams,
        'carbGrams': carbGrams,
      };

  factory PortionPreset.fromJson(Map<String, dynamic> j) => PortionPreset(
        label: j['label'] as String,
        grams: (j['grams'] as num).toDouble(),
        carbGrams: (j['carbGrams'] as num).toDouble(),
      );
}

class CarbSource {
  final String name;
  final String url;

  const CarbSource({required this.name, required this.url});

  Map<String, dynamic> toJson() => {'name': name, 'url': url};

  factory CarbSource.fromJson(Map<String, dynamic> j) =>
      CarbSource(name: j['name'] as String, url: j['url'] as String);
}

class FavoriteFood {
  final String foodId;
  final DateTime addedAt;
  final int timesLogged;

  const FavoriteFood({
    required this.foodId,
    required this.addedAt,
    required this.timesLogged,
  });

  FavoriteFood increment() => FavoriteFood(
        foodId: foodId,
        addedAt: addedAt,
        timesLogged: timesLogged + 1,
      );

  Map<String, dynamic> toJson() => {
        'foodId': foodId,
        'addedAt': addedAt.toIso8601String(),
        'timesLogged': timesLogged,
      };

  factory FavoriteFood.fromJson(Map<String, dynamic> j) => FavoriteFood(
        foodId: j['foodId'] as String,
        addedAt: DateTime.parse(j['addedAt'] as String),
        timesLogged: j['timesLogged'] as int,
      );
}
