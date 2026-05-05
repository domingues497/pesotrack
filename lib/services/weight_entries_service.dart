import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weight_entry.dart';

class WeightEntriesService {
  const WeightEntriesService();

  static const _entriesKey = 'weight_entries_v1';

  Future<List<WeightEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEntries = prefs.getString(_entriesKey);
    if (rawEntries == null || rawEntries.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawEntries) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .map(WeightEntry.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveEntries(List<WeightEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_entriesKey, jsonEncode(payload));
  }

  Future<void> clearEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
  }
}
