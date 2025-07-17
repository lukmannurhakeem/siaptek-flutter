import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // Integer operations
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // List operations
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  static List<String> getStringList(String key) {
    return _prefs?.getStringList(key) ?? [];
  }

  // JSON operations for complex objects
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error encoding JSON: $e');
      return false;
    }
  }

  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString.isNotEmpty) {
        return json.decode(jsonString);
      }
      return null;
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  }

  // List of JSON objects
  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error encoding JSON list: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error decoding JSON list: $e');
      return [];
    }
  }

  // Utility operations
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // Get all stored data (for debugging)
  static Map<String, dynamic> getAllData() {
    final keys = getKeys();
    Map<String, dynamic> data = {};
    for (String key in keys) {
      data[key] = _prefs?.get(key);
    }
    return data;
  }
}
