import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class BeerSelectionScreen extends StatefulWidget {
  const BeerSelectionScreen({super.key});

  @override
  State<BeerSelectionScreen> createState() => _BeerSelectionScreenState();
}

class _BeerSelectionScreenState extends State<BeerSelectionScreen> {
  List<Map<String, dynamic>>? _beerData;
  final _calorieController = TextEditingController();
  final _volumeController = TextEditingController();
  String? _selectedBeer;
  String? _resultText;

  @override
  void initState() {
    super.initState();
    loadBeerData();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

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
            if (_selectedBeer == 'Custom') ...[
              SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_selectedBeer == 'Custom') {
                    final calories =
                        double.tryParse(_calorieController.text) ?? 0.0;
                    final volume =
                        double.tryParse(_volumeController.text) ?? 0.0;
                    _resultText = 'Custom Beer: $calories kcal, $volume ml';
                    final totalCalories = (calories / 100.0) * volume;
                    Navigator.pop(context, totalCalories);
                  } else {
                    final beer = _beerData!.firstWhere(
                      (b) => b['name'] == _selectedBeer,
                    );
                    final totalCalories =
                        (beer['calories_per_100ml'] / 100.0) *
                        beer['volume_ml'];
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
