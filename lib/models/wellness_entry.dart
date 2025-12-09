class WellnessEntry {
  final DateTime timestamp;
  final Map<String, int> answers;

  WellnessEntry({required this.timestamp, required this.answers});

  double get averageScore {
    if (answers.isEmpty) return 0.0;
    final sum = answers.values.fold<int>(0, (a, b) => a + b);
    return sum / answers.length;
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'answers': answers,
      };

  factory WellnessEntry.fromJson(Map<String, dynamic> json) {
    final rawAnswers = Map<String, dynamic>.from(json['answers'] ?? {});
    final answers = rawAnswers.map((k, v) => MapEntry(k, (v as num).toInt()));
    return WellnessEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      answers: Map<String, int>.from(answers),
    );
  }
}
