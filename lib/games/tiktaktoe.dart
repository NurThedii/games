import 'package:flutter/material.dart';
import 'dart:math';
import '../screens/navbar.dart';

class TicTacToeScreen extends StatefulWidget {
  final bool isSinglePlayer;
  final String difficulty;
  final int coins;
  final Function(int) onCoinsChange;

  TicTacToeScreen({
    required this.isSinglePlayer,
    this.difficulty = "medium",
    required this.coins,
    required this.onCoinsChange,
  });

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, "");
  bool isX = true;
  String winner = "";
  List<int>? winningLine;
  bool _dialogOpen = false;
  late int currentCoins;

  final List<List<int>> _winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  @override
  void initState() {
    super.initState();
    currentCoins = widget.coins;
  }

  void _handleTap(int index) {
    if (board[index] == "" && winner == "") {
      setState(() {
        board[index] = isX ? "X" : "O";
        isX = !isX;
      });
      _checkWinner();

      if (widget.isSinglePlayer && !isX && winner == "") {
        Future.delayed(Duration(milliseconds: 500), _aiMove);
      }
    }
  }

  void _aiMove() {
    int bestMove = _findBestMove();
    if (bestMove != -1) {
      setState(() {
        board[bestMove] = "O";
        isX = true;
      });
      _checkWinner();
    }
  }

  int _findBestMove() {
    List<int> emptyCells = [
      for (int i = 0; i < 9; i++)
        if (board[i] == "") i,
    ];
    if (emptyCells.isEmpty) return -1;

    if (widget.difficulty == "easy") {
      return emptyCells[Random().nextInt(emptyCells.length)];
    } else if (widget.difficulty == "medium") {
      return _getMediumMove(emptyCells);
    } else {
      return _getBestMove();
    }
  }

  int _getMediumMove(List<int> emptyCells) {
    for (var i in emptyCells) {
      board[i] = "O";
      if (_isWinning("O")) {
        board[i] = "";
        return i;
      }
      board[i] = "";
    }
    for (var i in emptyCells) {
      board[i] = "X";
      if (_isWinning("X")) {
        board[i] = "";
        return i;
      }
      board[i] = "";
    }
    return emptyCells[Random().nextInt(emptyCells.length)];
  }

  int _getBestMove() {
    return _getMediumMove([
      for (int i = 0; i < 9; i++)
        if (board[i] == "") i,
    ]);
  }

  bool _isWinning(String player) {
    return _winningCombinations.any(
      (combo) =>
          board[combo[0]] == player &&
          board[combo[1]] == player &&
          board[combo[2]] == player,
    );
  }

  void _checkWinner() {
    for (var combo in _winningCombinations) {
      if (board[combo[0]] != "" &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        setState(() {
          winner = "${board[combo[0]]} Menang!";
          winningLine = combo;
        });

        int reward = 0;
        if (winner.contains("X") && widget.isSinglePlayer) {
          reward =
              widget.difficulty == "easy"
                  ? 1
                  : widget.difficulty == "medium"
                  ? 2
                  : 3;
          currentCoins += reward;
          widget.onCoinsChange(currentCoins);
        }

        _showGameResultDialog(winner, reward);
        return;
      }
    }

    if (!board.contains("")) {
      setState(() {
        winner = "Seri!";
      });
      _showGameResultDialog("Seri!", 0);
    }
  }

  void _showGameResultDialog(String result, int reward) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Game Over"),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () {
                  _dialogOpen = false;
                  Navigator.pop(context, currentCoins);
                },
                child: Text("Tutup"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(coins: currentCoins),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            winner.isNotEmpty ? winner : "Giliran: ${isX ? "X" : "O"}",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder:
                (context, index) => GestureDetector(
                  onTap: winner == "" ? () => _handleTap(index) : null,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          winningLine?.contains(index) == true
                              ? Colors.greenAccent
                              : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
