import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ["Workout 1", "Workout 2", "Workout 3"];

    return ListView(
      children: items.map((e) => ListTile(title: Text(e))).toList(),
    );
  }
}
