import 'package:flutter/material.dart';
import 'package:beerculator/models/workout_entry.dart';
import 'beer_selection_screen.dart';

class LogPage extends StatelessWidget {
  final List<WorkoutEntry> entries;

  // Current beer (from RootScaffold)
  final String beerName;
  final double beerKcal;

  // Calories consumed across all beers (persisted in RootScaffold)
  final double consumedKcal;

  // Actions from RootScaffold
  final void Function(String name, double kcal) onChangeBeer;
  final void Function(double kcal)
  onDrinkBeerKcal; // <-- drink current beer kcal
  final void Function(int index) onDeleteAt;
  final void Function(int index, WorkoutEntry e) onInsertAt;

  const LogPage({
    super.key,
    required this.entries,
    required this.beerName,
    required this.beerKcal,
    required this.consumedKcal,
    required this.onDrinkBeerKcal,
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

  String _messageForCredit(double beersCredit) {
    if (beersCredit >= 10) return "Absolute hero, pint’s on you tonight 🍺";
    if (beersCredit >= 7) return "Champion stuff, you’ve earned a proper round";
    if (beersCredit >= 5) return "Brilliant effort, pint well deserved";
    if (beersCredit >= 3) return "You’re doing grand, treat yourself";
    if (beersCredit >= 1) return "Looking tidy, still in the green";
    if (beersCredit == 0) return "All square, books are balanced";
    if (beersCredit >= -1) return "Bit slack there, get the trainers on";
    if (beersCredit >= -3) return "Debt’s creeping in, time for a jog";
    if (beersCredit >= -5) return "Mate, you’re running on lager loans now";
    if (beersCredit >= -7) return "Beer bank is empty, graft needed";
    return "Massive pint debt, only sweat will save you now";
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

  Future<bool> _confirmDelete(BuildContext context, WorkoutEntry e) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
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

  @override
  Widget build(BuildContext context) {
    final totalKcal = entries.fold<double>(0, (s, e) => s + e.calories);
    final netKcal = totalKcal - consumedKcal; // kcal truth
    final beersCredit = beerKcal > 0
        ? netKcal / beerKcal
        : 0; // display in beers

    return Column(
      children: [
        // Header: beer credit + change beer + drink-a-beer (subtract kcal)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_drink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Beer credit: ${beersCredit.toStringAsFixed(1)}",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: beersCredit < 0
                                    ? Colors.red
                                    : (beersCredit > 0 ? Colors.green : null),
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickBeer(context),
                        child: Text(beerName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_messageForCredit(beersCredit.toDouble())),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (beerKcal <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Pick a valid beer first"),
                              ),
                            );
                            return;
                          }
                          onDrinkBeerKcal(
                            beerKcal,
                          ); // subtracts current beer kcal
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Recorded: 1 $beerName (${beerKcal.round()} kcal)",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text("I drank a beer"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Entries list
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text("No workouts logged yet"))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    final beersForThisEntry = beerKcal > 0
                        ? e.calories / beerKcal
                        : 0.0;

                    return ListTile(
                      title: Text(e.activity),
                      subtitle: Text(
                        "${_fmt(e.timestamp)} • "
                        "${e.minutes.round()} min • "
                        "${e.calories.round()} kcal • "
                        "${beersForThisEntry.toStringAsFixed(1)} 🍺",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove',
                        onPressed: () async {
                          final ok = await _confirmDelete(context, e);
                          if (!ok) return;

                          final removed = e;
                          final removedIndex = i;

                          onDeleteAt(removedIndex);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Deleted ${removed.activity}"),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () =>
                                    onInsertAt(removedIndex, removed),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
