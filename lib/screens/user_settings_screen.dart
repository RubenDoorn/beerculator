import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/user_profile_form.dart';

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
      body: UserProfileForm(
        onSubmit:
            ({
              required int age,
              required double weight,
              required double height,
              required String gender,
              required String weightUnit,
              required String heightUnit,
            }) {
              // Show snack bar and close the screen after a short delay
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile saved')));
              // sleep(const Duration(milliseconds: 500));
              Navigator.pop(context);
            },
      ),
    );
  }
}
