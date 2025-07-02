// widgets/alarm_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlarmCard({
    Key? key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'alarme
                Text(
                  alarm.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Label de répétition
                Text(
                  alarm.repeatText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Main time display
                Text(
                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Controls on the right
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom switch
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: alarm.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: const Color(0xFF8B5CF6),
                  activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 12),

              // Menu/options button
              GestureDetector(
                onTap: () => _showOptionsBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Options pour "${alarm.title}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Edit option
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
              title: const Text('Modifier'),
              subtitle: const Text('Changer le titre, l\'heure et la répétition'),
              onTap: () {
                Get.back();
                onEdit();
              },
            ),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              subtitle: const Text('Supprimer définitivement cette alarme'),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context);
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'alarme'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'alarme "${alarm.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}