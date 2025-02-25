// difficulty_modal.dart
import 'package:flutter/material.dart';

class DifficultyModal extends StatelessWidget {
  final Function(String) onDifficultySelected;

  DifficultyModal({required this.onDifficultySelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Difficulty"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "easy"),
            child: Text("Easy"),
          ),
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "medium"),
            child: Text("Medium"),
          ),
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "hard"),
            child: Text("Hard"),
          ),
        ],
      ),
    );
  }

  void _selectDifficulty(BuildContext context, String difficulty) {
    Navigator.pop(context); // Tutup modal sebelum pindah halaman
    onDifficultySelected(difficulty);
  }
}

