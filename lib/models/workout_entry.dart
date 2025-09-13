import 'dart:convert';

class WorkoutEntry {
  final String activity;
  final double minutes;
  final double calories;
  final double beers;
  final DateTime timestamp; 

  const WorkoutEntry({
    required this.activity,
    required this.minutes,
    required this.calories,
    required this.beers,
    required this.timestamp, 
  });

  Map<String, dynamic> toJson() => {
    'activity': activity,
    'minutes': minutes,
    'calories': calories,
    'beers': beers,
    'ts': timestamp.toIso8601String(),
  };

  static String encodeList(List<WorkoutEntry> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<WorkoutEntry> decodeList(String s) => (jsonDecode(s) as List)
      .map((m) => WorkoutEntry.fromJson(Map<String, dynamic>.from(m)))
      .toList();

  factory WorkoutEntry.fromJson(Map<String, dynamic> m) => WorkoutEntry(
    activity: m['activity'] as String,
    minutes: (m['minutes'] as num).toDouble(),
    calories: (m['calories'] as num).toDouble(),
    beers: (m['beers'] as num).toDouble(),
    timestamp: m['ts'] != null
        ? DateTime.parse(m['ts'] as String)
        : DateTime.now(), // fallback for old saved logs
  );
}
