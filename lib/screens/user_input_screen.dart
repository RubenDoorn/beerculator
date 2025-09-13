import 'package:flutter/material.dart';

import 'calculate_page.dart';
import '../widgets/user_profile_form.dart';

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
        }) {
          // After successful submission, navigate to the Sport Selection screen
          // with weight and height passed as arguments.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CalculatePage(
                weight: weight,
                height: height,
              ),
            ),
          );
        },
      ),
    );
  }
}
