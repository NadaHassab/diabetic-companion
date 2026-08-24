import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/targets.dart';
import 'package:diabetic_companion/models/user_profile.dart';
import 'package:diabetic_companion/services/safety_service.dart';

void main() {
  final standard = GlycemicTargets.forProfile(const UserProfile());

  group('SafetyService.classify boundaries', () {
    test('hypo tiers', () {
      expect(SafetyService.classify(53, standard),
          ReadingSeverity.severeHypo);
      expect(SafetyService.classify(54, standard), ReadingSeverity.hypo);
      expect(SafetyService.classify(69.9, standard), ReadingSeverity.hypo);
      expect(SafetyService.classify(70, standard), ReadingSeverity.inRange);
    });

    test('hyper tiers', () {
      expect(SafetyService.classify(180, standard),
          ReadingSeverity.inRange);
      expect(SafetyService.classify(249, standard), ReadingSeverity.high);
      expect(
        SafetyService.classify(250, standard),
        ReadingSeverity.high,
        reason: '250 without ketone symptoms is above range, not an alert',
      );
      expect(
        SafetyService.classify(250, standard, ketoneSymptoms: true),
        ReadingSeverity.seekCare,
      );
      expect(SafetyService.classify(300, standard),
          ReadingSeverity.urgentHigh,
          reason: 'urgent hyper regardless of symptoms');
    });

    test('pregnancy range shifts in-range band', () {
      final gestational = GlycemicTargets.forProfile(
          const UserProfile(diabetesType: DiabetesType.gestational));
      expect(SafetyService.classify(150, gestational),
          ReadingSeverity.high);
      expect(SafetyService.classify(130, gestational),
          ReadingSeverity.inRange);
    });
  });

  group('unusual value guard', () {
    test('flags impossible inputs', () {
      expect(SafetyService.isUnusualValue(0), isTrue);
      expect(SafetyService.isUnusualValue(-5), isTrue);
      expect(SafetyService.isUnusualValue(601), isTrue);
      expect(SafetyService.isUnusualValue(600), isFalse);
      expect(SafetyService.isUnusualValue(120), isFalse);
    });
  });

  group('severity helpers', () {
    test('protocol card requirement', () {
      for (final s in ReadingSeverity.values) {
        expect(s.needsProtocolCard, s != ReadingSeverity.inRange);
      }
    });

    test('colors are distinct for low/high/in-range families', () {
      final colors = {
        ReadingSeverity.hypo.color,
        ReadingSeverity.high.color,
        ReadingSeverity.inRange.color,
      };
      expect(colors.length, 3);
    });
  });
}
