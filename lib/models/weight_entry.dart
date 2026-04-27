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
}
