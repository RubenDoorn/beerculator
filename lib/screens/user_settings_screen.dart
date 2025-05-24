import 'package:flutter/material.dart';
import '../widgets/user_profile_form.dart';

/// Screen where the user can update their saved profile settings (age, weight, etc.)
class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Settings')),

      /// Reuses the form from the initial setup, but now in an editable context.
      /// This allows the user to update their previously saved profile.
      body: UserProfileForm(
        onSubmit: ({
          required int age,
          required double weight,
          required double height,
          required String gender,
          required String weightUnit,
          required String heightUnit,
        }) {
          // Provide confirmation feedback to the user
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile saved')));

          // Close the settings screen and return to previous screen
          Navigator.pop(context);
        },
      ),
    );
  }
}
