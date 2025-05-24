import 'package:flutter/material.dart';
import 'sport_selection_screen.dart';


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

  final List<bool> _isWeightUnitSelected = [true, false]; // kg / lbs
  final List<bool> _isHeightUnitSelected = [true, false]; // cm / inch

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
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter your age' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: _weightUnit == 'kg' ? 'Weight (kg)' : 'Weight (lbs)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter your weight' : null,
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: _heightUnit == 'cm' ? 'Height (cm)' : 'Height (inch)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter your height' : null,
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final age = int.tryParse(_ageController.text) ?? 0;
                    final weight = double.tryParse(_weightController.text) ?? 0.0;
                    final height = double.tryParse(_heightController.text) ?? 0.0;
                    final metricWeight = _weightUnit == 'lbs' ? weight * 0.453592 : weight;
                    final metricHeight = _heightUnit == 'inch' ? height * 2.54 : height;

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
