import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeScreen extends StatefulWidget {
  final bool isSinglePlayer;
  final String difficulty;

  TicTacToeScreen({required this.isSinglePlayer, this.difficulty = "medium"});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, "");
  bool isX = true;
  String winner = "";
  List<int>? winningLine;

  void _handleTap(int index) {
    if (board[index] == "" && winner == "") {
      setState(() {
        board[index] = isX ? "X" : "O";
        isX = !isX;
        _checkWinner();
      });

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
        _checkWinner();
      });
    }
  }

  int _findBestMove() {
    List<int> emptyCells = [
      for (int i = 0; i < 9; i++)
        if (board[i] == "") i,
    ];

    if (emptyCells.isEmpty) return -1;

    switch (widget.difficulty) {
      case "easy":
        return emptyCells[Random().nextInt(emptyCells.length)];
      case "medium":
        return _getMediumMove(emptyCells);
      case "hard":
        return _getBestMove();
      default:
        return emptyCells[Random().nextInt(emptyCells.length)];
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
    int bestScore = -1000;
    int bestMove = -1;
    List<int> emptyCells = [
      for (int i = 0; i < 9; i++)
        if (board[i] == "") i,
    ];

    for (var i in emptyCells) {
      board[i] = "O";
      int score = _minimax(board, 0, false);
      board[i] = "";
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  int _minimax(List<String> boardState, int depth, bool isMaximizing) {
    if (_isWinning("O")) return 10 - depth;
    if (_isWinning("X")) return depth - 10;
    if (!boardState.contains("")) return 0;

    List<int> emptyCells = [
      for (int i = 0; i < 9; i++)
        if (boardState[i] == "") i,
    ];
    int bestScore = isMaximizing ? -1000 : 1000;

    for (var i in emptyCells) {
      boardState[i] = isMaximizing ? "O" : "X";
      int score = _minimax(boardState, depth + 1, !isMaximizing);
      boardState[i] = "";
      bestScore = isMaximizing ? max(bestScore, score) : min(bestScore, score);
    }
    return bestScore;
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
        _showGameResultDialog(winner);
        return;
      }
    }
    if (!board.contains("")) {
      setState(() {
        winner = "Seri!";
      });
      _showGameResultDialog("Seri!");
    }
  }

  void _showGameResultDialog(String result) {
    String message = result;
    if (result.contains("X Menang") && widget.isSinglePlayer) {
      message = "🥴 Kamu menang Tcih Paling Hoki Doang !!! 🥴";
    } else if (result.contains("O Menang") && widget.isSinglePlayer) {
      message =
          "🤪🤪 Ih kalah Wwkwkwk Cupu lu dek back back back back !!! 🤪🤪";
    } else if (result == "Seri!") {
      message = "🙄 Tcih Boleh tahan🙄 ";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Game Over"),
            content: Text(message, textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame();
                },
                child: Text("Main Lagi"),
              ),
            ],
          ),
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      isX = true;
      winner = "";
      winningLine = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic-Tac-Toe")),
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
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: winner == "" ? () => _handleTap(index) : null,
                child: Container(
                  margin: EdgeInsets.all(4),
                  width: 80,
                  height: 80,
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
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _resetGame, child: Text("Reset Game")),
        ],
      ),
    );
  }

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
}
