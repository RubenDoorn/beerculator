import 'package:beerculator/screens/sport_selection_screen.dart';
import 'package:beerculator/screens/user_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _loading = true;
  bool _hasProfile = false;
  double _weight = 0.0;
  double _height = 0.0;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getString('age');
    final weight = prefs.getString('weight');
    final height = prefs.getString('height');

    if (age != null && weight != null && height != null) {
      _weight = double.tryParse(weight) ?? 0.0;
      _height = double.tryParse(height) ?? 0.0;
      setState(() {
        _hasProfile = true;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _hasProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _hasProfile
        ? SportSelectionScreen(weight: _weight, height: _height)
        : const UserInputScreen(title: 'Beerculator User Input');
  }
}
