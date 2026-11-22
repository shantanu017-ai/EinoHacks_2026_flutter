import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/case_record.dart';

class CaseStore extends ChangeNotifier {
  CaseStore(this._prefs);

  static const _key = 'sahayak.cases.v1';

  final SharedPreferences _prefs;
  List<CaseRecord> _cases = const [];

  List<CaseRecord> get cases => List.unmodifiable(_cases);

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _cases = const [];
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cases = decoded
          .map((e) => CaseRecord.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on FormatException {
      _cases = const [];
    }
  }

  Future<void> add(CaseRecord record) async {
    _cases = [record, ..._cases];
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _cases = _cases.where((c) => c.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _cases = const [];
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_cases.map((c) => c.toJson()).toList()),
    );
  }
}
