import 'package:flutter/material.dart';
import 'dart:math';
import '../screens/navbar.dart';
import 'package:flutter/services.dart';

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

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  List<double> animationValues = List.filled(9, 0.0);
  bool isX = true;
  String winner = "";
  List<int>? winningLine;
  bool _dialogOpen = false;
  late int currentCoins;
  late AnimationController _boardAnimationController;
  late Animation<double> _boardAnimation;
  late AnimationController _turnIndicatorController;
  late Animation<double> _turnIndicatorAnimation;
  late AnimationController _confettiController;
  List<Confetti> confetti = [];

  // Warna tema yang lebih menarik
  final Color bgColor = Color(0xFF1A2238);
  final Color primaryColor = Color(0xFF9DAAF2);
  final Color secondaryColor = Color(0xFFFF6B6B);
  final Color accentColor = Color(0xFF4ECCA3);
  final Color neutralColor = Color(0xFFEAEAEA);

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

    // Animasi board
    _boardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _boardAnimation = CurvedAnimation(
      parent: _boardAnimationController,
      curve: Curves.easeOutBack,
    );
    _boardAnimationController.forward();

    // Animasi indikator giliran
    _turnIndicatorController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _turnIndicatorAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _turnIndicatorController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasi konfeti
    _confettiController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Generate konfeti
    for (int i = 0; i < 50; i++) {
      confetti.add(
        Confetti(
          position: Offset(Random().nextDouble() * 400, -20),
          color:
              [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ][Random().nextInt(6)],
          size: Random().nextDouble() * 10 + 5,
          speed: Random().nextDouble() * 300 + 100,
        ),
      );
    }
  }

  @override
  void dispose() {
    _boardAnimationController.dispose();
    _turnIndicatorController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (board[index] == "" && winner == "") {
      HapticFeedback.mediumImpact();
      setState(() {
        board[index] = isX ? "X" : "O";
        isX = !isX;

        // Animasi untuk sel yang disentuh
        animationValues[index] = 1.0;
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              animationValues[index] = 0.0;
            });
          }
        });
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
      HapticFeedback.lightImpact();
      setState(() {
        board[bestMove] = "O";
        isX = true;

        // Animasi untuk sel yang dipilih AI
        animationValues[bestMove] = 1.0;
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              animationValues[bestMove] = 0.0;
            });
          }
        });
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
          winner = "${board[combo[0]] == 'X' ? 'X' : 'O'} Menang!";
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
          _confettiController.forward(from: 0);
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

    Future.delayed(Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Game Over",
                style: TextStyle(
                  color: neutralColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color:
                          result.contains("X")
                              ? primaryColor
                              : result.contains("O")
                              ? secondaryColor
                              : neutralColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  if (widget.isSinglePlayer && reward > 0)
                    Column(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                        SizedBox(height: 10),
                        Text(
                          "Selamat!",
                          style: TextStyle(
                            fontSize: 20,
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Anda mendapatkan $reward koin!",
                          style: TextStyle(fontSize: 18, color: accentColor),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          board = List.filled(9, "");
                          winner = "";
                          winningLine = null;
                          isX = true;
                          _dialogOpen = false;
                          _boardAnimationController.reset();
                          _boardAnimationController.forward();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Main Lagi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: bgColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        _dialogOpen = false;
                        Navigator.pop(context, currentCoins);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryColor, side: BorderSide(color: secondaryColor, width: 2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Tutup",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: Navbar(coins: currentCoins),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(painter: BackgroundPatternPainter()),
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game title
              Text(
                "Tic Tac Toe",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: neutralColor,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: primaryColor.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Turn indicator or winner announcement
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child:
                    winner.isNotEmpty
                        ? Text(
                          winner,
                          key: ValueKey<String>(winner),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                winner.contains("X")
                                    ? primaryColor
                                    : winner.contains("O")
                                    ? secondaryColor
                                    : neutralColor,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Giliran: ",
                              style: TextStyle(
                                fontSize: 22,
                                color: neutralColor,
                              ),
                            ),
                            ScaleTransition(
                              scale: _turnIndicatorAnimation,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isX ? primaryColor : secondaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isX
                                              ? primaryColor
                                              : secondaryColor)
                                          .withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isX ? "X" : "O",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: bgColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
              SizedBox(height: 30),

              // Game board
              ScaleTransition(
                scale: _boardAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder:
                        (context, index) => GestureDetector(
                          onTap: winner == "" ? () => _handleTap(index) : null,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(
                              begin: 0,
                              end: animationValues[index],
                            ),
                            duration: Duration(milliseconds: 200),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: 1.0 + (value * 0.2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        winningLine?.contains(index) == true
                                            ? accentColor.withOpacity(0.9)
                                            : primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow:
                                        winningLine?.contains(index) == true
                                            ? [
                                              BoxShadow(
                                                color: accentColor.withOpacity(
                                                  0.5,
                                                ),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                            : [],
                                    border: Border.all(
                                      color:
                                          winningLine?.contains(index) == true
                                              ? accentColor
                                              : primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child:
                                        board[index] != ""
                                            ? TweenAnimationBuilder(
                                              tween: Tween<double>(
                                                begin: 0,
                                                end: 1,
                                              ),
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.elasticOut,
                                              builder: (
                                                context,
                                                double value,
                                                child,
                                              ) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: Text(
                                                    board[index],
                                                    style: TextStyle(
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          board[index] == "X"
                                                              ? primaryColor
                                                              : secondaryColor,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 5.0,
                                                          color: (board[index] ==
                                                                      "X"
                                                                  ? primaryColor
                                                                  : secondaryColor)
                                                              .withOpacity(0.5),
                                                          offset: Offset(
                                                            1.0,
                                                            1.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                            : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Difficulty indicator for single player mode
              if (widget.isSinglePlayer)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.computer,
                        color: neutralColor.withOpacity(0.7),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Level: ${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: neutralColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Confetti animation
          if (winner.contains("X") && widget.isSinglePlayer)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    confetti: confetti,
                    progress: _confettiController.value,
                  ),
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Class untuk animasi konfeti
class Confetti {
  Offset position;
  Color color;
  double size;
  double speed;
  double rotation = Random().nextDouble() * 360;

  Confetti({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
  });
}

// Painter untuk konfeti
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double progress;

  ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < confetti.length; i++) {
      final confettiItem = confetti[i];
      paint.color = confettiItem.color.withOpacity(1.0 - progress);

      // Posisi Y berdasarkan animasi
      final yOffset = confettiItem.speed * progress;

      // Posisi X dengan sedikit gelombang
      final wave = sin(progress * 10 + i) * 10;
      final xOffset = confettiItem.position.dx + wave;

      // Rotasi
      final rotation = confettiItem.rotation + (progress * 360);

      canvas.save();
      canvas.translate(xOffset, confettiItem.position.dy + yOffset);
      canvas.rotate(rotation * pi / 180);

      // Bentuk konfeti bervariasi
      if (i % 3 == 0) {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: confettiItem.size,
            height: confettiItem.size / 2,
          ),
          paint,
        );
      } else if (i % 3 == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, confettiItem.size / 2, paint);
      } else {
        // Triangle
        final path =
            Path()
              ..moveTo(0, -confettiItem.size / 2)
              ..lineTo(confettiItem.size / 2, confettiItem.size / 2)
              ..lineTo(-confettiItem.size / 2, confettiItem.size / 2)
              ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

// Painter untuk pola latar belakang
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final spacing = 20.0;

    // Garis horizontal
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Garis vertikal
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Titik-titik persilangan
    final dotPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
