import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/targets.dart';
import 'package:diabetic_companion/models/user_profile.dart';
import 'package:diabetic_companion/services/metrics_service.dart';

GlucoseEntry mk(double v, int minutesAgo) => GlucoseEntry(
      id: 'e$minutesAgo',
      recordedAt: DateTime(2026, 8, 24, 12).subtract(Duration(minutes: minutesAgo)),
      mgdl: v,
    );

void main() {
  final standard = GlycemicTargets.forProfile(const UserProfile());

  group('GlucoseStats.compute', () {
    test('empty list yields zeroed stats', () {
      final s = GlucoseStats.compute([], standard);
      expect(s.count, 0);
      expect(s.gmiPercent, isNull);
      expect(s.cvPercent, isNull);
      expect(s.inRangeFraction, 0);
    });

    test('fractions match composition for standard adult', () {
      final entries = [
        mk(100, 10), // in range
        mk(150, 20), // in range
        mk(180, 30), // in range (boundary inclusive)
        mk(65, 40), // below (<70)
        mk(50, 50), // below + severe low
        mk(220, 60), // above (>180)
        mk(260, 70), // above + urgent high
      ];
      final s = GlucoseStats.compute(entries, standard);
      expect(s.count, 7);
      expect(s.inRangeFraction, closeTo(3 / 7, 1e-9));
      expect(s.belowFraction, closeTo(2 / 7, 1e-9));
      expect(s.severeLowFraction, closeTo(1 / 7, 1e-9));
      expect(s.aboveFraction, closeTo(2 / 7, 1e-9));
      expect(s.urgentHighFraction, closeTo(1 / 7, 1e-9));
    });

    test('GMI uses the ADA formula on mean glucose', () {
      final entries = [mk(100, 5), mk(200, 15)];
      final s = GlucoseStats.compute(entries, standard);
      final mean = 150.0;
      expect(s.meanMgdl, mean);
      expect(s.gmiPercent, closeTo(3.31 + 0.02392 * mean, 1e-9));
    });

    test('CV is sample-based and zero when values are identical', () {
      final flat = GlucoseStats.compute([mk(120, 5), mk(120, 15)], standard);
      expect(flat.cvPercent, 0);

      final spread = GlucoseStats.compute(
          [mk(100, 5), mk(200, 15)], standard);
      const expectedCv = 70.71067811865476 / 150 * 100;
      expect(spread.cvPercent!, closeTo(expectedCv, 1e-6));
    });

    test('pregnancy stratum shifts range boundaries to 63-140', () {
      final pregnancy = GlycemicTargets.forProfile(const UserProfile(
        diabetesType: DiabetesType.gestational,
      ));
      expect(pregnancy.rangeLow, 63);
      expect(pregnancy.rangeHigh, 140);

      final s = GlucoseStats.compute([mk(130, 5)], pregnancy);
      expect(s.inRangeFraction, 1);
      expect(s.aboveFraction, 0);

      final s2 = GlucoseStats.compute([mk(150, 5)], pregnancy);
      expect(s2.aboveFraction, 1);
      expect(s2.inRangeFraction, 0);
    });
  });
}
