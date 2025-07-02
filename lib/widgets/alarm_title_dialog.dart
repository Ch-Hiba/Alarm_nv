// widgets/alarm_title_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmTitleDialog extends StatefulWidget {
  final String initialTitle;
  final Function(String) onTitleChanged;

  const AlarmTitleDialog({
    Key? key,
    required this.initialTitle,
    required this.onTitleChanged,
  }) : super(key: key);

  @override
  State<AlarmTitleDialog> createState() => _AlarmTitleDialogState();
}

class _AlarmTitleDialogState extends State<AlarmTitleDialog> {
  late TextEditingController _titleController;
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialTitle;
    _titleController = TextEditingController(text: _currentTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
              'Titre de l\'alarme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Champ de texte pour le titre
            TextField(
              controller: _titleController,
              autofocus: true,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Entrez le titre de l\'alarme',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
                prefixIcon: const Icon(Icons.title, color: Color(0xFF8B5CF6)),
                counterText: '', // Masquer le compteur de caractères
              ),
              onChanged: (value) {
                setState(() {
                  _currentTitle = value;
                });
              },
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _confirmTitle(),
            ),

            const SizedBox(height: 20),

            // Suggestions de titres prédéfinis
            const Text(
              'Suggestions :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('Réveil'),
                _buildSuggestionChip('Travail'),
                _buildSuggestionChip('Sport'),
                _buildSuggestionChip('Rendez-vous'),
                _buildSuggestionChip('Médicament'),
                _buildSuggestionChip('Pause'),
              ],
            ),

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
                  onPressed: _currentTitle.trim().isNotEmpty ? _confirmTitle : null,
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

  Widget _buildSuggestionChip(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTitle = title;
          _titleController.text = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _currentTitle == title ? const Color(0xFF8B5CF6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _currentTitle == title ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _currentTitle == title ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _confirmTitle() {
    final title = _currentTitle.trim();
    if (title.isNotEmpty) {
      widget.onTitleChanged(title);
      Get.back();
    }
  }
}