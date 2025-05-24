import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sport_selection_screen.dart';
import '../widgets/user_profile_form.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SportSelectionScreen(weight: weight, height: height),
                ),
              );
            },
      ),
    );
  }
}
