import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueke/features/truekes/data/models/trueke_model.dart';

class LocalTruekeDataSource {
  final SharedPreferences _prefs;
  static const _storageKey = 'cached_financial_truekes_list';

  LocalTruekeDataSource(this._prefs);

  Future<void> cacheTruekes(List<TruekeModel> truekes) async {
    final String rawJson = jsonEncode(truekes.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, rawJson);
  }

  Future<List<TruekeModel>> getCachedTruekes() async {
    final String? rawJson = _prefs.getString(_storageKey);
    if (rawJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .map((json) => TruekeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
