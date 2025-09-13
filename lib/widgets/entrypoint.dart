import 'package:beerculator/screens/calculate_page.dart';
import 'package:beerculator/screens/user_input_screen.dart';
import 'package:beerculator/widgets/root_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// EntryPoint widget decides which screen to show first:
/// - If user profile data is saved, go to the SportSelectionScreen.
/// - If not, prompt the user to fill in their profile with the UserInputScreen.
class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _loading = true; // Indicates if we're still checking for saved profile
  bool _hasProfile = false; // Indicates if a valid profile is found
  double _weight = 0.0; // Stored weight from preferences
  double _height = 0.0; // Stored height from preferences

  @override
  void initState() {
    super.initState();
    _checkProfile(); // Begin checking profile as soon as the widget initializes
  }

  /// Checks SharedPreferences for existing user profile data.
  /// Sets state accordingly to navigate to the appropriate screen.
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
    // While loading, show a loading indicator
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Navigate to appropriate screen based on profile existence
    return _hasProfile
      ? RootScaffold(weight: _weight, height: _height)
      : const UserInputScreen(title: 'Beerculator User Input');
  }
}
