// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import '../models/alarm.dart';
import 'dart:typed_data';
import 'alarm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AlarmService _alarmService = AlarmService();
  Timer? _checkTimer;

  // Initialiser le service de notification
  Future<void> initialize() async {
    print('🔔 Initialisation du service de notification...');

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    final bool? initialized = await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (initialized == true) {
      print('✅ Service de notification initialisé avec succès');
    } else {
      print('❌ Échec de l\'initialisation du service de notification');
    }

    // Demander les permissions pour Android 13+
    await _requestPermissions();

    // Créer les canaux de notification
    await _createNotificationChannels();

    // Démarrer la vérification périodique
    startAlarmChecker();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? notificationPermission = await androidImplementation.requestNotificationsPermission();
      final bool? alarmPermission = await androidImplementation.requestExactAlarmsPermission();

      print('🔐 Permission notifications: $notificationPermission');
      print('🔐 Permission alarmes exactes: $alarmPermission');
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'alarms_channel_id',
      'Alarmes',
      description: 'Canal pour les notifications d\'alarmes',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel snoozeChannel = AndroidNotificationChannel(
      'snooze_channel_id',
      'Alarmes reportées',
      description: 'Canal pour les alarmes reportées',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(alarmChannel);
      await androidImplementation.createNotificationChannel(snoozeChannel);
      print('✅ Canaux de notification créés');
    }
  }

  // Gérer le tap sur la notification
  void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapée: ${response.payload}');

    if (response.actionId != null) {
      final int? alarmId = int.tryParse(response.payload ?? '');
      if (alarmId != null) {
        switch (response.actionId) {
          case 'stop_alarm':
            print('🛑 Arrêt de l\'alarme $alarmId');
            _stopAlarm(alarmId);
            break;
          case 'snooze_alarm':
            print('😴 Report de l\'alarme $alarmId');
            snoozeAlarm(alarmId);
            break;
        }
      }
    }
  }

  // Démarrer la vérification périodique des alarmes (toutes les 30 secondes)
  void startAlarmChecker() {
    print('⏰ Démarrage de la vérification périodique des alarmes');
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndTriggerAlarms();
    });
  }

  // Arrêter la vérification périodique
  void stopAlarmChecker() {
    print('⏸️ Arrêt de la vérification des alarmes');
    _checkTimer?.cancel();
  }

  // Vérifier et déclencher les alarmes
  Future<void> _checkAndTriggerAlarms() async {
    try {
      print('🔍 Vérification des alarmes à déclencher...');
      final alarmsToRing = await _alarmService.getAlarmsToRing();

      if (alarmsToRing.isNotEmpty) {
        print('🚨 ${alarmsToRing.length} alarme(s) à déclencher');
      }

      for (final alarm in alarmsToRing) {
        print('🔔 Déclenchement de l\'alarme: ${alarm.title}');
        await _showAlarmNotification(alarm);

        // Si c'est une alarme "une fois", la désactiver
        if (alarm.repeatType == RepeatType.once) {
          await _alarmService.markOnceAlarmAsInactive(alarm.id!);
          print('✅ Alarme "une fois" désactivée: ${alarm.title}');
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification des alarmes: $e');
    }
  }

  // Afficher la notification d'alarme
  Future<void> _showAlarmNotification(Alarm alarm) async {
    try {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'alarms_channel_id',
        'Alarmes',
        channelDescription: 'Notifications pour les alarmes',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        showWhen: true,
        ongoing: true,
        autoCancel: false,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_alarm',
            'Arrêter',
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze_alarm',
            'Reporter (5 min)',
            cancelNotification: false,
          ),
        ],
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        alarm.id!,
        alarm.title,
        'Il est ${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')} - ${alarm.repeatText}',
        notificationDetails,
        payload: alarm.id.toString(),
      );

      print('✅ Notification affichée pour l\'alarme: ${alarm.title}');
    } catch (e) {
      print('❌ Erreur lors de l\'affichage de la notification: $e');
    }
  }

  // Arrêter une alarme
  Future<void> _stopAlarm(int alarmId) async {
    await _notifications.cancel(alarmId);
    print('🛑 Alarme $alarmId arrêtée');
  }

  // Reporter une alarme (snooze)
  Future<void> snoozeAlarm(int alarmId, {int minutes = 5}) async {
    try {
      // Annuler la notification actuelle
      await _notifications.cancel(alarmId);

      // Programmer une nouvelle notification dans X minutes
      final snoozeTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'snooze_channel_id',
        'Alarmes reportées',
        channelDescription: 'Alarmes reportées temporairement',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_alarm',
            'Arrêter',
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze_alarm',
            'Reporter encore',
            cancelNotification: false,
          ),
        ],
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        alarmId + 10000, // ID différent pour éviter les conflits
        'Alarme reportée',
        'Votre alarme a été reportée de $minutes minutes',
        snoozeTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: alarmId.toString(),



      );

      print('😴 Alarme $alarmId reportée de $minutes minutes');
    } catch (e) {
      print('❌ Erreur lors du report de l\'alarme: $e');
    }
  }

  // Annuler une notification d'alarme
  Future<void> cancelAlarmNotification(int alarmId) async {
    await _notifications.cancel(alarmId);
    await _notifications.cancel(alarmId + 10000); // Annuler aussi le snooze si il existe
  }

  // Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Test de notification (pour débugger)
  Future<void> testNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de test',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999,
      'Test de notification',
      'Si vous voyez ceci, les notifications fonctionnent !',
      notificationDetails,
    );
  }

  void dispose() {
    print('🗑️ Nettoyage du service de notification');
    _checkTimer?.cancel();
  }
}