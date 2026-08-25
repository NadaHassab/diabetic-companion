import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/glucose_entry.dart';
import '../../services/safety_service.dart';
import '../../state/app_state.dart';
import 'add/add_reading_sheet.dart';
import 'dashboard/dashboard_screen.dart';
import 'logbook/logbook_screen.dart';
import 'safety/safety_screen.dart';
import 'safety/protocol_screen.dart';
import 'settings/settings_screen.dart';
import 'studio/studio_screen.dart';
import 'widgets/voice_input_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.format_list_bulleted_outlined),
      selectedIcon: Icon(Icons.format_list_bulleted),
      label: 'Logbook',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Kitchen',
    ),
    NavigationDestination(
      icon: Icon(Icons.health_and_safety_outlined),
      selectedIcon: Icon(Icons.health_and_safety),
      label: 'Safety',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  Future<void> _openAdd() async {
    final entry = await showModalBottomSheet<GlucoseEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddReadingSheet(),
    );
    if (entry == null || !mounted) return;

    final state = context.read<AppState>();
    final severity = SafetyService.classify(entry.mgdl, state.targets);
    if (severity.needsProtocolCard) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            ProtocolScreen(severity: severity, value: entry.mgdl),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Reading saved. Consistency is what counts.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openVoiceInput() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const VoiceInputSheet(),
    );
    if (result == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Command processed.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardScreen(onQuickAdd: _openAdd),
          const LogbookScreen(),
          const StudioScreen(),
          const SafetyScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'voice',
            onPressed: _openVoiceInput,
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: _openAdd,
            icon: const Icon(Icons.add),
            label: const Text('Log'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: _destinations,
      ),
    );
  }
}
