import 'package:flutter/material.dart';

import '../models/targets.dart';
import '../theme.dart';

enum ReadingSeverity { severeHypo, hypo, inRange, high, seekCare, urgentHigh }

extension ReadingSeverityX on ReadingSeverity {
  bool get isLow => this == ReadingSeverity.severeHypo || this == ReadingSeverity.hypo;
  bool get isHigh =>
      this == ReadingSeverity.high ||
      this == ReadingSeverity.seekCare ||
      this == ReadingSeverity.urgentHigh;
  bool get needsProtocolCard => isLow || isHigh;

  Color get color => switch (this) {
        ReadingSeverity.inRange => kInRangeColor,
        ReadingSeverity.high => kAboveColor,
        _ => kUrgentColor,
      };

  String get title => switch (this) {
        ReadingSeverity.severeHypo => 'Very low \u00b7 act now',
        ReadingSeverity.hypo => 'Low blood sugar',
        ReadingSeverity.inRange => 'In range',
        ReadingSeverity.high => 'Above range',
        ReadingSeverity.seekCare => 'High with warning signs',
        ReadingSeverity.urgentHigh => 'Urgently high',
      };

  String get subtitle => switch (this) {
        ReadingSeverity.severeHypo => 'Below 54 mg/dL \u2014 level 2/3 hypoglycemia',
        ReadingSeverity.hypo => 'Below 70 mg/dL \u2014 level 1 hypoglycemia',
        ReadingSeverity.inRange => 'Within your personal target range',
        ReadingSeverity.high => 'Above your personal range',
        ReadingSeverity.seekCare => '\u2265250 mg/dL with ketone symptoms \u2014 possible DKA',
        ReadingSeverity.urgentHigh => '\u2265300 mg/dL \u2014 recheck and hydrate',
      };
}

class SafetyService {
  static ReadingSeverity classify(
    double mgdl,
    GlycemicTargets t, {
    bool ketoneSymptoms = false,
  }) {
    if (mgdl < GlycemicTargets.hypoLevel2) return ReadingSeverity.severeHypo;
    if (mgdl < GlycemicTargets.hypoLevel1) return ReadingSeverity.hypo;
    if (mgdl >= GlycemicTargets.urgentHyper) return ReadingSeverity.urgentHigh;
    if (mgdl >= GlycemicTargets.ketoneAlert && ketoneSymptoms) {
      return ReadingSeverity.seekCare;
    }
    if (mgdl > t.rangeHigh || mgdl < t.rangeLow) return ReadingSeverity.high;
    return ReadingSeverity.inRange;
  }

  static bool isUnusualValue(double v) => v <= 0 || v > 600;
}
