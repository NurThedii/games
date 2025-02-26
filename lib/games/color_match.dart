import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  _ColorMatchScreenState createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  late Color targetColor;
  late List<Color> options;
  final Random _random = Random();
  int score = 0;
  bool isGameOver = false;
  int timeLeft = 30;
  Timer? timer;
  final int targetScore = 20;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _generateNewColors();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _generateNewColors() {
    targetColor = _randomColor();
    options = List.generate(3, (_) => _randomColor())..add(targetColor);
    options.shuffle();
    setState(() {});
  }

  Color _randomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  void _checkMatch(Color selectedColor) {
    if (isGameOver) return;
    if (selectedColor == targetColor) {
      setState(() {
        score++;
        if (score >= targetScore) {
          _endGame(win: true);
        } else {
          _generateNewColors();
        }
      });
    } else {
      // Optionally, you can show a message for incorrect selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try Again!')),
      );
    }
  }

  void _endGame({bool win = false}) {
    setState(() {
      isGameOver = true;
    });
    timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(win ? 'You Win!' : 'Game Over!')),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      _generateNewColors();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Color Match")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isGameOver
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score >= targetScore ? "You Win!" : "Game Over!",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text("Score: $score", style: const TextStyle(fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text("Play Again"),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Time Left: $timeLeft s", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Score: $score / $targetScore", style: const TextStyle(fontSize: 20, color: Colors.white)),
                    const SizedBox(height: 20),
                    const Text("Match this color:", style: TextStyle(fontSize: 18, color: Colors.white)),
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: targetColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                    Wrap(
                      spacing: 16,
                      children: options.map((color) => GestureDetector(
                            onTap: () => _checkMatch(color),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          )).toList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}