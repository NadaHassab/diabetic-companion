import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/notifications_service.dart';
import 'services/storage.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsService.initialize();
  await NotificationsService.requestPermission();
  final store = await JsonStore.create(encrypted: true);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState.create(store)..load(),
      child: const CompanionApp(),
    ),
  );
}
