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
    this.glucagonExpiresAt,
    this.ageYears = 40,
    this.olderAdultComplexHealth = false,
    this.pregnant = false,
    this.onboarded = false,
    this.acceptedDisclaimer = false,
    this.passedSafetyQuiz = false,
    this.lastWeeklyReviewAt,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hasMedicalId = false,
    this.focusMode = false,
    this.darkMode = false,
    this.languageCode = 'en',
  });

  final DiabetesType diabetesType;
  final bool usesInsulin;
  final bool hasGlucagonKit;
  final String? glucagonExpiresAt;
  final int ageYears;
  final bool olderAdultComplexHealth;
  final bool pregnant;
  final bool onboarded;
  final bool acceptedDisclaimer;
  final bool passedSafetyQuiz;
  final String? lastWeeklyReviewAt;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool hasMedicalId;
  final bool focusMode;
  final bool darkMode;
  final String languageCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'diabetesType': diabetesType.name,
        'usesInsulin': usesInsulin,
        'hasGlucagonKit': hasGlucagonKit,
        'glucagonExpiresAt': glucagonExpiresAt,
        'ageYears': ageYears,
        'olderAdultComplexHealth': olderAdultComplexHealth,
        'pregnant': pregnant,
        'onboarded': onboarded,
        'acceptedDisclaimer': acceptedDisclaimer,
        'passedSafetyQuiz': passedSafetyQuiz,
        'lastWeeklyReviewAt': lastWeeklyReviewAt,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'hasMedicalId': hasMedicalId,
        'focusMode': focusMode,
        'darkMode': darkMode,
        'languageCode': languageCode,
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
      glucagonExpiresAt: json['glucagonExpiresAt'] as String?,
      ageYears: (json['ageYears'] as num?)?.toInt() ?? 40,
      olderAdultComplexHealth: (json['olderAdultComplexHealth'] as bool?) ?? false,
      pregnant: (json['pregnant'] as bool?) ?? false,
      onboarded: (json['onboarded'] as bool?) ?? false,
      acceptedDisclaimer: (json['acceptedDisclaimer'] as bool?) ?? false,
      passedSafetyQuiz: (json['passedSafetyQuiz'] as bool?) ?? false,
      lastWeeklyReviewAt: json['lastWeeklyReviewAt'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      hasMedicalId: (json['hasMedicalId'] as bool?) ?? false,
      focusMode: (json['focusMode'] as bool?) ?? false,
      darkMode: (json['darkMode'] as bool?) ?? false,
      languageCode: (json['languageCode'] as String?) ?? 'en',
    );
  }

  UserProfile copyWith({
    DiabetesType? diabetesType,
    bool? usesInsulin,
    bool? hasGlucagonKit,
    String? glucagonExpiresAt,
    int? ageYears,
    bool? olderAdultComplexHealth,
    bool? pregnant,
    bool? onboarded,
    bool? acceptedDisclaimer,
    bool? passedSafetyQuiz,
    String? lastWeeklyReviewAt,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? hasMedicalId,
    bool? focusMode,
    bool? darkMode,
    String? languageCode,
  }) =>
      UserProfile(
        diabetesType: diabetesType ?? this.diabetesType,
        usesInsulin: usesInsulin ?? this.usesInsulin,
        hasGlucagonKit: hasGlucagonKit ?? this.hasGlucagonKit,
        glucagonExpiresAt: glucagonExpiresAt ?? this.glucagonExpiresAt,
        ageYears: ageYears ?? this.ageYears,
        olderAdultComplexHealth:
            olderAdultComplexHealth ?? this.olderAdultComplexHealth,
        pregnant: pregnant ?? this.pregnant,
        onboarded: onboarded ?? this.onboarded,
        acceptedDisclaimer: acceptedDisclaimer ?? this.acceptedDisclaimer,
        passedSafetyQuiz: passedSafetyQuiz ?? this.passedSafetyQuiz,
        lastWeeklyReviewAt: lastWeeklyReviewAt ?? this.lastWeeklyReviewAt,
        emergencyContactName: emergencyContactName ?? this.emergencyContactName,
        emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
        hasMedicalId: hasMedicalId ?? this.hasMedicalId,
        focusMode: focusMode ?? this.focusMode,
        darkMode: darkMode ?? this.darkMode,
        languageCode: languageCode ?? this.languageCode,
      );
}

extension FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
