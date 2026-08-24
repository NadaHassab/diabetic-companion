enum DiabetesType { type1, type2, prediabetes, gestational }

extension DiabetesTypeX on DiabetesType {
  String get label => switch (this) {
        DiabetesType.type1 => 'Type 1',
        DiabetesType.type2 => 'Type 2',
        DiabetesType.prediabetes => 'Prediabetes',
        DiabetesType.gestational => 'Gestational',
      };

  String get detail => switch (this) {
        DiabetesType.type1 => 'Insulin-dependent \u00b7 safety protocols included',
        DiabetesType.type2 => 'Manage with food, activity or medication',
        DiabetesType.prediabetes => 'Focus on post-meal patterns and habits',
        DiabetesType.gestational => 'Tight pregnancy ranges and reassurance',
      };
}

class UserProfile {
  const UserProfile({
    this.diabetesType = DiabetesType.type2,
    this.usesInsulin = false,
    this.hasGlucagonKit = false,
    this.ageYears = 40,
    this.olderAdultComplexHealth = false,
    this.pregnant = false,
    this.onboarded = false,
    this.acceptedDisclaimer = false,
    this.passedSafetyQuiz = false,
    this.lastWeeklyReviewAt,
  });

  final DiabetesType diabetesType;
  final bool usesInsulin;
  final bool hasGlucagonKit;
  final int ageYears;
  final bool olderAdultComplexHealth;
  final bool pregnant;
  final bool onboarded;
  final bool acceptedDisclaimer;
  final bool passedSafetyQuiz;
  final String? lastWeeklyReviewAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'diabetesType': diabetesType.name,
        'usesInsulin': usesInsulin,
        'hasGlucagonKit': hasGlucagonKit,
        'ageYears': ageYears,
        'olderAdultComplexHealth': olderAdultComplexHealth,
        'pregnant': pregnant,
        'onboarded': onboarded,
        'acceptedDisclaimer': acceptedDisclaimer,
        'passedSafetyQuiz': passedSafetyQuiz,
        'lastWeeklyReviewAt': lastWeeklyReviewAt,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final typeName = json['diabetesType'] as String?;
    final type = DiabetesType.values
        .where((t) => t.name == typeName)
        .firstOrNull;
    return UserProfile(
      diabetesType: type ?? DiabetesType.type2,
      usesInsulin: (json['usesInsulin'] as bool?) ?? false,
      hasGlucagonKit: (json['hasGlucagonKit'] as bool?) ?? false,
      ageYears: (json['ageYears'] as num?)?.toInt() ?? 40,
      olderAdultComplexHealth: (json['olderAdultComplexHealth'] as bool?) ?? false,
      pregnant: (json['pregnant'] as bool?) ?? false,
      onboarded: (json['onboarded'] as bool?) ?? false,
      acceptedDisclaimer: (json['acceptedDisclaimer'] as bool?) ?? false,
      passedSafetyQuiz: (json['passedSafetyQuiz'] as bool?) ?? false,
      lastWeeklyReviewAt: json['lastWeeklyReviewAt'] as String?,
    );
  }

  UserProfile copyWith({
    DiabetesType? diabetesType,
    bool? usesInsulin,
    bool? hasGlucagonKit,
    int? ageYears,
    bool? olderAdultComplexHealth,
    bool? pregnant,
    bool? onboarded,
    bool? acceptedDisclaimer,
    bool? passedSafetyQuiz,
    String? lastWeeklyReviewAt,
  }) =>
      UserProfile(
        diabetesType: diabetesType ?? this.diabetesType,
        usesInsulin: usesInsulin ?? this.usesInsulin,
        hasGlucagonKit: hasGlucagonKit ?? this.hasGlucagonKit,
        ageYears: ageYears ?? this.ageYears,
        olderAdultComplexHealth:
            olderAdultComplexHealth ?? this.olderAdultComplexHealth,
        pregnant: pregnant ?? this.pregnant,
        onboarded: onboarded ?? this.onboarded,
        acceptedDisclaimer: acceptedDisclaimer ?? this.acceptedDisclaimer,
        passedSafetyQuiz: passedSafetyQuiz ?? this.passedSafetyQuiz,
        lastWeeklyReviewAt: lastWeeklyReviewAt ?? this.lastWeeklyReviewAt,
      );
}

extension FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
