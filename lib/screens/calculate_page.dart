import 'dart:convert';

import 'package:beerculator/models/workout_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'beer_selection_screen.dart';
import 'user_settings_screen.dart';

/// Calculate tab: pick a workout + minutes, compute kcal and beers,
/// optionally log the workout via [onLog].
class CalculatePage extends StatefulWidget {
  final double weight;
  final double height;
  final String beerName;
  final double beerKcal;
  final void Function(String, double) onChangeBeer;
  final void Function(WorkoutEntry) onLog;

  const CalculatePage({
    super.key,
    required this.weight,
    required this.height,
    required this.onLog,
    required this.beerName,
    required this.beerKcal,
    required this.onChangeBeer,
  });

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  Map<String, dynamic>? _workoutData;

  String? _selectedWorkout;
  String? _resultText;

  // Beer choice
  double? _caloriesPerBeer;    // kcal per selected beer (one serving)
  String? _selectedBeerName;   // e.g., "Pils"

  // Last computed values (so the log button uses the exact numbers shown)
  double? _lastCalories;
  double? _lastBeers;

  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialBeer();
    _loadWorkoutData();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  /// Load workouts from assets.
  Future<void> _loadWorkoutData() async {
    final jsonString = await rootBundle.loadString('assets/exercise_data.json');
    setState(() {
      _workoutData = json.decode(jsonString) as Map<String, dynamic>;
    });
  }

  /// Persist current beer selection to SharedPreferences.
  Future<void> _persistCurrentBeerChoice() async {
    if (_selectedBeerName == null || _caloriesPerBeer == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_beer_name', _selectedBeerName!);
    await prefs.setDouble('current_beer_kcal', _caloriesPerBeer!);
  }

  /// Load beer from prefs first; fallback to default "Pils" from assets.
  Future<void> _loadInitialBeer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('current_beer_name');
    final savedKcal = prefs.getDouble('current_beer_kcal');

    if (savedName != null && savedKcal != null) {
      setState(() {
        _selectedBeerName = savedName;
        _caloriesPerBeer  = savedKcal;
      });
      return;
    }

    // Fallback to Pils from assets
    final jsonString = await rootBundle.loadString('assets/beer_data.json');
    final List<dynamic> parsed = json.decode(jsonString) as List<dynamic>;
    final beer = parsed.firstWhere((b) => b['name'] == 'Pils') as Map<String, dynamic>;
    final perBeer = (beer['calories_per_100ml'] as num) / 100.0 * (beer['volume_ml'] as num);

    setState(() {
      _selectedBeerName = beer['name'] as String;
      _caloriesPerBeer  = perBeer.toDouble();
    });
    await _persistCurrentBeerChoice();
  }

  /// Compute kcal & beers from current inputs and store the results in state.
  void _calculateResult() {
    final minutes = double.tryParse(_timeController.text) ?? 0.0;
    final rate = (_workoutData?[_selectedWorkout] as num?)?.toDouble() ?? 0.0; // kcal/kg/hour
    final durationHours = minutes / 60.0;

    if (_selectedWorkout != null &&
        _caloriesPerBeer != null &&
        _caloriesPerBeer! > 0 &&
        minutes > 0 &&
        rate > 0) {
      final calories = widget.weight * rate * durationHours;
      final beers = calories / _caloriesPerBeer!;

      setState(() {
        _lastCalories = calories;
        _lastBeers    = beers;
        _resultText   =
            'You burned ${calories.toStringAsFixed(0)} kcal = ${beers.toStringAsFixed(1)} beers ($_selectedBeerName)';
      });
    }
  }

  /// Clear input/result after logging.
  void _resetAfterLog() {
    _timeController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _resultText   = null;
      _lastCalories = null;
      _lastBeers    = null;
      // Keep _selectedWorkout and beer choice as-is for convenience.
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_workoutData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beerculator Workout Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Workout dropdown
              DropdownButtonFormField<String>(
                value: _selectedWorkout,
                decoration: const InputDecoration(labelText: 'Select Workout'),
                items: _workoutData!.keys
                    .cast<String>()
                    .map((w) => DropdownMenuItem<String>(
                          value: w,
                          child: Text(w),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedWorkout = value),
              ),
              const SizedBox(height: 16),

              // Minutes input
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (minutes)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Calculate
              ElevatedButton(
                onPressed: _calculateResult,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 16),

              // Result text
              if (_resultText != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _resultText!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),

              // Change beer button
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BeerSelectionScreen(),
                    ),
                  );

                  if (result == null) return;

                  setState(() {
                    if (result is Map &&
                        result.containsKey('selectedBeerCalories') &&
                        result.containsKey('selectedBeerName')) {
                      _caloriesPerBeer = (result['selectedBeerCalories'] as num).toDouble();
                      _selectedBeerName = result['selectedBeerName'] as String;
                    } else if (result is double) {
                      _caloriesPerBeer = result.toDouble();
                      _selectedBeerName = 'Custom';
                    }
                  });
                  await _persistCurrentBeerChoice();
                  _calculateResult(); // re-evaluate with new beer
                },
                child: Text('Change type of beer'
                    '${_selectedBeerName != null ? ' ($_selectedBeerName)' : ''}'),
              ),
              const SizedBox(height: 32),

              // Log button (only after a calculation)
              if (_resultText != null)
                ElevatedButton.icon(
                  onPressed: () {
                    final entry = WorkoutEntry(
                      activity: _selectedWorkout ?? 'Unknown',
                      minutes: double.tryParse(_timeController.text) ?? 0.0,
                      calories: _lastCalories ?? 0.0,
                      beers: _lastBeers ?? 0.0, // persisted but we use kcal as truth elsewhere
                      timestamp: DateTime.now(),
                    );

                    widget.onLog(entry);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Workout logged: ${entry.activity}, ${entry.calories.toStringAsFixed(0)} kcal",
                        ),
                      ),
                    );

                    _resetAfterLog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Log this workout"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
