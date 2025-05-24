import 'package:flutter/material.dart';
import 'screens/user_input_screen.dart';

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

