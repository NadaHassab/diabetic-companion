import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:diabetic_companion/models/context_tag.dart';
import 'package:diabetic_companion/models/user_profile.dart';
import 'package:diabetic_companion/services/storage.dart';
import 'package:diabetic_companion/state/app_state.dart';

void main() {
  late Directory tmp;
  late JsonStore store;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('companion_test');
    store = JsonStore.forDirectory(tmp);
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('JsonStore', () {
    test('readList on missing file returns empty', () async {
      expect(await store.readList('nope'), isEmpty);
    });

    test('write then read round trips a list', () async {
      await store.writeList('things', [
        {'a': 1},
        {'b': 'x'},
      ]);
      final back = await store.readList('things');
      expect(back.length, 2);
      expect(back[0]['a'], 1);
    });

    test('overwrites atomically', () async {
      await store.writeList('things', [
        {'v': 1},
      ]);
      await store.writeList('things', [
        {'v': 2},
      ]);
      final back = await store.readList('things');
      expect(back.single['v'], 2);
    });
  });

  group('AppState persistence', () {
    test('addReading persists and reloads', () async {
      final state = AppState.create(store);
      await state.load();

      await state.addReading(
        mgdl: 132,
        tags: {ContextTag.fasting},
        note: 'morning',
      );
      expect(state.entries.length, 1);
      expect(state.entries.first.mgdl, 132);

      final reloaded = AppState.create(store);
      await reloaded.load();
      expect(reloaded.entries.length, 1);
      expect(reloaded.entries.first.tags.contains(ContextTag.fasting), isTrue);
      expect(reloaded.loaded, isTrue);
    });

    test('updateProfile persists targets stratum', () async {
      final state = AppState.create(store);
      await state.load();
      await state.updateProfile(const UserProfile(pregnant: true));
      expect(state.targets.rangeHigh, 140);

      final reloaded = AppState.create(store);
      await reloaded.load();
      expect(reloaded.profile.pregnant, isTrue);
      expect(reloaded.targets.stratumLabel, contains('Pregnancy'));
    });

    test('deleteEntry removes it from disk too', () async {
      final state = AppState.create(store);
      await state.load();
      await state.addReading(mgdl: 90);
      await state.addReading(mgdl: 180);
      final id = state.entries.first.id;
      await state.deleteEntry(id);

      final reloaded = AppState.create(store);
      await reloaded.load();
      expect(reloaded.entries.length, 1);
    });

    test('deleteAllData resets profile and entries', () async {
      final state = AppState.create(store);
      await state.load();
      await state.addReading(mgdl: 90);
      await state.updateProfile(state.profile.copyWith(onboarded: true));
      await state.deleteAllData();
      expect(state.entries, isEmpty);
      expect(state.profile.onboarded, isFalse);
    });
  });
}
