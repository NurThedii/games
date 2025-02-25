import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, "");
  bool isX = true;
  String winner = "";
  List<int>? winningLine;
  bool isSinglePlayer = true;

  void _handleTap(int index) {
    if (board[index] == "" && winner == "") {
      setState(() {
        board[index] = "X";
        isX = false;
        _checkWinner();
      });

      if (isSinglePlayer && winner == "") {
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
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = "O";
        int score = _minimax(board, 0, false);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int _minimax(List<String> newBoard, int depth, bool isMaximizing) {
    String result = _checkWinnerMinimax(newBoard);
    if (result != "") {
      if (result == "O") return 10 - depth;
      if (result == "X") return depth - 10;
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == "") {
          newBoard[i] = "O";
          int score = _minimax(newBoard, depth + 1, false);
          newBoard[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (newBoard[i] == "") {
          newBoard[i] = "X";
          int score = _minimax(newBoard, depth + 1, true);
          newBoard[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var combo in winningCombinations) {
      if (board[combo[0]] != "" &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        setState(() {
          winner = "${board[combo[0]]} Menang!";
          if (board[combo[0]] == "O") {
            winner += " Yahaha! Cupu lu dek 😆";
          }
          winningLine = combo;
        });
        return;
      }
    }
  }

  String _checkWinnerMinimax(List<String> newBoard) {
    for (var combo in [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ]) {
      if (newBoard[combo[0]] != "" &&
          newBoard[combo[0]] == newBoard[combo[1]] &&
          newBoard[combo[1]] == newBoard[combo[2]]) {
        return newBoard[combo[0]];
      }
    }
    return newBoard.contains("") ? "" : "draw";
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
}
