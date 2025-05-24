import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A reusable form widget that collects and saves the user's personal profile.
/// This includes age, weight, height, gender, and unit preferences.
class UserProfileForm extends StatefulWidget {
  /// Callback function executed after successful submission.
  final void Function({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String weightUnit,
    required String heightUnit,
  }) onSubmit;

  const UserProfileForm({super.key, required this.onSubmit});

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedGender;

  // Toggle states for unit selections
  final List<bool> _isWeightUnitSelected = [true, false]; // kg / lbs
  final List<bool> _isHeightUnitSelected = [true, false]; // cm / inch

  // Helpers to get the selected unit as text
  String get _weightUnit => _isWeightUnitSelected[0] ? 'kg' : 'lbs';
  String get _heightUnit => _isHeightUnitSelected[0] ? 'cm' : 'inch';

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // Load saved profile data from local storage
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Loads profile values from SharedPreferences and populates the form
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _ageController.text = prefs.getString('age') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _selectedGender = prefs.getString('gender');

      final weightUnit = prefs.getString('weightUnit');
      if (weightUnit != null) {
        _isWeightUnitSelected[0] = weightUnit == 'kg';
        _isWeightUnitSelected[1] = weightUnit == 'lbs';
      }

      final heightUnit = prefs.getString('heightUnit');
      if (heightUnit != null) {
        _isHeightUnitSelected[0] = heightUnit == 'cm';
        _isHeightUnitSelected[1] = heightUnit == 'inch';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Age input
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your age' : null,
            ),

            const SizedBox(height: 16),

            /// Weight input
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: _weightUnit == 'kg' ? 'Weight (kg)' : 'Weight (lbs)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your weight' : null,
            ),

            /// Weight unit toggle
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

            const SizedBox(height: 16),

            /// Gender dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please select your gender' : null,
            ),

            const SizedBox(height: 16),

            /// Height input
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: _heightUnit == 'cm' ? 'Height (cm)' : 'Height (inch)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your height' : null,
            ),

            /// Height unit toggle
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

            const SizedBox(height: 24),

            /// Submit button — saves preferences and calls the parent handler
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final age = int.tryParse(_ageController.text) ?? 0;
                  final weight = double.tryParse(_weightController.text) ?? 0.0;
                  final height = double.tryParse(_heightController.text) ?? 0.0;

                  // Convert to metric for internal logic
                  final metricWeight =
                      _weightUnit == 'lbs' ? weight * 0.453592 : weight;
                  final metricHeight =
                      _heightUnit == 'inch' ? height * 2.54 : height;

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('age', _ageController.text);
                  prefs.setString('weight', _weightController.text);
                  prefs.setString('height', _heightController.text);
                  prefs.setString('gender', _selectedGender ?? '');
                  prefs.setString('weightUnit', _weightUnit);
                  prefs.setString('heightUnit', _heightUnit);

                  // Notify parent widget (e.g., screen) with parsed data
                  widget.onSubmit(
                    age: age,
                    weight: metricWeight,
                    height: metricHeight,
                    gender: _selectedGender!,
                    weightUnit: _weightUnit,
                    heightUnit: _heightUnit,
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
