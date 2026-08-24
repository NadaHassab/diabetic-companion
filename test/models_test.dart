import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/glucose_entry.dart';
import 'package:diabetic_companion/models/targets.dart';
import 'package:diabetic_companion/models/user_profile.dart';

void main() {
  group('GlucoseEntry JSON round trip', () {
    test('preserves all fields', () {
      final e = GlucoseEntry(
        id: 'abc',
        recordedAt: DateTime.parse('2026-08-24T14:30:00.000'),
        mgdl: 145,
        tags: {ContextTag.afterMeal, ContextTag.stress},
        note: 'pizza night',
        confirmedUnusual: true,
      );
      final back = GlucoseEntry.fromJson(e.toJson());
      expect(back.id, e.id);
      expect(back.recordedAt, e.recordedAt);
      expect(back.mgdl, e.mgdl);
      expect(back.tags, {ContextTag.afterMeal, ContextTag.stress});
      expect(back.note, 'pizza night');
      expect(back.confirmedUnusual, isTrue);
    });

    test('tolerates missing optional fields', () {
      final back = GlucoseEntry.fromJson({
        'id': 'x',
        'recordedAt': '2026-08-24T10:00:00.000',
        'mgdl': 90,
      });
      expect(back.tags, isEmpty);
      expect(back.note, '');
      expect(back.confirmedUnusual, isFalse);
    });
  });

  group('UserProfile JSON round trip', () {
    test('preserves fields', () {
      const p = UserProfile(
        diabetesType: DiabetesType.type1,
        usesInsulin: true,
        hasGlucagonKit: true,
        ageYears: 72,
        olderAdultComplexHealth: true,
        pregnant: false,
        onboarded: true,
        acceptedDisclaimer: true,
        passedSafetyQuiz: true,
      );
      final back = UserProfile.fromJson(p.toJson());
      expect(back.diabetesType, DiabetesType.type1);
      expect(back.usesInsulin, isTrue);
      expect(back.hasGlucagonKit, isTrue);
      expect(back.ageYears, 72);
      expect(back.olderAdultComplexHealth, isTrue);
      expect(back.onboarded, isTrue);
    });

    test('falls back to defaults on unknown enum value', () {
      final p = UserProfile.fromJson({'diabetesType': 'nope'});
      expect(p.diabetesType, DiabetesType.type2);
    });
  });

  group('GlycemicTargets strata', () {
    test('gestational type applies pregnancy targets', () {
      final t = GlycemicTargets.forProfile(const UserProfile(
        diabetesType: DiabetesType.gestational,
      ));
      expect(t.stratumLabel, contains('Pregnancy'));
      expect(t.rangeLow, 63);
    });

    test('pregnant flag applies pregnancy targets', () {
      final t = GlycemicTargets.forProfile(const UserProfile(pregnant: true));
      expect(t.rangeHigh, 140);
    });

    test('older adult complex health gets relaxed goals', () {
      final t = GlycemicTargets.forProfile(const UserProfile(
        olderAdultComplexHealth: true,
      ));
      expect(t.tirGoalFraction, 0.50);
      expect(t.tbrGoalFraction, 0.01);
      expect(t.tarGoalFraction, 0.50);
    });

    test('default profile gets standard adult goals', () {
      final t = GlycemicTargets.forProfile(const UserProfile());
      expect(t.stratumLabel, contains('adults'));
      expect(t.rangeLow, 70);
      expect(t.rangeHigh, 180);
      expect(t.tirGoalFraction, closeTo(0.7, 1e-9));
    });
  });
}
