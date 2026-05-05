import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../services/weight_entries_service.dart';
import 'profile_provider.dart';

final weightEntriesServiceProvider = Provider<WeightEntriesService>(
  (ref) => const WeightEntriesService(),
);

final weightProvider = StateNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>(
  (ref) {
    final notifier = WeightEntriesNotifier(ref.read(weightEntriesServiceProvider));
    notifier.setProfile(ref.read(profileProvider).profile);

    ref.listen(profileProvider, (_, next) {
      notifier.setProfile(next.profile);
    });

    return notifier;
  },
);

class WeightEntriesNotifier extends StateNotifier<List<WeightEntry>> {
  WeightEntriesNotifier(this._service) : super(const []) {
    unawaited(_loadEntries());
  }

  final WeightEntriesService _service;
  UserProfile? _profile;
  bool _didLoad = false;

  void _sortState() {
    state = [...state]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  void _persistState() {
    unawaited(_service.saveEntries(state));
  }

  void _setInitialEntry(UserProfile profile) {
    state = [
      WeightEntry(
        id: 1,
        recordedAt: DateTime.now(),
        weight: profile.initialWeight,
        note: 'Primeiro registro do cadastro inicial',
        type: WeightEntryType.manual,
      ),
    ];
    _persistState();
  }

  Future<void> _loadEntries() async {
    final loadedEntries = await _service.loadEntries();
    if (state.isNotEmpty) {
      _didLoad = true;
      _persistState();
      return;
    }

    _didLoad = true;
    if (_profile == null) {
      state = const [];
      return;
    }

    state = [...loadedEntries]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final profile = _profile;
    if (state.isEmpty && profile != null) {
      _setInitialEntry(profile);
    }
  }

  void setProfile(UserProfile? profile) {
    _profile = profile;
    if (profile == null) {
      clear();
      return;
    }

    if (_didLoad && state.isEmpty) {
      _setInitialEntry(profile);
    }
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
    _persistState();
  }

  void clear() {
    state = const [];
    unawaited(_service.clearEntries());
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
      _persistState();
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
    ];
    _sortState();
    _persistState();
  }

  void updateEntry({
    required int id,
    required double weight,
    required DateTime recordedAt,
    required String note,
    required WeightEntryType type,
  }) {
    state = [
      for (final entry in state)
        if (entry.id == id)
          WeightEntry(
            id: id,
            recordedAt: recordedAt,
            weight: weight,
            note: note,
            type: type,
          )
        else
          entry,
    ];
    _sortState();
    _persistState();
  }

  void deleteEntry(int id) {
    state = [
      for (final entry in state)
        if (entry.id != id) entry,
    ];
    _sortState();
    _persistState();
  }
}
