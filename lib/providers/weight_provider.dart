import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import 'profile_provider.dart';

final weightProvider = StateNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>(
  (ref) {
    final notifier = WeightEntriesNotifier();
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      notifier.ensureInitialEntry(profile);
    }

    ref.listen(profileProvider, (_, next) {
      final loadedProfile = next.profile;
      if (loadedProfile == null) {
        notifier.clear();
        return;
      }
      notifier.ensureInitialEntry(loadedProfile);
    });

    return notifier;
  },
);

class WeightEntriesNotifier extends StateNotifier<List<WeightEntry>> {
  WeightEntriesNotifier() : super(const []);

  void ensureInitialEntry(UserProfile profile) {
    if (state.isNotEmpty) {
      return;
    }

    state = [
      WeightEntry(
        id: 1,
        recordedAt: DateTime.now(),
        weight: profile.initialWeight,
        note: 'Primeiro registro do cadastro inicial',
        type: WeightEntryType.manual,
      ),
    ];
  }

  void resetWithInitialWeight(double weight) {
    state = [
      WeightEntry(
        id: 1,
        recordedAt: DateTime.now(),
        weight: weight,
        note: 'Primeiro registro do cadastro inicial',
        type: WeightEntryType.manual,
      ),
    ];
  }

  void clear() {
    state = const [];
  }

  void saveEntry({
    required double weight,
    required DateTime recordedAt,
    required String note,
    required WeightEntryType type,
  }) {
    final sameDayIndex = state.indexWhere(
      (entry) =>
          entry.recordedAt.year == recordedAt.year &&
          entry.recordedAt.month == recordedAt.month &&
          entry.recordedAt.day == recordedAt.day,
    );

    if (sameDayIndex != -1) {
      final current = state[sameDayIndex];
      final updated = WeightEntry(
        id: current.id,
        recordedAt: recordedAt,
        weight: weight,
        note: note,
        type: type,
      );
      state = [
        for (var index = 0; index < state.length; index++)
          if (index == sameDayIndex) updated else state[index],
      ]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      return;
    }

    final nextId = state.isEmpty
        ? 1
        : state.map((entry) => entry.id).reduce((a, b) => a > b ? a : b) + 1;
    state = [
      ...state,
      WeightEntry(
        id: nextId,
        recordedAt: recordedAt,
        weight: weight,
        note: note,
        type: type,
      ),
    ]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }
}
