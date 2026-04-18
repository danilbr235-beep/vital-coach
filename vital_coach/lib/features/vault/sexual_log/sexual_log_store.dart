import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sexual_log_models.dart';

class SexualLogStore {
  static const _kKey = 'vault_sexual_log_v1';
  static const _maxEntries = 500;

  Future<List<SexualLogEntry>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => SexualLogEntry.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  Future<void> add(SexualLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await list();
    final next = [entry, ...current].take(_maxEntries).toList(growable: false);
    final raw = jsonEncode(next.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_kKey, raw);
  }
}

