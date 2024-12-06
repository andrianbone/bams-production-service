import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return json.decode(prefs.getString(key).toString());
    } catch (error) {
      print(error.toString());
    }
  }

  save(String key, value) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(key, json.encode(value));
    }
  }

  readSingleVal(String key) async {
    if (key.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  saveSingleVal(String key, value) async {
    if (key.isNotEmpty && value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(key, value);
    }
  }

  remove(String key) async {
    if (key.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(key);
    }
  }
}
