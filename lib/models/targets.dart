import 'user_profile.dart';

class GlycemicTargets {
  const GlycemicTargets({
    required this.stratumLabel,
    required this.rangeLow,
    required this.rangeHigh,
    required this.tirGoalFraction,
    required this.tbrGoalFraction,
    required this.tarGoalFraction,
    required this.guidanceLines,
    required this.individualizedNote,
  });

  final String stratumLabel;
  final double rangeLow;
  final double rangeHigh;
  final double tirGoalFraction;
  final double tbrGoalFraction;
  final double tarGoalFraction;
  final List<String> guidanceLines;
  final String individualizedNote;

  static const double hypoLevel1 = 70;
  static const double hypoLevel2 = 54;
  static const double ketoneAlert = 250;
  static const double urgentHyper = 300;
  static const double cvGoalPercent = 36;

  static GlycemicTargets forProfile(UserProfile p) {
    if (p.diabetesType == DiabetesType.gestational || p.pregnant) {
      return const GlycemicTargets(
        stratumLabel: 'Pregnancy',
        rangeLow: 63,
        rangeHigh: 140,
        tirGoalFraction: 0.70,
        tbrGoalFraction: 0.04,
        tarGoalFraction: 0.25,
        guidanceLines: [
          'Time in range 63\u2013140 mg/dL \u2265 70%',
          'Below 63 mg/dL < 4%',
          'Post-meal peak < 140 mg/dL',
          'Fasting < 95 mg/dL',
        ],
        individualizedNote:
            'Pregnancy targets are intentionally tight. Review them with your '
            'obstetric and diabetes care team.',
      );
    }
    if (p.olderAdultComplexHealth) {
      return const GlycemicTargets(
        stratumLabel: 'Older adult \u00b7 complex health',
        rangeLow: 70,
        rangeHigh: 180,
        tirGoalFraction: 0.50,
        tbrGoalFraction: 0.01,
        tarGoalFraction: 0.50,
        guidanceLines: [
          'Time in range 70\u2013180 mg/dL > 50%',
          'Below 70 mg/dL < 1% (\u2264 15 min/day)',
          'Above 180 mg/dL < 50%',
          'Goals are deliberately relaxed to reduce hypoglycemia risk',
        ],
        individualizedNote:
            'For older adults with complex health, avoiding lows matters more '
            'than perfect numbers. Individualize with your clinician.',
      );
    }
    return const GlycemicTargets(
      stratumLabel: 'Most nonpregnant adults',
      rangeLow: 70,
      rangeHigh: 180,
      tirGoalFraction: 0.70,
      tbrGoalFraction: 0.04,
      tarGoalFraction: 0.25,
      guidanceLines: [
        'Time in range 70\u2013180 mg/dL > 70% (\u2265 17 h/day)',
        'Below 70 mg/dL < 4% (\u2264 1 h/day) \u00b7 below 54 < 1%',
        'Above 180 mg/dL < 25% \u00b7 above 250 < 5%',
        'Glucose variability (CV) \u2264 36%',
        'Fasting 80\u2013130 mg/dL \u00b7 post-meal peak < 180 mg/dL',
      ],
      individualizedNote:
          'ADA Standards of Care 2026 goals for most adults. Your clinician may '
          'personalize them further.',
    );
  }
}
