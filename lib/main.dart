import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadWorkoutData() async {
  final String jsonString = await rootBundle.loadString(
    'assets/exercise_data.json',
  );
  return json.decode(jsonString);
}

Future<Map<String, dynamic>> loadBeerData() async {
  final String jsonString = await rootBundle.loadString(
    'assets/beer_data.json',
  );
  return json.decode(jsonString);
}

void main() {
  runApp(const BeerculatorApp());
}

class BeerculatorApp extends StatelessWidget {
  const BeerculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beerculator',
      theme: ThemeData(useMaterial3: true),
      home: const UserInputScreen(title: 'Beerculator User Input'),
    );
  }
}

class UserInputScreen extends StatefulWidget {
  final String title;

  const UserInputScreen({super.key, required this.title});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedGender;

  final List<bool> _isWeightUnitSelected = [
    true,
    false,
  ]; // true for cm, false for inches
  final List<bool> _isHeightUnitSelected = [
    true,
    false,
  ]; // true for cm, false for inches

  String get _weightUnit => _isWeightUnitSelected[0] ? 'kg' : 'lbs';
  String get _heightUnit => _isHeightUnitSelected[0] ? 'cm' : 'inch';

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: _isWeightUnitSelected[0]
                      ? 'Weight (kg)'
                      : 'Weight (lbs)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              ToggleButtons(
                isSelected: _isWeightUnitSelected,
                onPressed: (index) {
                  setState(() {
                    for (int i = 0; i < _isWeightUnitSelected.length; i++) {
                      _isWeightUnitSelected[i] = i == index;
                    }
                  });
                },
                children: const [Text('kg'), Text('lbs')],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedGender = value;
                }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: _isHeightUnitSelected[0]
                      ? 'Height (cm)'
                      : 'Height (inch)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              ToggleButtons(
                isSelected: _isHeightUnitSelected,
                onPressed: (index) {
                  setState(() {
                    for (int i = 0; i < _isHeightUnitSelected.length; i++) {
                      _isHeightUnitSelected[i] = i == index;
                    }
                  });
                },
                children: const [Text('cm'), Text('inch')],
              ),
              SizedBox(height: 16),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final age = int.tryParse(_ageController.text) ?? 0;
                    final weight =
                        double.tryParse(_weightController.text) ?? 0.0;
                    final height = double.tryParse(_heightController.text) ?? 0;
                    final metricWeight = _weightUnit == 'lbs'
                        ? weight * 0.453592
                        : weight;
                    final metricHeight = _heightUnit == 'inch'
                        ? height * 2.54
                        : height;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SportSelectionScreen(
                          weight: metricWeight,
                          height: metricHeight,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SportSelectionScreen extends StatefulWidget {
  final double weight;
  final double height;

  const SportSelectionScreen({
    super.key,
    required this.weight,
    required this.height,
  });

  @override
  State<SportSelectionScreen> createState() => _SportSelectionScreenState();
}

class _SportSelectionScreenState extends State<SportSelectionScreen> {
  Map<String, dynamic>? _workoutData;
  String? _selectedWorkout;
  String? _resultText;
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWorkoutData();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> loadWorkoutData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/exercise_data.json',
    );
    setState(() {
      _workoutData = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_workoutData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Beerculator Workout Selection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedWorkout,
              decoration: const InputDecoration(labelText: 'Select Workout'),
              items: _workoutData?.keys
                  .map(
                    (workout) =>
                        DropdownMenuItem(value: workout, child: Text(workout)),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedWorkout = value;
              }),
            ),
            const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final minutes = double.tryParse(_timeController.text) ?? 0.0;
                  final double rate = _workoutData?[_selectedWorkout];
                  final double durationHours = minutes / 60.0;
                  final double calories = widget.weight * rate * durationHours;
                  final beers = calories / 150.0; // default calories per beer

                  _resultText =
                      'You burned ${calories.toStringAsFixed(0)} kcal = ${beers.toStringAsFixed(1)} beers 🍺';
                });
              },
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BeerSelectionScreen(),
                  ),
                );
              },
              child: const Text('Change type of beer'),
            ),
          ],
        ),
      ),
    );
  }
}

class BeerSelectionScreen extends StatefulWidget {
  const BeerSelectionScreen({super.key});

  @override
  State<BeerSelectionScreen> createState() => _BeerSelectionScreenState();
}

class _BeerSelectionScreenState extends State<BeerSelectionScreen> {
  List<Map<String, dynamic>>? _beerData;
  String? _selectedBeer;
  String? _resultText;

  @override
  void initState() {
    super.initState();
    loadBeerData();
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
          ],
        ),
      ),
    );
  }
}
