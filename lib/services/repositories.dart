import '../models/glucose_entry.dart';
import '../models/medication.dart';
import '../models/user_profile.dart';
import 'storage.dart';

class GlucoseRepository {
  GlucoseRepository(this._store);

  static const _key = 'glucose_entries';
  final JsonStore _store;

  Future<List<GlucoseEntry>> loadAll() async {
    try {
      final raw = await _store.readList(_key);
      final list = raw.map(GlucoseEntry.fromJson).toList();
      list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<GlucoseEntry> entries) =>
      _store.writeList(_key, entries.map((e) => e.toJson()).toList());

  Future<void> clear() => _store.remove(_key);
}

class ProfileRepository {
  ProfileRepository(this._store);

  static const _key = 'user_profile';
  final JsonStore _store;

  Future<UserProfile> load() async {
    final raw = await _store.readMap(_key);
    if (raw == null) return const UserProfile();
    try {
      return UserProfile.fromJson(raw);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> save(UserProfile profile) =>
      _store.write(_key, profile.toJson());

  Future<void> clear() => _store.remove(_key);
}

class MedicationRepository {
  MedicationRepository(this._store);

  static const _key = 'medications';
  final JsonStore _store;

  Future<List<Medication>> loadAll() async {
    try {
      final raw = await _store.readList(_key);
      return raw.map(Medication.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Medication> meds) =>
      _store.writeList(_key, meds.map((m) => m.toJson()).toList());

  Future<void> clear() => _store.remove(_key);
}

class IntakeRepository {
  IntakeRepository(this._store);

  static const _key = 'med_intakes';
  final JsonStore _store;

  Future<List<MedIntake>> loadAll() async {
    try {
      final raw = await _store.readList(_key);
      final list = raw.map(MedIntake.fromJson).toList();
      list.sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<MedIntake> intakes) =>
      _store.writeList(_key, intakes.map((i) => i.toJson()).toList());

  Future<void> clear() => _store.remove(_key);
}
