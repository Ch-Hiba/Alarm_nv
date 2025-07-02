import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmService {
  static int _idCounter = 0;
  static List<Alarm> _alarms = [];

  static const String _storageKey = 'alarms';

  // Sauvegarder la liste dans SharedPreferences
  static Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // Charger la liste depuis SharedPreferences
  static Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _alarms = decoded.map((e) => Alarm.fromJson(e)).toList();

      // Remettre le compteur au bon ID
      if (_alarms.isNotEmpty) {
        _idCounter = _alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
      }
    }
  }

  static Future<List<Alarm>> fetchAlarms() async {
    await loadAlarms();
    return List.from(_alarms);
  }

  static Future<Alarm> addAlarm(String title, DateTime time) async {
    final alarm = Alarm(
      id: _idCounter++,
      title: title,
      time: time,
      isActive: true,
    );
    _alarms.add(alarm);
    await _saveAlarms();
    return alarm;
  }

  static Future<void> saveEditedAlarm(Alarm updatedAlarm) async {
    final index = _alarms.indexWhere((a) => a.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      await _saveAlarms();
    }
  }

  static Future<void> deleteAlarm(int id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
  }

  static Future<void> toggleAlarm(int id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alarms[index].isActive = !_alarms[index].isActive;
      await _saveAlarms();
    }
  }

  static List<Alarm> get all => List.from(_alarms);

  static Future<void> reset() async {
    _alarms.clear();
    _idCounter = 0;
    await _saveAlarms();
  }
}
