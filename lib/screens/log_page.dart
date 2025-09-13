import 'package:flutter/material.dart';
import 'package:beerculator/models/workout_entry.dart';
import 'beer_selection_screen.dart';

class LogPage extends StatelessWidget {
  final List<WorkoutEntry> entries;
  final String beerName;
  final double beerKcal;
  final void Function(String name, double kcal) onChangeBeer;
  final void Function(int index) onDeleteAt;
  final void Function(int index, WorkoutEntry e) onInsertAt;

  const LogPage({
    super.key,
    required this.entries,
    required this.beerName,
    required this.beerKcal,
    required this.onChangeBeer,
    required this.onDeleteAt,
    required this.onInsertAt,
  });

  String _fmt(DateTime ts) {
    final dd = ts.day.toString().padLeft(2, '0');
    final mm = ts.month.toString().padLeft(2, '0');
    final yyyy = ts.year.toString();
    final hh = ts.hour.toString().padLeft(2, '0');
    final min = ts.minute.toString().padLeft(2, '0');
    return "$dd-$mm-$yyyy $hh:$min";
  }
Future<bool> _confirmDelete(BuildContext context, WorkoutEntry e) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false, // require an explicit choice
        builder: (context) => AlertDialog(
          title: const Text('Delete this workout?'),
          content: Text(
            '${e.activity} • ${e.minutes.round()} min • '
            '${e.calories.round()} kcal • ${_fmt(e.timestamp)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

  Future<void> _pickBeer(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeerSelectionScreen()),
    );
    if (result == null) return;

    late final String name;
    late final double kcal;

    if (result is Map &&
        result.containsKey('selectedBeerCalories') &&
        result.containsKey('selectedBeerName')) {
      kcal = (result['selectedBeerCalories'] as num).toDouble();
      name = result['selectedBeerName'] as String;
    } else if (result is double) {
      kcal = result.toDouble();
      name = 'Custom';
    } else {
      return;
    }
    onChangeBeer(name, kcal);
  }

  @override
  Widget build(BuildContext context) {
    final totalKcal = entries.fold<double>(0, (s, e) => s + e.calories);
    final beerCredit = beerKcal > 0 ? totalKcal / beerKcal : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.local_drink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Beer credit: ${beerCredit.toStringAsFixed(1)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickBeer(context),
                    child: Text(beerName),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text("No workouts logged yet"))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    final beers = beerKcal > 0 ? e.calories / beerKcal : 0.0;
                    return ListTile(
                      title: Text(e.activity),
                      subtitle: Text(
                        "${_fmt(e.timestamp)} • "
                        "${e.minutes.round()} min • "
                        "${e.calories.round()} kcal • "
                        "${beers.toStringAsFixed(1)} 🍺 • ",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final removed = e;
                          final removedIndex = i;
                          
                          final ok = await _confirmDelete(context, removed);
                          if (!ok) return;
                          onDeleteAt(i);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Removed workout: ${removed.activity}"),
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  onInsertAt(removedIndex, removed);
                                },
                              ),
                            ),
                          );
                        },
                        tooltip: 'Remove',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
