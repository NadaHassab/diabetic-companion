class SmartDishVersion {
  final String id;
  final String dishId;
  final String label;
  final List<String> appliedSwapIds;
  final Map<String, String> methodAnswers;
  final DateTime createdAt;

  const SmartDishVersion({
    required this.id,
    required this.dishId,
    required this.label,
    required this.appliedSwapIds,
    required this.methodAnswers,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dishId': dishId,
        'label': label,
        'appliedSwapIds': appliedSwapIds,
        'methodAnswers': methodAnswers,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SmartDishVersion.fromJson(Map<String, dynamic> j) =>
      SmartDishVersion(
        id: j['id'] as String,
        dishId: j['dishId'] as String,
        label: j['label'] as String,
        appliedSwapIds:
            (j['appliedSwapIds'] as List).cast<String>().toList(),
        methodAnswers:
            (j['methodAnswers'] as Map).cast<String, String>(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

/// One post-meal reading tied to a smart version, with confounder context.
class DishSample {
  final String id;
  final String versionId;
  final double preMealMgdl;
  final double postMealMgdl;
  final String portionLabel; // S / M / L
  final Set<String> confounders; // exercise, stress, illness, poorSleep
  final DateTime loggedAt;

  const DishSample({
    required this.id,
    required this.versionId,
    required this.preMealMgdl,
    required this.postMealMgdl,
    required this.portionLabel,
    required this.confounders,
    required this.loggedAt,
  });

  double get rise => postMealMgdl - preMealMgdl;

  bool get hasConfounders => confounders.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionId': versionId,
        'preMealMgdl': preMealMgdl,
        'postMealMgdl': postMealMgdl,
        'portionLabel': portionLabel,
        'confounders': confounders.toList(),
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory DishSample.fromJson(Map<String, dynamic> j) => DishSample(
        id: j['id'] as String,
        versionId: j['versionId'] as String,
        preMealMgdl: (j['preMealMgdl'] as num).toDouble(),
        postMealMgdl: (j['postMealMgdl'] as num).toDouble(),
        portionLabel: j['portionLabel'] as String,
        confounders: ((j['confounders'] as List?) ?? const []).cast<String>().toSet(),
        loggedAt: DateTime.parse(j['loggedAt'] as String),
      );
}
