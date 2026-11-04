enum BodyMeasurement {
  shoulders,
  chest,
  bicepsRight,
  bicepsLeft,
  forearmRight,
  forearmLeft,
  thighRight,
  thighLeft,
  calfRight,
  calfLeft,
}

class BodyMeasurementEntry {
  final double cm;
  final DateTime date;

  const BodyMeasurementEntry({required this.cm, required this.date});

  Map<String, dynamic> toJson() => {'cm': cm, 't': date.toIso8601String()};

  factory BodyMeasurementEntry.fromJson(Map<String, dynamic> json) =>
      BodyMeasurementEntry(
        cm: (json['cm'] as num).toDouble(),
        date: DateTime.parse(json['t'] as String),
      );
}
