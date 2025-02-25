import 'package:flutter/material.dart';
import 'games/tiktaktoe.dart';
import 'games/color_match.dart';
import 'games/fluppie_bird.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameListScreen(),
    );
  }
}

class GameListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Collection")),
      body: ListView(
        children: [
          GameTile(
            title: "Tic-Tac-Toe",
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TicTacToeScreen()),
                ),
          ),
          GameTile(
            title: "Flappy Square",
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FlappySquareScreen()),
                ),
          ),
          GameTile(
            title: "Color Match",
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ColorMatchScreen()),
                ),
          ),
        ],
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  GameTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
