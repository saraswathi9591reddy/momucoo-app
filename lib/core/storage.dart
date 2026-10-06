import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';

/// Typed wrapper over shared_preferences using the SAME keys and JSON shapes as the web localStorage.
/// Every value is stored as a String (JSON text), exactly like localStorage.
class StorageKeys {
  static const profile = 'momucooProfile';
  static const account = 'momucooAccount';
  static const session = 'momucooSession'; // raw "true", not JSON
  static const cbcData = 'cbcData';
  static const pregnancyData = 'pregnancyData';
  static const scanData = 'scanData';
  static const aiResult = 'aiResult';
  static const symptoms = 'symptoms'; // legacy fallback read by AIAnalysis
}

class AppStorage {
  AppStorage._(this._prefs);
  final SharedPreferences _prefs;

  static AppStorage? _instance;
  static AppStorage get instance => _instance ?? (throw StateError('Call AppStorage.init() first'));

  /// Bumped on profile writes; replaces the web `momucoo-profile-updated` event.
  static final ValueNotifier<int> profileChanged = ValueNotifier(0);

  static Future<AppStorage> init() async => _instance = AppStorage._(await SharedPreferences.getInstance());

  @visibleForTesting
  static void resetForTest() => _instance = null;

  // ---- raw JSON helpers (localStorage.getItem / setItem semantics) ----
  String? getRaw(String key) => _prefs.getString(key);
  Future<void> setRaw(String key, String value) => _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);

  dynamic readJson(String key) {
    final raw = getRaw(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? readMap(String key) {
    final v = readJson(key);
    return v is Map ? Map<String, dynamic>.from(v) : null;
  }

  Future<void> writeJson(String key, Object? value) => setRaw(key, jsonEncode(value));

  // ---- profile ----
  Profile? get profile => _map(StorageKeys.profile, Profile.fromJson);
  /// Same defaults as the web pages (`{ name: "Ananya Sharma" }` etc.).
  Profile profileOr(String defaultName) => profile ?? Profile(name: defaultName, pregnancyStatus: '');
  Future<void> saveProfile(Profile p) async {
    await writeJson(StorageKeys.profile, p.toJson());
    profileChanged.value++;
  }

  // ---- account ----
  Account? get account => Account.tryParse(readJson(StorageKeys.account));
  Future<void> saveAccount(Account a) => writeJson(StorageKeys.account, a.toJson());

  // ---- session ----
  bool get isLoggedIn => Session.fromRaw(getRaw(StorageKeys.session)).loggedIn;
  Future<void> setLoggedIn(bool v) =>
      v ? setRaw(StorageKeys.session, Session.loggedInValue) : remove(StorageKeys.session);

  // ---- health data ----
  CbcData? get cbcData => _map(StorageKeys.cbcData, CbcData.fromJson);
  Future<void> saveCbcData(CbcData d) => writeJson(StorageKeys.cbcData, d.toJson());

  PregnancyData? get pregnancyData => _map(StorageKeys.pregnancyData, PregnancyData.fromJson);
  Future<void> savePregnancyData(PregnancyData d) => writeJson(StorageKeys.pregnancyData, d.toJson());

  ScanData? get scanData => _map(StorageKeys.scanData, ScanData.fromJson);
  Future<void> saveScanData(ScanData d) => writeJson(StorageKeys.scanData, d.toJson());

  AiResult? get aiResult => _map(StorageKeys.aiResult, AiResult.fromJson);
  Future<void> saveAiResult(AiResult r) => writeJson(StorageKeys.aiResult, r.toJson());

  List<String> get legacySymptoms =>
      (readJson(StorageKeys.symptoms) as List?)?.map((e) => e.toString()).toList() ?? [];

  T? _map<T>(String key, T Function(Map<String, dynamic>) f) {
    final m = readMap(key);
    return m == null ? null : f(m);
  }
}
