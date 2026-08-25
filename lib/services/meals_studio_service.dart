import 'package:diabetic_companion/models/smart_dish.dart';
import 'package:diabetic_companion/models/studio_models.dart';
import 'package:diabetic_companion/services/studio_catalog.dart';

enum DishConfidence { stillLearning, emerging, established }

class DishResponse {
  final int matchedSamples;
  final DishConfidence confidence;
  final double? medianRise;
  final double? iqrLow;
  final double? iqrHigh;
  final List<double> sampleRises;

  const DishResponse({
    required this.matchedSamples,
    required this.confidence,
    this.medianRise,
    this.iqrLow,
    this.iqrHigh,
    this.sampleRises = const [],
  });

  String get confidenceLabel => switch (confidence) {
        DishConfidence.stillLearning => 'still learning',
        DishConfidence.emerging => 'emerging',
        DishConfidence.established => 'established',
      };

  String phrase() {
    if (medianRise == null) {
      return 'No matched samples yet — log a couple of post-meal readings.';
    }
    final m = medianRise!;
    if (m < 40) return 'for you so far: usually a mild rise';
    if (m < 80) return 'for you so far: usually a moderate rise';
    return 'for you so far: usually a high rise';
  }
}

class StudioFixCard {
  final Swap swap;
  final bool applied;

  const StudioFixCard({required this.swap, required this.applied});
}

class MealsStudioService {
  /// Fix cards for a dish = dish defaults + swaps referenced by chosen method answers.
  static List<StudioFixCard> fixCards({
    required StudioDish dish,
    Map<String, String> methodAnswers = const {},
    Set<String> appliedSwaps = const {},
  }) {
    final suggested = <String>{...dish.defaultSwapIds};
    for (final q in studioMethodQuestions) {
      final answerId = methodAnswers[q.id];
      if (answerId == null) continue;
      final option = q.options.firstWhere(
        (o) => o.id == answerId,
        orElse: () => q.options.first,
      );
      if (option.swapId != null) suggested.add(option.swapId!);
    }
    final cards = <StudioFixCard>[];
    for (final id in suggested) {
      final idx = studioSwaps.indexWhere((s) => s.id == id);
      if (idx == -1) continue;
      cards.add(StudioFixCard(
          swap: studioSwaps[idx], applied: appliedSwaps.contains(id)));
    }
    return cards;
  }

  /// Matched-context samples: same portion, no confounders.
  static List<DishSample> matchedSamples({
    required List<DishSample> samples,
    required String versionId,
  }) =>
      samples
          .where((s) =>
              s.versionId == versionId &&
              !s.hasConfounders &&
              s.portionLabel.isNotEmpty)
          .toList(growable: false);

  static DishResponse responseFor(List<DishSample> matched) {
    if (matched.isEmpty) {
      return const DishResponse(matchedSamples: 0, confidence: DishConfidence.stillLearning);
    }
    final rises = matched.map((s) => s.rise).toList()..sort();
    final n = rises.length;
    final median =
        n.isOdd ? rises[n ~/ 2] : (rises[n ~/ 2 - 1] + rises[n ~/ 2]) / 2;
    final confidence = n >= 7
        ? DishConfidence.established
        : n >= 3
            ? DishConfidence.emerging
            : DishConfidence.stillLearning;

    double? iqrLow;
    double? iqrHigh;
    if (n >= 4) {
      final lower = rises.sublist(0, n ~/ 2);
      final upper = n.isOdd
          ? rises.sublist(n ~/ 2 + 1)
          : rises.sublist(n ~/ 2);
      iqrLow = _medianOf(lower);
      iqrHigh = _medianOf(upper);
    }
    return DishResponse(
      matchedSamples: n,
      confidence: confidence,
      medianRise: median,
      iqrLow: iqrLow,
      iqrHigh: iqrHigh,
      sampleRises: rises,
    );
  }

  static String display(DishResponse r) {
    if (r.medianRise == null) return '${r.confidenceLabel} · no data yet';
    if (r.matchedSamples < 3) {
      return '${r.confidenceLabel} · ${r.sampleRises.map((v) => '+${v.toStringAsFixed(0)}').join(", ")}';
    }
    final spread = (r.iqrLow != null && r.iqrHigh != null)
        ? ' (IQR +${r.iqrLow!.toStringAsFixed(0)} to +${r.iqrHigh!.toStringAsFixed(0)})'
        : '';
    return '${r.confidenceLabel} · median +${r.medianRise!.toStringAsFixed(0)}$spread';
  }

  static String eatingOrderCard(String dishNameEn) =>
      'Start with the salad (سلطة أولاً), then the protein, '
      '$dishNameEn last. Eating order can lower the spike at that meal — '
      'it is a habit to try, not a cure.';

  static double _medianOf(List<double> sorted) {
    final n = sorted.length;
    if (n == 0) return 0;
    return n.isOdd
        ? sorted[n ~/ 2]
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
  }
}
