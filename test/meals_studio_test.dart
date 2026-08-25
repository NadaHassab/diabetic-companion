import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/smart_dish.dart';
import 'package:diabetic_companion/services/meals_studio_service.dart';
import 'package:diabetic_companion/services/studio_catalog.dart';

DishSample _s(String versionId, double pre, double post,
        {String portion = 'M', Set<String> confounders = const {}}) =>
    DishSample(
      id: 'ds-$pre-$post-$portion',
      versionId: versionId,
      preMealMgdl: pre,
      postMealMgdl: post,
      portionLabel: portion,
      confounders: confounders,
      loggedAt: DateTime(2026, 8, 24),
    );

void main() {
  group('MealsStudioService.fixCards', () {
    test('dish defaults appear as fix cards', () {
      final dish = studioDishes.firstWhere((d) => d.id == 'd-koshari');
      final cards = MealsStudioService.fixCards(dish: dish);
      expect(cards.any((c) => c.swap.id == 'sw-lentils'), isTrue);
    });

    test('method answer referencing a swap adds that card', () {
      final dish = studioDishes.firstWhere((d) => d.id == 'd-koshari');
      final cards = MealsStudioService.fixCards(
          dish: dish, methodAnswers: {'q-fry': 'fried'});
      expect(cards.any((c) => c.swap.id == 'sw-baking'), isTrue);
    });

    test('clean method answer adds no extra swap', () {
      final dish = studioDishes.firstWhere((d) => d.id == 'd-koshari');
      final cards = MealsStudioService.fixCards(
          dish: dish, methodAnswers: {'q-fry': 'baked'});
      expect(cards.any((c) => c.swap.id == 'sw-baking'), isFalse);
    });
  });

  group('MealsStudioService.responseFor', () {
    test('no matched samples → still learning, no numbers', () {
      final r = MealsStudioService.responseFor([]);
      expect(r.confidence, DishConfidence.stillLearning);
      expect(r.medianRise, isNull);
      expect(r.phrase(), contains('No matched samples'));
    });

    test('confounder samples are excluded from matching', () {
      final matched = MealsStudioService.matchedSamples(samples: [
        _s('v1', 100, 140),
        _s('v1', 100, 200, confounders: {'illness'}),
      ], versionId: 'v1');
      expect(matched.length, 1);
    });

    test('other versions excluded', () {
      final matched = MealsStudioService.matchedSamples(samples: [
        _s('v1', 100, 140),
        _s('v2', 100, 220),
      ], versionId: 'v1');
      expect(matched.length, 1);
    });

    test('under 3 samples stays still learning with raw values', () {
      final r = MealsStudioService.responseFor(MealsStudioService.matchedSamples(
          samples: [_s('v1', 100, 140), _s('v1', 100, 160)],
          versionId: 'v1'));
      expect(r.matchedSamples, 2);
      expect(r.confidence, DishConfidence.stillLearning);
      expect(r.medianRise, 50);
      expect(MealsStudioService.display(r), contains('+40'));
    });

    test('3-6 samples are emerging with median', () {
      final samples = [
        _s('v1', 100, 130),
        _s('v1', 100, 150),
        _s('v1', 100, 170),
      ];
      final r =
          MealsStudioService.responseFor(MealsStudioService.matchedSamples(
              samples: samples, versionId: 'v1'));
      expect(r.confidence, DishConfidence.emerging);
      expect(r.medianRise, 50);
    });

    test('7+ samples are established with IQR', () {
      final samples = [
        for (var i = 0; i < 7; i++) _s('v1', 100, 120.0 + i * 10),
      ];
      final r =
          MealsStudioService.responseFor(MealsStudioService.matchedSamples(
              samples: samples, versionId: 'v1'));
      expect(r.confidence, DishConfidence.established);
      expect(r.iqrLow, isNotNull);
      expect(r.iqrHigh, isNotNull);
      expect(r.iqrHigh! > r.iqrLow!, isTrue);
    });

    test('phrase uses pattern-hypothesis language, never lab facts', () {
      final samples = List.generate(3, (i) => _s('v1', 100, 150));
      final r =
          MealsStudioService.responseFor(MealsStudioService.matchedSamples(
              samples: samples, versionId: 'v1'));
      expect(r.phrase(), startsWith('for you so far'));
    });
  });

  group('catalog integrity', () {
    test('every swap referenced by dishes and questions exists', () {
      final ids = studioSwaps.map((s) => s.id).toSet();
      for (final d in studioDishes) {
        for (final id in d.defaultSwapIds) {
          expect(ids.contains(id), isTrue, reason: '${d.id} → $id');
        }
      }
      for (final q in studioMethodQuestions) {
        for (final o in q.options) {
          if (o.swapId != null) {
            expect(ids.contains(o.swapId), isTrue,
                reason: '${q.id}/${o.id} → ${o.swapId}');
          }
        }
      }
    });
  });

  group('SmartDishVersion JSON round trip', () {
    test('preserves fields', () {
      final real = SmartDishVersion(
        id: 'sv-1',
        dishId: 'd-koshari',
        label: 'v1',
        appliedSwapIds: ['sw-lentils'],
        methodAnswers: {'q-fry': 'baked'},
        createdAt: DateTime(2026, 8, 24),
      );
      final back = SmartDishVersion.fromJson(real.toJson());
      expect(back.id, real.id);
      expect(back.dishId, real.dishId);
      expect(back.appliedSwapIds, real.appliedSwapIds);
      expect(back.createdAt, real.createdAt);
    });

    test('DishSample round trip keeps confounders', () {
      final s = _s('v1', 90, 210, confounders: {'stress'});
      final back = DishSample.fromJson(s.toJson());
      expect(back.rise, 120);
      expect(back.hasConfounders, isTrue);
    });
  });
}
