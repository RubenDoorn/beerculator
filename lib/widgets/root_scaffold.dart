import 'package:flutter/material.dart';
import 'package:beerculator/screens/calculate_page.dart';
import 'package:beerculator/screens/log_page.dart';
import 'package:beerculator/models/workout_entry.dart';
import 'package:beerculator/data/workout_log_store.dart';

class RootScaffold extends StatefulWidget {
  final double weight;
  final double height;

  const RootScaffold({super.key, required this.weight, required this.height});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int index = 0;

  final _store = WorkoutLogStore();
  final List<WorkoutEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final loaded = await _store.load();
    setState(() => _entries.addAll(loaded)); // keep newest-first behavior later if you want
  }

  // Keep this non-async so it matches void Function(WorkoutEntry)
  void _addEntry(WorkoutEntry e) {
    setState(() => _entries.insert(0, e)); // newest first
    _store.save(_entries); // fire-and-forget persist
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalculatePage(
        weight: widget.weight,
        height: widget.height,
        onLog: _addEntry,
      ),
      LogPage(entries: _entries),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Calculate',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'Log',
          ),
        ],
      ),
    );
  }
}
