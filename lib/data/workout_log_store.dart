import 'package:shared_preferences/shared_preferences.dart';
import 'package:beerculator/models/workout_entry.dart';

class WorkoutLogStore {
  static const _kKey = 'workout_log_v1';

  Future<List<WorkoutEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    return WorkoutEntry.decodeList(raw);
  }

  Future<void> save(List<WorkoutEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, WorkoutEntry.encodeList(items));
  }
}
