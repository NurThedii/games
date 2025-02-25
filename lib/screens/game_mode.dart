// game_selector.dart
import 'package:flutter/material.dart';
import '../games/tiktaktoe.dart';
import 'difficulty_modal.dart';

class GameSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Game Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DifficultyModal(
                    onDifficultySelected: (difficulty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicTacToeScreen(
                            isSinglePlayer: true,
                            difficulty: difficulty,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              child: Text("Single Player"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicTacToeScreen(isSinglePlayer: false),
                  ),
                );
              },
              child: Text("Multiplayer"),
            ),
          ],
        ),
      ),
    );
  }
}