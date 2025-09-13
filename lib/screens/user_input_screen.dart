import 'package:flutter/material.dart';

import '../widgets/user_profile_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/root_scaffold.dart';  // instead of calculate_page.dart


/// The first screen the user sees (if no profile is saved).
/// Displays a form to collect user data like age, weight, height, and gender.
class UserInputScreen extends StatefulWidget {
  final String title;

  const UserInputScreen({super.key, required this.title});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  @override
  void initState() {
    super.initState();
    // Reserved for future setup if needed (e.g. fetching initial state).
  }

  @override
  void dispose() {
    // Clean up if necessary when screen is removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      // Uses the reusable form component to collect user input.
      body: UserProfileForm(
        // This callback is triggered after form submission and validation.
        onSubmit: ({
          required int age,
          required double weight,
          required double height,
          required String gender,
          required String weightUnit,
          required String heightUnit,
        }) async{
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('age', age.toString());
          await prefs.setString('weight', weight.toString());
          await prefs.setString('height', height.toString());

          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => RootScaffold(
              weight: weight,
              height: height,                // Handle logging the workout entry
            ),
          ));
        }
      ),
    );
  }
}