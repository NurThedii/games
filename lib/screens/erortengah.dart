import 'package:flutter/material.dart';
import '../games/tiktaktoe.dart';
import 'navbar.dart'; // Navbar tetap dipakai

class GameSelector extends StatefulWidget {
  final int coins;
  final Function(int) onCoinsChange;

  const GameSelector({
    Key? key,
    required this.coins,
    required this.onCoinsChange,
  }) : super(key: key);

  @override
  _GameSelectorState createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  Future<void> _startGame(BuildContext context, bool isSinglePlayer) async {
    String? selectedDifficulty;
    int initialCoins = widget.coins; // ✅ Simpan jumlah koin sebelum masuk game

    if (isSinglePlayer) {
      selectedDifficulty = await showDialog<String>(
        context: context,
        builder: (context) => DifficultyModal(),
      );

      if (selectedDifficulty == null) return;
    }

    print("Koin sebelum masuk game: $initialCoins");

    final int? updatedCoins = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder:
            (_) => TicTacToeScreen(
              isSinglePlayer: isSinglePlayer,
              difficulty: selectedDifficulty ?? "medium",
              coins: initialCoins, // ✅ Kirim koin awal
              onCoinsChange: (newCoins) {
                setState(() {
                  widget.onCoinsChange(newCoins); // ✅ Update koin ke Main.dart
                });
              },
            ),
      ),
    );

    // ✅ Pastikan hanya update jika ada tambahan koin, tanpa reset ulang
    if (updatedCoins != null && updatedCoins > initialCoins) {
      print("Koin setelah kembali ke GameSelector: $updatedCoins");
      setState(() {
        widget.onCoinsChange(updatedCoins);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(coins: widget.coins),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startGame(context, true),
              child: const Text("Single Player"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startGame(context, false),
              child: const Text("Multiplayer"),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultyModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Difficulty"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "easy"),
            child: const Text("Easy"),
          ),
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "medium"),
            child: const Text("Medium"),
          ),
          ElevatedButton(
            onPressed: () => _selectDifficulty(context, "hard"),
            child: const Text("Hard"),
          ),
        ],
      ),
    );
  }

  void _selectDifficulty(BuildContext context, String difficulty) {
    Navigator.pop(context, difficulty); // Kembalikan nilai difficulty
  }
}
