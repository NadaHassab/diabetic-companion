class MealLog {
  final String id;
  final String glucoseEntryId;
  final List<MealItem> items;
  final double totalCarbs;
  final DateTime loggedAt;

  const MealLog({
    required this.id,
    required this.glucoseEntryId,
    required this.items,
    required this.totalCarbs,
    required this.loggedAt,
  });

  MealLog copyWith({List<MealItem>? items}) => MealLog(
        id: id,
        glucoseEntryId: glucoseEntryId,
        items: items ?? this.items,
        totalCarbs: items != null
            ? items.fold(0, (sum, i) => sum + i.carbGrams)
            : totalCarbs,
        loggedAt: loggedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'glucoseEntryId': glucoseEntryId,
        'items': items.map((i) => i.toJson()).toList(),
        'totalCarbs': totalCarbs,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory MealLog.fromJson(Map<String, dynamic> j) => MealLog(
        id: j['id'] as String,
        glucoseEntryId: j['glucoseEntryId'] as String,
        items: (j['items'] as List)
            .map((i) => MealItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        totalCarbs: (j['totalCarbs'] as num).toDouble(),
        loggedAt: DateTime.parse(j['loggedAt'] as String),
      );
}

class MealItem {
  final String foodId;
  final String foodName;
  final String portionLabel;
  final double carbGrams;

  const MealItem({
    required this.foodId,
    required this.foodName,
    required this.portionLabel,
    required this.carbGrams,
  });

  Map<String, dynamic> toJson() => {
        'foodId': foodId,
        'foodName': foodName,
        'portionLabel': portionLabel,
        'carbGrams': carbGrams,
      };

  factory MealItem.fromJson(Map<String, dynamic> j) => MealItem(
        foodId: j['foodId'] as String,
        foodName: j['foodName'] as String,
        portionLabel: j['portionLabel'] as String,
        carbGrams: (j['carbGrams'] as num).toDouble(),
      );
}
