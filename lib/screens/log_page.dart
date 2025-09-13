// in screens/log_page.dart
import 'package:beerculator/models/workout_entry.dart';
import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  final List<WorkoutEntry> entries;
  const LogPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text("No workouts logged yet"));
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return ListTile(
          title: Text(e.activity),
          subtitle: Text("${e.minutes.toStringAsFixed(0)} min • "
                         "${e.calories.toStringAsFixed(0)} kcal • "
                         "${e.beers.toStringAsFixed(1)} beers"),
        );
      },
    );
  }
}
