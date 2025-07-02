import 'package:flutter/material.dart';
import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlarmCard({
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.all(20),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label "Weekdays"
                Text(
                  'Weekdays',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),

                // Heure principale
                Text(
                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 4),

                // Titre de l'alarme
                Text(
                  alarm.title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Contrôles à droite
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Switch personnalisé
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: alarm.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: Color(0xFF8B5CF6),
                  activeTrackColor: Color(0xFF8B5CF6).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(height: 12),

              // Bouton menu/options
              GestureDetector(
                onTap: () => _showOptionsBottomSheet(context),
                child: Container(
                  padding: EdgeInsets.all(8),
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de drag
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),

            // Titre
            Text(
              'Options d\'alarme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Option Modifier
            ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF8B5CF6)),
              title: Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),

            // Option Supprimer
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}