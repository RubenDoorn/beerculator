import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beerculator/data/workout_log_store.dart';
import 'package:beerculator/models/workout_entry.dart';
import 'package:beerculator/screens/calculate_page.dart';
import 'package:beerculator/screens/log_page.dart';

class BeerChoice {
  final String name;
  final double kcalPerBeer;
  const BeerChoice({required this.name, required this.kcalPerBeer});
}

class RootScaffold extends StatefulWidget {
  final double weight;
  final double height;

  const RootScaffold({super.key, required this.weight, required this.height});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int index = 0;
  static const _kConsumedKcalKey = 'kcal_consumed_v1';
  double _kcalConsumed = 0.0; // total kcal you've drunk (all beers)
  final _store = WorkoutLogStore();
  final List<WorkoutEntry> _entries = [];

  // Single source of truth for beer selection
  final ValueNotifier<BeerChoice> _beer = ValueNotifier<BeerChoice>(
    const BeerChoice(name: 'Pils', kcalPerBeer: 150),
  );

  @override
  void initState() {
    super.initState();
    _loadBeerChoice();
    _loadEntries();
    _loadConsumedKcal();
  }

  Future<void> _loadEntries() async {
    final loaded = await _store.load();
    loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _entries
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _loadConsumedKcal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _kcalConsumed = prefs.getDouble(_kConsumedKcalKey) ?? 0.0);
  }

  Future<void> _saveConsumedKcal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kConsumedKcalKey, _kcalConsumed);
  }

  // Call this when user presses "I drank a beer"
  void _drinkBeerKcal(double kcal) {
    setState(() => _kcalConsumed += (kcal > 0 ? kcal : 0.0));
    _saveConsumedKcal();
  }

  void _deleteAt(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    _store.save(_entries);
  }

  void _insertAt(int index, WorkoutEntry e) {
    setState(() {
      _entries.insert(index, e);
    });
    _store.save(_entries);
  }

  Future<void> _loadBeerChoice() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('current_beer_name');
    final kcal = prefs.getDouble('current_beer_kcal');

    if (name != null && kcal != null) {
      _beer.value = BeerChoice(name: name, kcalPerBeer: kcal);
      return;
    }

    // Fallback to "Pils" from assets
    final jsonString = await rootBundle.loadString('assets/beer_data.json');
    final List<dynamic> parsed = jsonDecode(jsonString);
    final beer =
        parsed.firstWhere((b) => b['name'] == 'Pils') as Map<String, dynamic>;
    final perBeer =
        ((beer['calories_per_100ml'] as num) / 100.0) *
        (beer['volume_ml'] as num);

    _beer.value = BeerChoice(
      name: beer['name'] as String,
      kcalPerBeer: perBeer.toDouble(),
    );
    await _persistBeerChoice(_beer.value);
  }

  Future<void> _persistBeerChoice(BeerChoice bc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_beer_name', bc.name);
    await prefs.setDouble('current_beer_kcal', bc.kcalPerBeer);
  }

  void _setBeer(String name, double kcalPerBeer) {
    final next = BeerChoice(name: name, kcalPerBeer: kcalPerBeer);
    _beer.value = next; // notify listeners (both tabs)
    _persistBeerChoice(next); // persist
    setState(() {}); // defensive rebuild for non-listeners
  }

  void _addEntry(WorkoutEntry e) {
    setState(() => _entries.insert(0, e)); // newest first
    _store.save(_entries);
  }

  @override
  Widget build(BuildContext context) {
    // Keep both tabs alive so state doesn't reset when switching
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<BeerChoice>(
          valueListenable: _beer,
          builder: (context, beer, _) {
            return IndexedStack(
              index: index,
              children: [
                CalculatePage(
                  weight: widget.weight,
                  height: widget.height,
                  onLog: _addEntry,
                  beerName: beer.name,
                  beerKcal: beer.kcalPerBeer,
                  onChangeBeer: _setBeer,
                ),
                LogPage(
                  entries: _entries,
                  beerName: beer.name,
                  beerKcal: beer.kcalPerBeer,
                  consumedKcal: _kcalConsumed, // NEW
                  onDrinkBeerKcal: _drinkBeerKcal, // NEW
                  onChangeBeer: _setBeer,
                  onDeleteAt: _deleteAt,
                  onInsertAt: _insertAt,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Calculate',
          ),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Log'),
        ],
      ),
    );
  }
}
