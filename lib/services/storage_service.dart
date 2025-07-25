// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/income_entry.dart';

class StorageService {
  static const String _targetKey = 'monthly_target';
  static const String _entriesKey = 'entries';

  static Future<double> getMonthlyTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetKey) ?? 0.0;
  }

  static Future<void> setMonthlyTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetKey, target);
  }

  static Future<List<IncomeEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_entriesKey) ?? [];

    final entries = entriesJson
        .map((json) => IncomeEntry.fromJson(jsonDecode(json)))
        .toList();

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  static Future<void> saveEntries(List<IncomeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();

    await prefs.setStringList(_entriesKey, entriesJson);
  }

  static Future<void> addEntry(IncomeEntry entry) async {
    final entries = await getEntries();
    entries.insert(0, entry);
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await saveEntries(entries);
  }

  static Future<void> updateEntry(IncomeEntry updatedEntry) async {
    final entries = await getEntries();
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);

    if (index != -1) {
      entries[index] = updatedEntry;
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await saveEntries(entries);
    }
  }

  static Future<void> deleteEntry(String entryId) async {
    final entries = await getEntries();
    entries.removeWhere((entry) => entry.id == entryId);
    await saveEntries(entries);
  }
}
