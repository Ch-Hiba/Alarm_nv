// widgets/repeat_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/alarm.dart';

class RepeatSelectionDialog extends StatefulWidget {
  final RepeatType initialRepeatType;
  final List<int> initialCustomDays;
  final Function(RepeatType, List<int>) onRepeatSelected;

  const RepeatSelectionDialog({
    Key? key,
    required this.initialRepeatType,
    required this.initialCustomDays,
    required this.onRepeatSelected,
  }) : super(key: key);

  @override
  State<RepeatSelectionDialog> createState() => _RepeatSelectionDialogState();
}

class _RepeatSelectionDialogState extends State<RepeatSelectionDialog> {
  late RepeatType selectedRepeatType;
  late List<int> selectedCustomDays;

  final List<String> dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  @override
  void initState() {
    super.initState();
    selectedRepeatType = widget.initialRepeatType;
    selectedCustomDays = List.from(widget.initialCustomDays);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répétition de l\'alarme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Options de répétition
            _buildRepeatOption(RepeatType.once, 'Une seule fois', Icons.schedule),
            _buildRepeatOption(RepeatType.daily, 'Tous les jours', Icons.repeat),
            _buildRepeatOption(RepeatType.weekdays, 'Jours de semaine', Icons.business_center),
            _buildRepeatOption(RepeatType.weekends, 'Week-ends', Icons.weekend),
            _buildRepeatOption(RepeatType.custom, 'Personnalisé', Icons.tune),

            // Sélection des jours personnalisés
            if (selectedRepeatType == RepeatType.custom) ...[
              const SizedBox(height: 20),
              const Text(
                'Sélectionner les jours :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _buildCustomDaysSelection(),
            ],

            const SizedBox(height: 20),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isValidSelection() ? _confirmSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Confirmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(RepeatType type, String title, IconData icon) {
    return RadioListTile<RepeatType>(
      value: type,
      groupValue: selectedRepeatType,
      onChanged: (RepeatType? value) {
        setState(() {
          selectedRepeatType = value!;
          if (value != RepeatType.custom) {
            selectedCustomDays.clear();
          }
        });
      },
      title: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      activeColor: const Color(0xFF8B5CF6),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCustomDaysSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayIndex = index + 1; // 1=Lundi, 7=Dimanche
        final isSelected = selectedCustomDays.contains(dayIndex);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedCustomDays.remove(dayIndex);
              } else {
                selectedCustomDays.add(dayIndex);
              }
            });
          },
          child: Container(
            width: 70,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                dayNames[index].substring(0, 3), // Lun, Mar, etc.
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  bool _isValidSelection() {
    if (selectedRepeatType == RepeatType.custom) {
      return selectedCustomDays.isNotEmpty;
    }
    return true;
  }

  void _confirmSelection() {
    widget.onRepeatSelected(selectedRepeatType, selectedCustomDays);
    Get.back();
  }
}