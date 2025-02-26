import 'package:flutter/material.dart';
import '../games/tiktaktoe.dart';

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
  late int currentCoins;

  @override
  void initState() {
    super.initState();
    currentCoins = widget.coins;
  }

  Future<void> _startGame(BuildContext context, bool isSinglePlayer) async {
    String? selectedDifficulty;

    if (isSinglePlayer) {
      selectedDifficulty = await showDialog<String>(
        context: context,
        builder: (context) => DifficultyModal(),
      );

      if (selectedDifficulty == null) return;
    }

    final int? updatedCoins = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder:
            (_) => TicTacToeScreen(
              isSinglePlayer: isSinglePlayer,
              difficulty: selectedDifficulty ?? "medium",
              coins: currentCoins,
              onCoinsChange: (newCoins) {
                if (newCoins > currentCoins) {
                  setState(() {
                    currentCoins = newCoins;
                  });
                  widget.onCoinsChange(newCoins);
                }
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Pilih Mode Permainan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _startGame(context, true),
                child: const Text(
                  "Single Player",
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _startGame(context, false),
                child: const Text(
                  "Multiplayer",
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                ),
              ),
              SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Kembali ke Halaman Awal",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DifficultyModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pilih Tingkat Kesulitan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDifficultyButton(context, "Easy", Colors.green),
          _buildDifficultyButton(context, "Medium", Colors.orange),
          _buildDifficultyButton(context, "Hard", Colors.red),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String level,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => Navigator.pop(context, level.toLowerCase()),
        child: Text(level, style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
