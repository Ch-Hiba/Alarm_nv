// controllers/alarm_controller.dart

import 'package:get/get.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';

class AlarmController extends GetxController {
  final AlarmService _alarmService = AlarmService();

  final RxList<Alarm> alarms = <Alarm>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    isLoading.value = true;
    try {
      final loadedAlarms = await _alarmService.getAllAlarms();
      alarms.assignAll(loadedAlarms);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les alarmes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAlarm(
      String title,
      DateTime time,
      RepeatType repeatType,
      List<int> customDays
      ) async {
    try {
      final newAlarm = await _alarmService.addAlarm(title, time, repeatType, customDays);
      if (newAlarm != null) {
        alarms.add(newAlarm);
        Get.snackbar('Succès', 'Alarme ajoutée avec succès');
      } else {
        Get.snackbar('Erreur', 'Impossible d\'ajouter l\'alarme');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue');
    }
  }

  Future<void> updateAlarm(Alarm alarm) async {
    try {
      final success = await _alarmService.updateAlarm(alarm);
      if (success) {
        final index = alarms.indexWhere((a) => a.id == alarm.id);
        if (index != -1) {
          alarms[index] = alarm;
        }
        Get.snackbar('Succès', 'Alarme modifiée avec succès');
      } else {
        Get.snackbar('Erreur', 'Impossible de modifier l\'alarme');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue');
    }
  }

  Future<void> toggleAlarm(Alarm alarm) async {
    try {
      final success = await _alarmService.toggleAlarm(alarm.id!, !alarm.isActive);
      if (success) {
        final index = alarms.indexWhere((a) => a.id == alarm.id);
        if (index != -1) {
          alarms[index] = alarm.copyWith(isActive: !alarm.isActive);
        }
      } else {
        Get.snackbar('Erreur', 'Impossible de modifier l\'alarme');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue');
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      final success = await _alarmService.deleteAlarm(id);
      if (success) {
        alarms.removeWhere((alarm) => alarm.id == id);
        Get.snackbar('Succès', 'Alarme supprimée');
      } else {
        Get.snackbar('Erreur', 'Impossible de supprimer l\'alarme');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue');
    }
  }

  // Méthode pour obtenir le texte de la prochaine alarme
  String get nextAlarmText {
    if (alarms.isEmpty) return 'Aucune alarme programmée';

    final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();
    if (activeAlarms.isEmpty) return 'Aucune alarme active';

    // Trouver la prochaine alarme qui doit sonner
    final now = DateTime.now();
    Alarm? nextAlarm;
    Duration? shortestDuration;

    for (final alarm in activeAlarms) {
      if (alarm.shouldRingToday()) {
        final alarmDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.time.hour,
          alarm.time.minute,
        );

        // Si l'alarme est dans le futur aujourd'hui
        if (alarmDateTime.isAfter(now)) {
          final duration = alarmDateTime.difference(now);
          if (shortestDuration == null || duration < shortestDuration) {
            shortestDuration = duration;
            nextAlarm = alarm;
          }
        }
      }
    }

    // Si aucune alarme aujourd'hui, chercher la prochaine dans les jours suivants
    if (nextAlarm == null) {
      for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
        final checkDate = now.add(Duration(days: dayOffset));

        for (final alarm in activeAlarms) {
          final weekday = checkDate.weekday;
          bool shouldRing = false;

          switch (alarm.repeatType) {
            case RepeatType.once:
              continue; // Les alarmes "une fois" ne se répètent pas
            case RepeatType.daily:
              shouldRing = true;
              break;
            case RepeatType.weekdays:
              shouldRing = weekday >= 1 && weekday <= 5;
              break;
            case RepeatType.weekends:
              shouldRing = weekday == 6 || weekday == 7;
              break;
            case RepeatType.custom:
              shouldRing = alarm.customDays.contains(weekday);
              break;
          }

          if (shouldRing) {
            final alarmDateTime = DateTime(
              checkDate.year,
              checkDate.month,
              checkDate.day,
              alarm.time.hour,
              alarm.time.minute,
            );

            final duration = alarmDateTime.difference(now);
            if (shortestDuration == null || duration < shortestDuration) {
              shortestDuration = duration;
              nextAlarm = alarm;
            }
          }
        }

        if (nextAlarm != null) break;
      }
    }

    if (nextAlarm == null) return 'Aucune alarme programmée';

    // Formater le texte de la prochaine alarme
    final timeStr = '${nextAlarm.time.hour.toString().padLeft(2, '0')}:${nextAlarm.time.minute.toString().padLeft(2, '0')}';

    if (shortestDuration!.inHours < 1) {
      return '$timeStr dans ${shortestDuration.inMinutes} min';
    } else if (shortestDuration.inHours < 24) {
      return '$timeStr dans ${shortestDuration.inHours}h ${shortestDuration.inMinutes % 60}min';
    } else {
      final days = shortestDuration.inDays;
      return '$timeStr dans $days jour${days > 1 ? 's' : ''}';
    }
  }
}