// in screens/log_page.dart
import 'package:beerculator/models/workout_entry.dart';
import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  final List<WorkoutEntry> entries;
  const LogPage({super.key, required this.entries});

String _fmt(DateTime ts) {
  final dd = ts.day.toString().padLeft(2, '0');
  final mm = ts.month.toString().padLeft(2, '0');
  final yyyy = ts.year.toString();
  final hh = ts.hour.toString().padLeft(2, '0');
  final min = ts.minute.toString().padLeft(2, '0');
  return "$dd-$mm-$yyyy $hh:$min"; // e.g., 13-09-2025 16:42
}


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
          subtitle: Text(
            "${_fmt(e.timestamp)} • "
            "${e.minutes.round()} min • "
            "${e.calories.round()} kcal • "
            "${e.beers.toStringAsFixed(1)} 🍺 • "
          ),
        );
      },
    );
  }
}
