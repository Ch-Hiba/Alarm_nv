// main.dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les fuseaux horaires
  tz.initializeTimeZones();

  // Définir le fuseau horaire local pour le Maroc
  tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));

  // Initialiser le service de notification AVANT de lancer l'app
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alarm App',
      home: const HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}