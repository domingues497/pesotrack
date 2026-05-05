enum WeightEntryType { manual, ocr }

class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.recordedAt,
    required this.weight,
    required this.note,
    required this.type,
  });

  final int id;
  final DateTime recordedAt;
  final double weight;
  final String note;
  final WeightEntryType type;

  String get typeLabel => type == WeightEntryType.ocr ? 'OCR' : 'Manual';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordedAt': recordedAt.toIso8601String(),
      'weight': weight,
      'note': note,
      'type': type.name,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] as String? ?? '',
      type: WeightEntryType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => WeightEntryType.manual,
      ),
    );
  }
}
