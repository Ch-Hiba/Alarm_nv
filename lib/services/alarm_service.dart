// services/alarm_service.dart (VERSION CORRIGÉE)
import '../models/alarm.dart';
import '../database/database_helper.dart';

class AlarmService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Set<String> _triggeredAlarms = {}; // Pour éviter les doublons
  String? _lastCheckedMinute; // Pour détecter le changement de minute

  Future<List<Alarm>> getAllAlarms() async {
    try {
      return await _dbHelper.getAllAlarms();
    } catch (e) {
      print('Error getting alarms: $e');
      return [];
    }
  }

  Future<Alarm?> addAlarm(
      String title,
      DateTime time,
      RepeatType repeatType,
      List<int> customDays
      ) async {
    try {
      final alarm = Alarm(
        title: title,
        time: time,
        isActive: true,
        repeatType: repeatType,
        customDays: customDays,
      );

      final id = await _dbHelper.insertAlarm(alarm);
      return alarm.copyWith(id: id);
    } catch (e) {
      print('Error adding alarm: $e');
      return null;
    }
  }

  Future<bool> updateAlarm(Alarm alarm) async {
    try {
      final result = await _dbHelper.updateAlarm(alarm);
      return result > 0;
    } catch (e) {
      print('Error updating alarm: $e');
      return false;
    }
  }

  Future<bool> deleteAlarm(int id) async {
    try {
      final result = await _dbHelper.deleteAlarm(id);
      return result > 0;
    } catch (e) {
      print('Error deleting alarm: $e');
      return false;
    }
  }

  Future<bool> toggleAlarm(int id, bool isActive) async {
    try {
      final alarms = await getAllAlarms();
      final alarm = alarms.firstWhere((a) => a.id == id);
      final updatedAlarm = alarm.copyWith(isActive: isActive);
      return await updateAlarm(updatedAlarm);
    } catch (e) {
      print('Error toggling alarm: $e');
      return false;
    }
  }

  // Méthode améliorée pour obtenir les alarmes qui doivent sonner maintenant
  Future<List<Alarm>> getAlarmsToRing() async {
    try {
      final allAlarms = await getAllAlarms();
      final now = DateTime.now();
      final currentMinuteKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

      // Si on est dans une nouvelle minute, réinitialiser le cache
      if (_lastCheckedMinute != currentMinuteKey) {
        _triggeredAlarms.clear();
        _lastCheckedMinute = currentMinuteKey;
        print('🔄 Nouvelle minute détectée: $currentMinuteKey');
      }

      final List<Alarm> alarmsToRing = [];

      for (final alarm in allAlarms) {
        if (!alarm.isActive) continue;

        // Créer une clé unique pour cette alarme à cette minute
        final alarmKey = '${alarm.id}-$currentMinuteKey';

        // Si cette alarme a déjà été déclenchée cette minute, l'ignorer
        if (_triggeredAlarms.contains(alarmKey)) continue;

        // Vérifier si l'heure correspond (à la minute près)
        if (alarm.time.hour == now.hour && alarm.time.minute == now.minute) {
          if (alarm.shouldRingToday()) {
            alarmsToRing.add(alarm);
            _triggeredAlarms.add(alarmKey);
            print('⏰ Alarme à déclencher: ${alarm.title} à ${alarm.time.hour}:${alarm.time.minute}');
          }
        }
      }

      return alarmsToRing;
    } catch (e) {
      print('Error getting alarms to ring: $e');
      return [];
    }
  }

  // Méthode pour marquer une alarme "une fois" comme inactive après qu'elle ait sonné
  Future<void> markOnceAlarmAsInactive(int alarmId) async {
    try {
      final alarms = await getAllAlarms();
      final alarm = alarms.firstWhere((a) => a.id == alarmId);

      if (alarm.repeatType == RepeatType.once) {
        final updatedAlarm = alarm.copyWith(isActive: false);
        await updateAlarm(updatedAlarm);
      }
    } catch (e) {
      print('Error marking once alarm as inactive: $e');
    }
  }

  // Nettoyer le cache des alarmes déclenchées (à appeler périodiquement)
  void clearTriggeredCache() {
    _triggeredAlarms.clear();
  }
}