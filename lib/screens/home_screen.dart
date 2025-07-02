import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/alarm_service.dart';
import '../models/alarm.dart';
import '../widgets/alarm_card.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    AlarmService.loadAlarms().then((_) => _loadAlarms());
  }


  void _loadAlarms() {
    setState(() {
      alarms = AlarmService.all;
    });
    print('Alarmes chargées: ${alarms.length}'); // Debug
  }

  Future<void> _scheduleNotification(Alarm alarm) async {
    try {
      final now = DateTime.now();
      final alarmTime = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.time.hour,
          alarm.time.minute
      );

      // Si l'heure est déjà passée aujourd'hui, programmer pour demain
      final scheduledTime = alarmTime.isBefore(now)
          ? alarmTime.add(Duration(days: 1))
          : alarmTime;

      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id,
        '⏰ ${alarm.title}',
        'Il est ${alarm.time.hour}:${alarm.time.minute.toString().padLeft(2, '0')} !',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel',
            'Alarmes',
            channelDescription: 'Notifications d\'alarmes',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('Notification programmée pour: $scheduledDate'); // Debug
    } catch (e) {
      print('Erreur lors de la programmation de la notification: $e');
    }
  }

  String _getNextAlarmText() {
    if (alarms.isEmpty) return "Aucune alarme";

    final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();
    if (activeAlarms.isEmpty) return "Aucune alarme active";

    // Trouver la prochaine alarme
    final now = DateTime.now();
    Alarm? nextAlarm;
    Duration? shortestDuration;

    for (final alarm in activeAlarms) {
      final alarmTime = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
      final adjustedAlarmTime = alarmTime.isBefore(now) ? alarmTime.add(Duration(days: 1)) : alarmTime;
      final duration = adjustedAlarmTime.difference(now);

      if (shortestDuration == null || duration < shortestDuration) {
        shortestDuration = duration;
        nextAlarm = alarm;
      }
    }

    if (nextAlarm == null) return "Aucune alarme active";

    final hours = shortestDuration!.inHours;
    final minutes = shortestDuration.inMinutes % 60;

    return "Alarme dans ${hours}h ${minutes}m";
  }

  void _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final DateTime now = DateTime.now();
    final DateTime alarmTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

    try {
      final newAlarm = await AlarmService.addAlarm("Wake up", alarmTime);
      print('Nouvelle alarme créée: ${newAlarm.id} - ${newAlarm.title}'); // Debug

      if (newAlarm.isActive) {
        await _scheduleNotification(newAlarm);
      }

      _loadAlarms(); // Recharger la liste
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'alarme: $e');
    }
  }

  void _toggleAlarm(Alarm alarm) async {
    try {
      await AlarmService.toggleAlarm(alarm.id);
      final updatedAlarms = AlarmService.all;
      final updatedAlarm = updatedAlarms.firstWhere((a) => a.id == alarm.id);

      if (updatedAlarm.isActive) {
        await _scheduleNotification(updatedAlarm);
      } else {
        await flutterLocalNotificationsPlugin.cancel(alarm.id);
      }
      _loadAlarms();
    } catch (e) {
      print('Erreur lors du basculement de l\'alarme: $e');
    }
  }
  void _editAlarm(Alarm alarm) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: alarm.time.hour, minute: alarm.time.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final DateTime now = DateTime.now();
    final DateTime newTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

    setState(() {
      alarm.time = newTime;
    });
    await AlarmService.saveEditedAlarm(alarm);
    await _scheduleNotification(alarm);
    _loadAlarms();
  }


  void _deleteAlarm(Alarm alarm) async {
    try {
      await AlarmService.deleteAlarm(alarm.id);
      await flutterLocalNotificationsPlugin.cancel(alarm.id);
      _loadAlarms();
    } catch (e) {
      print('Erreur lors de la suppression de l\'alarme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8B5CF6), // Fond violet
      body: SafeArea(
        child: Column(
          children: [
            // Header avec informations sur la prochaine alarme
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next alarm',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getNextAlarmText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Liste des alarmes avec fond blanc arrondi
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: alarms.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucune alarme',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount: alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          return AlarmCard(
                            alarm: alarm,
                            onToggle: () => _toggleAlarm(alarm),
                            onDelete: () => _deleteAlarm(alarm),
                            onEdit: () => _editAlarm(alarm),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20, right: 4),
        child: FloatingActionButton(
          onPressed: _addAlarm,
          backgroundColor: Color(0xFF8B5CF6),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
          elevation: 8,
        ),
      ),
    );
  }
}