import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'beer_selection_screen.dart';
import 'user_settings_screen.dart';

/// This screen allows the user to select a sport and duration,
/// and calculates how many beers (based on calories) they burned.
class CalculatePage extends StatefulWidget {
  final double weight;
  final double height;

  const CalculatePage({
    super.key,
    required this.weight,
    required this.height,
  });

  @override
  State<CalculatePage> createState() => _SportSelectionScreenState();
}

class _SportSelectionScreenState extends State<CalculatePage> {
  Map<String, dynamic>? _workoutData;
  String? _selectedWorkout;
  String? _resultText;
  double? _caloriesPerBeer;         // Total calories in selected beer
  String? _selectedBeerName;        // Name of the selected beer
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDefaultBeer();   // Loads 'Pils' as default beer on screen init
    loadWorkoutData();   // Loads the sports data from JSON
  }

  @override
  void dispose() {
    _timeController.dispose(); // Dispose controller when widget is removed
    super.dispose();
  }

  /// Loads exercise data from local JSON and updates state
  Future<void> loadWorkoutData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/exercise_data.json',
    );
    setState(() {
      _workoutData = json.decode(jsonString);
    });
  }

  /// Loads the default beer ("Pils") and sets calories per glass
  Future<void> loadDefaultBeer() async {
    final jsonString = await rootBundle.loadString('assets/beer_data.json');
    final List<dynamic> parsed = json.decode(jsonString);
    final beer = parsed.firstWhere((b) => b['name'] == 'Pils');

    setState(() {
      _caloriesPerBeer = (beer['calories_per_100ml'] / 100.0) * beer['volume_ml'];
      _selectedBeerName = beer['name'];
    });
  }

  /// Calculates calories burned and translates it to beers burned
  void _calculateResult() {
    final minutes = double.tryParse(_timeController.text) ?? 0.0;
    final rate = _workoutData?[_selectedWorkout] ?? 0.0;
    final durationHours = minutes / 60.0;

    if (_selectedWorkout != null &&
        _caloriesPerBeer != null &&
        minutes > 0 &&
        rate > 0) {
      final calories = widget.weight * rate * durationHours;
      final beers = calories / _caloriesPerBeer!;

      setState(() {
        _resultText =
            'You burned ${calories.toStringAsFixed(0)} kcal = ${beers.toStringAsFixed(1)} beers ($_selectedBeerName)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_workoutData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beerculator Workout Selection'),
        actions: [
          // Navigation to user settings via gear icon
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown to choose workout type
            DropdownButtonFormField<String>(
              value: _selectedWorkout,
              decoration: const InputDecoration(labelText: 'Select Workout'),
              items: _workoutData?.keys
                  .map((workout) =>
                      DropdownMenuItem(value: workout, child: Text(workout)))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedWorkout = value;
              }),
            ),
            const SizedBox(height: 16),

            // Input for workout duration
            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time (minutes)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the time';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Button to calculate the result
            ElevatedButton(
              onPressed: _calculateResult,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16),

            // Show result if available
            if (_resultText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _resultText!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 42),

            // Button to select a different beer
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BeerSelectionScreen(),
                  ),
                );

                // Update beer details and recalculate if user selected a new beer
                if (result != null) {
                  setState(() {
                    if (result is Map &&
                        result.containsKey('selectedBeerCalories') &&
                        result.containsKey('selectedBeerName')) {
                      _caloriesPerBeer = result['selectedBeerCalories'];
                      _selectedBeerName = result['selectedBeerName'];
                    } else if (result is double) {
                      _caloriesPerBeer = result;
                      _selectedBeerName = 'Custom';
                    }
                  });
                  _calculateResult(); // Recalculate after changing beer
                }
              },
              child: const Text('Change type of beer'),
            ),
          ],
        ),
      ),
    );
  }
}
