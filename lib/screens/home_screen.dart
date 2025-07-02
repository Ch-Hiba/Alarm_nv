// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alarm_controller.dart';
import '../widgets/alarm_card.dart';
import '../models/alarm.dart';
import '../widgets/repeaterDialog.dart';
import '../widgets/alarm_title_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AlarmController controller = Get.put(AlarmController());

    return Scaffold(
      backgroundColor: const Color(0xFF8B5CF6),
      body: SafeArea(
        child: Column(
          children: [
            // Header with next alarm information
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prochaine alarme',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.nextAlarmText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ],
              ),
            ),

            // Alarm list with white rounded background
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B5CF6),
                            ),
                          );
                        }

                        if (controller.alarms.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.alarm_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
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
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 0),
                          itemCount: controller.alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = controller.alarms[index];
                            return AlarmCard(
                              alarm: alarm,
                              onToggle: () => controller.toggleAlarm(alarm),
                              onDelete: () => controller.deleteAlarm(alarm.id!),
                              onEdit: () => _editAlarm(context, controller, alarm),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 4),
        child: FloatingActionButton(
          onPressed: () => _addAlarm(context, controller),
          backgroundColor: const Color(0xFF8B5CF6),
          elevation: 8,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _addAlarm(BuildContext context, AlarmController controller) async {
    // Variables pour stocker les valeurs sélectionnées
    String selectedTitle = 'Réveil'; // Valeur par défaut
    TimeOfDay? selectedTime;
    RepeatType selectedRepeatType = RepeatType.once;
    List<int> selectedCustomDays = [];

    // 1. Sélection du titre
    await showDialog(
      context: context,
      builder: (context) => AlarmTitleDialog(
        initialTitle: selectedTitle,
        onTitleChanged: (title) {
          selectedTitle = title;
        },
      ),
    );

    // 2. Sélection de l'heure
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    // 3. Sélection de la répétition
    await showDialog(
      context: context,
      builder: (context) => RepeatSelectionDialog(
        initialRepeatType: selectedRepeatType,
        initialCustomDays: selectedCustomDays,
        onRepeatSelected: (repeatType, customDays) {
          selectedRepeatType = repeatType;
          selectedCustomDays = customDays;
        },
      ),
    );

    // Créer l'alarme
    final DateTime now = DateTime.now();
    final DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await controller.addAlarm(
        selectedTitle,
        alarmTime,
        selectedRepeatType,
        selectedCustomDays
    );
  }

  void _editAlarm(BuildContext context, AlarmController controller, Alarm alarm) async {
    // Variables pour stocker les valeurs modifiées
    String selectedTitle = alarm.title;
    TimeOfDay? selectedTime;
    RepeatType selectedRepeatType = alarm.repeatType;
    List<int> selectedCustomDays = List.from(alarm.customDays);

    // 1. Modification du titre
    await showDialog(
      context: context,
      builder: (context) => AlarmTitleDialog(
        initialTitle: selectedTitle,
        onTitleChanged: (title) {
          selectedTitle = title;
        },
      ),
    );

    // 2. Modification de l'heure
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: alarm.time.hour, minute: alarm.time.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    // 3. Modification de la répétition
    await showDialog(
      context: context,
      builder: (context) => RepeatSelectionDialog(
        initialRepeatType: selectedRepeatType,
        initialCustomDays: selectedCustomDays,
        onRepeatSelected: (repeatType, customDays) {
          selectedRepeatType = repeatType;
          selectedCustomDays = customDays;
        },
      ),
    );

    // Créer l'alarme mise à jour
    final DateTime now = DateTime.now();
    final DateTime newTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final updatedAlarm = alarm.copyWith(
      title: selectedTitle,
      time: newTime,
      repeatType: selectedRepeatType,
      customDays: selectedCustomDays,
    );

    await controller.updateAlarm(updatedAlarm);
  }
}