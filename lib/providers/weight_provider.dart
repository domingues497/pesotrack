import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weight_entry.dart';

final weightProvider = StateNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>(
  (ref) => WeightEntriesNotifier(),
);

class WeightEntriesNotifier extends StateNotifier<List<WeightEntry>> {
  WeightEntriesNotifier()
      : super([
          WeightEntry(id: 1, recordedAt: DateTime(2026, 4, 20, 7), weight: 82.5, note: 'Inicio do diario', type: WeightEntryType.manual),
          WeightEntry(id: 2, recordedAt: DateTime(2026, 4, 22, 7, 10), weight: 81.8, note: 'Semana boa', type: WeightEntryType.manual),
          WeightEntry(id: 3, recordedAt: DateTime(2026, 4, 25, 7, 5), weight: 80.9, note: 'Via foto', type: WeightEntryType.ocr),
          WeightEntry(id: 4, recordedAt: DateTime(2026, 4, 27, 7, 8), weight: 79.5, note: '', type: WeightEntryType.manual),
        ]);
}
