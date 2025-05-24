class Beer {
  final String name;
  final double caloriesPer100ml;
  final double volumeMl;

  Beer({
    required this.name,
    required this.caloriesPer100ml,
    required this.volumeMl,
  });

  factory Beer.fromJson(Map<String, dynamic> json) => Beer(
    name: json['name'],
    caloriesPer100ml: (json['calories_per_100ml']).toDouble(),
    volumeMl: (json['volume_ml']).toDouble(),
  );
}
