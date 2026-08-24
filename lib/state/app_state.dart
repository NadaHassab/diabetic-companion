import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/context_tag.dart';
import '../models/glucose_entry.dart';
import '../models/medication.dart';
import '../models/targets.dart';
import '../models/user_profile.dart';
import '../services/metrics_service.dart';
import '../services/repositories.dart';
import '../services/storage.dart';

class AppState extends ChangeNotifier {
  AppState(
    this._store,
    this._glucoseRepo,
    this._profileRepo,
    this._medicationRepo,
    this._intakeRepo,
  );

  factory AppState.create(JsonStore store) => AppState(
        store,
        GlucoseRepository(store),
        ProfileRepository(store),
        MedicationRepository(store),
        IntakeRepository(store),
      );

  final JsonStore _store;
  final GlucoseRepository _glucoseRepo;
  final ProfileRepository _profileRepo;
  final MedicationRepository _medicationRepo;
  final IntakeRepository _intakeRepo;

  bool loaded = false;
  UserProfile profile = const UserProfile();
  List<GlucoseEntry> entries = <GlucoseEntry>[];
  List<Medication> medications = <Medication>[];
  List<MedIntake> intakes = <MedIntake>[];

  GlycemicTargets get targets => GlycemicTargets.forProfile(profile);

  GlucoseStats get overallStats => GlucoseStats.compute(entries, targets);

  int get currentStreak {
    if (entries.isEmpty) return 0;
    final now = DateTime.now();
    var streak = 0;
    var day = DateTime(now.year, now.month, now.day);
    for (var d = 0; d < 365; d++) {
      final next = day;
      final hasEntry = entries.any((e) =>
          e.recordedAt.isAfter(next.subtract(const Duration(hours: 1))) &&
          e.recordedAt.isBefore(next.add(const Duration(days: 1))));
      if (hasEntry) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  GlucoseStats statsFor(List<GlucoseEntry> list) =>
      GlucoseStats.compute(list, targets);

  List<GlucoseEntry> entriesInLast(Duration d) {
    final now = DateTime.now();
    return entries
        .where((e) => now.difference(e.recordedAt) <= d)
        .toList(growable: false);
  }

  Future<void> load() async {
    profile = await _profileRepo.load();
    entries = await _glucoseRepo.loadAll();
    medications = await _medicationRepo.loadAll();
    intakes = await _intakeRepo.loadAll();
    loaded = true;
    notifyListeners();
  }

  Future<void> addReading({
    required double mgdl,
    Set<ContextTag> tags = const {},
    String note = '',
    DateTime? at,
    bool confirmedUnusual = false,
  }) async {
    final entry = GlucoseEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
      recordedAt: at ?? DateTime.now(),
      mgdl: mgdl,
      tags: tags,
      note: note,
      confirmedUnusual: confirmedUnusual,
    );
    entries = <GlucoseEntry>[entry, ...entries];
    await _glucoseRepo.saveAll(entries);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    entries = entries.where((e) => e.id != id).toList();
    await _glucoseRepo.saveAll(entries);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    profile = updated;
    await _profileRepo.save(profile);
    notifyListeners();
  }

  Future<void> addMedication(String name, List<String> times) async {
    final med = Medication(
      id: 'med-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      times: List<String>.unmodifiable(times),
    );
    medications = <Medication>[...medications, med];
    await _medicationRepo.saveAll(medications);
    notifyListeners();
  }

  Future<void> removeMedication(String id) async {
    medications = medications.where((m) => m.id != id).toList();
    await _medicationRepo.saveAll(medications);
    notifyListeners();
  }

  Future<void> markMedicationTaken(String medicationId, {DateTime? at}) async {
    final intake = MedIntake(
      id: 'in-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
      medicationId: medicationId,
      takenAt: at ?? DateTime.now(),
    );
    intakes = <MedIntake>[intake, ...intakes];
    await _intakeRepo.saveAll(intakes);
    notifyListeners();
  }

  Future<void> recordWeeklyReview() =>
      updateProfile(profile.copyWith(
        lastWeeklyReviewAt: DateTime.now().toIso8601String(),
      ));

  Future<String> exportAllData() => _store.exportToFile(<String, Object?>{
        'exportedAt': DateTime.now().toIso8601String(),
        'app': 'diabetic-companion',
        'schemaVersion': 1,
        'profile': profile.toJson(),
        'entries': entries.map((e) => e.toJson()).toList(),
      });

  Future<void> deleteAllData() async {
    await _glucoseRepo.clear();
    await _profileRepo.clear();
    await _medicationRepo.clear();
    await _intakeRepo.clear();
    entries = <GlucoseEntry>[];
    medications = <Medication>[];
    intakes = <MedIntake>[];
    profile = const UserProfile();
    notifyListeners();
  }
}
