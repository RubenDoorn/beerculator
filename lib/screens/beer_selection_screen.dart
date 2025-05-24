import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// This screen allows the user to select a predefined beer type,
/// or input a custom beer (calories and volume), and returns the
/// total calories per glass back to the previous screen.
class BeerSelectionScreen extends StatefulWidget {
  const BeerSelectionScreen({super.key});

  @override
  State<BeerSelectionScreen> createState() => _BeerSelectionScreenState();
}

class _BeerSelectionScreenState extends State<BeerSelectionScreen> {
  List<Map<String, dynamic>>? _beerData;           // List of beer types loaded from JSON
  final _calorieController = TextEditingController(); // Input for custom calories
  final _volumeController = TextEditingController();  // Input for custom volume
  String? _selectedBeer;                           // Name of the selected beer
  String? _resultText;                             // Debug/output string (not currently shown)

  @override
  void initState() {
    super.initState();
    loadBeerData();  // Load beer data from assets
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  /// Loads the beer JSON from assets and casts it to a usable structure
  Future<void> loadBeerData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/beer_data.json',
    );
    final List<dynamic> parsedJson = json.decode(jsonString);
    setState(() {
      _beerData = parsedJson.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_beerData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Beerculator Beer Selection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown to select beer type
            DropdownButtonFormField<String>(
              value: _selectedBeer,
              decoration: const InputDecoration(labelText: 'Select Beer'),
              items: _beerData!.map((beer) {
                return DropdownMenuItem<String>(
                  value: beer['name'],
                  child: Text(beer['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selectedBeer = value;
              }),
            ),

            // If custom beer is selected, show input fields for calories and volume
            if (_selectedBeer == 'Custom') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _calorieController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the calories';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(labelText: 'Volume (ml)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the volume';
                  }
                  return null;
                },
              ),
            ],

            // Show beer details when one is selected (except 'Custom')
            if (_selectedBeer != 'Custom' && _selectedBeer != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(
                  builder: (context) {
                    final beer = _beerData!.firstWhere(
                      (b) => b['name'] == _selectedBeer,
                    );
                    return Text(
                      'Calories per 100ml: ${beer['calories_per_100ml']} kcal\n'
                      'Volume: ${beer['volume_ml']} ml',
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Submit the selected beer back to the previous screen
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_selectedBeer == 'Custom') {
                    final calories = double.tryParse(_calorieController.text) ?? 0.0;
                    final volume = double.tryParse(_volumeController.text) ?? 0.0;
                    _resultText = 'Custom Beer: $calories kcal, $volume ml';
                    final totalCalories = (calories / 100.0) * volume;
                    Navigator.pop(context, totalCalories);
                  } else {
                    final beer = _beerData!.firstWhere(
                      (b) => b['name'] == _selectedBeer,
                    );
                    final totalCalories = (beer['calories_per_100ml'] / 100.0) * beer['volume_ml'];
                    _resultText =
                        '${beer['name']}: ${beer['calories_per_100ml']} kcal, ${beer['volume_ml']} ml';
                    Navigator.pop(context, {
                      'selectedBeerCalories': totalCalories,
                      'selectedBeerName': beer['name'],
                    });
                  }
                });
              },
              child: const Text('Use this beer'),
            ),
          ],
        ),
      ),
    );
  }
}
