import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/storage.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await JsonStore.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState.create(store)..load(),
      child: const CompanionApp(),
    ),
  );
}
