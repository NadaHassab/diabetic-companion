import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/context_tag.dart';
import '../models/food_item.dart';
import '../models/glucose_entry.dart';
import '../models/meal_log.dart';
import '../models/medication.dart';
import '../models/smart_dish.dart';
import '../models/targets.dart';
import '../models/user_profile.dart';
import '../services/metrics_service.dart';
import '../services/notifications_service.dart';
import '../services/repositories.dart';
import '../services/storage.dart';

class AppState extends ChangeNotifier {
  AppState(
    this._store,
    this._glucoseRepo,
    this._profileRepo,
    this._medicationRepo,
    this._intakeRepo,
    this._mealLogRepo,
    this._smartDishRepo,
    this._favoriteFoodRepo,
  );

  factory AppState.create(JsonStore store) => AppState(
        store,
        GlucoseRepository(store),
        ProfileRepository(store),
        MedicationRepository(store),
        IntakeRepository(store),
        MealLogRepository(store),
        SmartDishRepository(store),
        FavoriteFoodRepository(store),
      );

  final JsonStore _store;
  final GlucoseRepository _glucoseRepo;
  final ProfileRepository _profileRepo;
  final MedicationRepository _medicationRepo;
  final IntakeRepository _intakeRepo;
  final MealLogRepository _mealLogRepo;
  final SmartDishRepository _smartDishRepo;
  final FavoriteFoodRepository _favoriteFoodRepo;

  bool loaded = false;
  UserProfile profile = const UserProfile();
  List<GlucoseEntry> entries = <GlucoseEntry>[];
  List<Medication> medications = <Medication>[];
  List<MedIntake> intakes = <MedIntake>[];
  List<MealLog> mealLogs = <MealLog>[];
  List<SmartDishVersion> smartVersions = <SmartDishVersion>[];
  List<DishSample> dishSamples = <DishSample>[];
  List<FavoriteFood> favoriteFoods = <FavoriteFood>[];

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
    mealLogs = await _mealLogRepo.loadAll();
    smartVersions = await _smartDishRepo.loadVersions();
    dishSamples = await _smartDishRepo.loadSamples();
    favoriteFoods = await _favoriteFoodRepo.loadAll();
    loaded = true;
    notifyListeners();
  }

  Future<GlucoseEntry> addReading({
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
    return entry;
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
    await NotificationsService.scheduleReminders(
      medications: medications,
      intakes: intakes,
    );
    notifyListeners();
  }

  Future<void> removeMedication(String id) async {
    medications = medications.where((m) => m.id != id).toList();
    await _medicationRepo.saveAll(medications);
    await NotificationsService.scheduleReminders(
      medications: medications,
      intakes: intakes,
    );
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
    await NotificationsService.scheduleReminders(
      medications: medications,
      intakes: intakes,
    );
    notifyListeners();
  }

  Future<void> recordWeeklyReview() =>
      updateProfile(profile.copyWith(
        lastWeeklyReviewAt: DateTime.now().toIso8601String(),
      ));

  Future<void> addMealLog({
    required String glucoseEntryId,
    required List<MealItem> items,
  }) async {
    final totalCarbs = items.fold(0.0, (sum, i) => sum + i.carbGrams);
    final log = MealLog(
      id: 'meal-${DateTime.now().microsecondsSinceEpoch}',
      glucoseEntryId: glucoseEntryId,
      items: items,
      totalCarbs: totalCarbs,
      loggedAt: DateTime.now(),
    );
    mealLogs = <MealLog>[log, ...mealLogs];
    await _mealLogRepo.saveAll(mealLogs);
    notifyListeners();
  }

  MealLog? mealLogForEntry(String entryId) {
    try {
      return mealLogs.firstWhere((l) => l.glucoseEntryId == entryId);
    } catch (_) {
      return null;
    }
  }

  List<MealLog> mealLogsInLast(Duration d) {
    final now = DateTime.now();
    return mealLogs
        .where((l) => now.difference(l.loggedAt) <= d)
        .toList(growable: false);
  }

  Future<void> saveSmartVersion(SmartDishVersion version) async {
    smartVersions = [version, ...smartVersions];
    await _smartDishRepo.saveVersions(smartVersions);
    notifyListeners();
  }

  Future<void> addDishSample(DishSample sample) async {
    dishSamples = [sample, ...dishSamples];
    await _smartDishRepo.saveSamples(dishSamples);
    notifyListeners();
  }

  bool isFavorite(String foodId) =>
      favoriteFoods.any((f) => f.foodId == foodId);

  Future<void> toggleFavorite(String foodId) async {
    if (isFavorite(foodId)) {
      favoriteFoods =
          favoriteFoods.where((f) => f.foodId != foodId).toList();
    } else {
      favoriteFoods = [
        ...favoriteFoods,
        FavoriteFood(
          foodId: foodId,
          addedAt: DateTime.now(),
          timesLogged: 0,
        ),
      ];
    }
    await _favoriteFoodRepo.saveAll(favoriteFoods);
    notifyListeners();
  }

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
    await _mealLogRepo.clear();
    await _smartDishRepo.clear();
    await _favoriteFoodRepo.clear();
    entries = <GlucoseEntry>[];
    medications = <Medication>[];
    intakes = <MedIntake>[];
    mealLogs = <MealLog>[];
    smartVersions = <SmartDishVersion>[];
    dishSamples = <DishSample>[];
    favoriteFoods = <FavoriteFood>[];
    profile = const UserProfile();
    notifyListeners();
  }
}
