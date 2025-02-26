import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class FlappySquareScreen extends StatefulWidget {
  const FlappySquareScreen({super.key});

  @override
  _FlappySquareScreenState createState() => _FlappySquareScreenState();
}

class _FlappySquareScreenState extends State<FlappySquareScreen> with SingleTickerProviderStateMixin {
  double squareY = 0; // Posisi vertikal kotak
  double velocity = 0; // Kecepatan jatuh
  double gravity = 0.002; // Gaya gravitasi
  double jumpForce = -0.035; // Gaya loncat
  bool gameStarted = false;
  bool gameOver = false;
  Timer? gameLoop;
  Timer? scoreTimer;
  Timer? gameOverTimer;
  Timer? preparationTimer; // Timer untuk persiapan
  int score = 0;
  int highScore = 0;
  int countdown = 3; // Hitung mundur
  bool isCountingDown = false; // Status hitung mundur
  
  // Untuk animasi
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Background
  Color skyColor = Color(0xFF4BC6FF);
  Color groundColor = Color(0xFF8B5C34);
  
  // Obstacle List
  List<Map<String, double>> obstacles = [];
  double obstacleSpeed = 0.015; // Kecepatan obstacle bergerak ke kiri
  double squareSize = 0.1; // Ukuran kotak dalam sistem koordinat layar

  @override
  void initState() {
    super.initState();
    generateObstacles();
    
    // Inisiasi animasi untuk player
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    gameLoop?.cancel();
    scoreTimer?.cancel();
    gameOverTimer?.cancel();
    preparationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void generateObstacles() {
    obstacles.clear();
    double initialX = 1.2;

    for (int i = 0; i < 3; i++) {
      obstacles.add({
        "x": initialX + (i * 0.7), // Jarak antar obstacle
        "height": Random().nextDouble() * 0.5 + 0.2, // Random tinggi
        "gap": 0.4 // Jarak antar atas & bawah
      });
    }
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      obstacleSpeed = 0.015; // Reset kecepatan obstacle
    });
    
    // Timer untuk menambah skor (10 poin per detik)
    scoreTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (gameStarted && !gameOver) {
        setState(() {
          score += 1; // 10 poin per detik = 1 poin per 100ms
          // Meningkatkan kecepatan setiap 200 poin
          if (score % 200 == 0 && obstacleSpeed < 0.01875) { // 0.01875 adalah 25% lebih cepat dari 0.015
            obstacleSpeed *= 1.05; // Meningkatkan kecepatan sebesar 5%
          }
        });
      }
    });
    
    gameLoop = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!gameOver) {
        setState(() {
          velocity += gravity;
          squareY += velocity;

          for (var obstacle in obstacles) {
            obstacle["x"] = (obstacle["x"]! - obstacleSpeed);

            if (obstacle["x"]! < -1.2) {
              obstacle["x"] = 1.2;
              obstacle["height"] = Random().nextDouble() * 0.5 + 0.2;
            }
          }

          if (checkCollision()) {
            handleGameOver();
          }

          if (squareY > 1.1) {
            handleGameOver();
          }
        });
      }
    });
  }
  
  void handleGameOver() {
    gameOver = true;
    scoreTimer?.cancel();
    
    // Update high score
    if (score > highScore) {
      highScore = score;
    }
    
    // Tampilkan "Game Over" selama 2 detik
    gameOverTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        // Setelah 2 detik, ubah tampilan menjadi "Play Again"
        gameLoop?.cancel();
      });
    });
  }

  void jump() {
    if (gameStarted && !gameOver) {
      setState(() {
        velocity = jumpForce;
      });
    } else if (!gameStarted && !gameOver) {
      // Menunggu 3 detik sebelum memulai permainan
      startCountdown();
    }
  }

  void startCountdown() {
    isCountingDown = true;
    countdown = 3; // Reset hitung mundur
    preparationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        isCountingDown = false;
        startGame();
      }
    });
  }

  void resetGame() {
    gameLoop?.cancel();
    scoreTimer?.cancel();
    gameOverTimer?.cancel();
    preparationTimer?.cancel();
    setState(() {
      squareY = 0;
      velocity = 0;
      gameStarted = false;
      gameOver = false;
      score = 0;
      generateObstacles();
    });
  }

  bool checkCollision() {
    // Posisi kotak pemain
    double squareLeft = -squareSize / 2;  // sekitar -0.05
    double squareRight = squareSize / 2;  // sekitar 0.05
    double squareTop = squareY - squareSize / 2;
    double squareBottom = squareY + squareSize / 2;

    for (var obstacle in obstacles) {
      double obstacleX = obstacle["x"]!;
      double obstacleHeight = obstacle["height"]!;
      double obstacleGap = obstacle["gap"]!;
      
      // Posisi obstacle dalam koordinat relatif layar
      double obstacleWidth = 0.1; // Lebar obstacle dalam koordinat relatif
      double obstacleLeft = obstacleX - obstacleWidth;
      double obstacleRight = obstacleX + obstacleWidth;
      
      // Tinggi obstacle dalam koordinat relatif
      double bottomObstacleTop = 1 - (1 - obstacleHeight - obstacleGap);
      double topObstacleBottom = -1 + obstacleHeight;
      
      // Cek apakah kotak dan obstacle tumpang tindih pada sumbu X
      bool xOverlap = squareRight > obstacleLeft && squareLeft < obstacleRight;
      
      // Cek apakah kotak menabrak obstacle bawah atau atas
      bool hitTop = squareTop < topObstacleBottom;
      bool hitBottom = squareBottom > bottomObstacleTop;
      
      if (xOverlap && (hitBottom || hitTop)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameOver ? null : jump,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background - Sky
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E88E5), // Darker blue at top
                    Color(0xFF64B5F6), // Lighter blue at bottom
                  ],
                ),
              ),
            ),
            
            // Clouds (stationary decoration)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1,
              top: MediaQuery.of(context).size.height * 0.15,
              child: _buildCloud(60),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5,
              top: MediaQuery.of(context).size.height * 0.08,
              child: _buildCloud(40),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.8,
              top: MediaQuery.of(context).size.height * 0.2,
              child: _buildCloud(50),
            ),
            
            // Ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: groundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: GroundPainter(),
                  child: Container(),
                ),
              ),
            ),

            // Kotak pemain dengan rotasi
            AnimatedContainer(
              alignment: Alignment(0, squareY),
              duration: Duration(milliseconds: 16),
              child: Transform.rotate(
                angle: velocity * 1.5, // Rotasi berdasarkan kecepatan
                child: Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      )
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.amber[300]!, Colors.amber[700]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Wing animation
                      Positioned(
                        top: 15 + _animation.value * 10,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.amber[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Eyes
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Beak
                      Positioned(
                        top: 18,
                        right: 0,
                        child: Container(
                          width: 15,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

           // Obstacles
            ...obstacles.map((obstacle) {
              double screenHeight = MediaQuery.of(context).size.height;
              double topObstacleHeight = max(0, screenHeight * obstacle["height"]! / 2);
              double bottomObstacleHeight = max(0, screenHeight * (1 - obstacle["height"]! - obstacle["gap"]!) / 2);

              return Stack(
                children: [
                  // Obstacle atas
                  Positioned(
                    left: (obstacle["x"]! + 1) * MediaQuery.of(context).size.width / 2,
                    top: 0,
                    child: Container(
                      width: 70,
                      height: topObstacleHeight,
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 5,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                      child: _buildPipeDecoration(),
                    ),
                  ),
                  // Obstacle bawah
                  Positioned(
                    left: (obstacle["x"]! + 1) * MediaQuery.of(context).size.width / 2,
                    bottom: 80, // Adjust to ground height
                    child: Container(
                      width: 70,
                      height: bottomObstacleHeight,
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 5,
                            offset: Offset(3, -3),
                          )
                        ],
                      ),
                      child: _buildPipeDecoration(),
                    ),
                  ),
                ],
              );
            }),

            // Skor di pojok kanan atas (lebih kecil)
            Positioned(
              top: 30,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Text(
                  "$score",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),

            // Hitung mundur
            if (!gameStarted && isCountingDown)
              Center(
                child: Text(
                  "$countdown",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),

            // Splash screen
            if (!gameStarted && !gameOver && !isCountingDown)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "FLAPPY SQUARE",
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.touch_app, 
                          size: 40, 
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "TAP TO START",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 30),
                      if (highScore > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "HIGH SCORE: $highScore",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
            // Game Over Notification
            if (gameOver)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "GAME OVER",
                              style: TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 5,
                                    offset: Offset(2, 2),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildScoreItem("SCORE", score),
                                SizedBox(width: 20),
                                _buildScoreItem("BEST", highScore),
                              ],
                            ),
                            SizedBox(height: 30),
                            if (gameOverTimer?.isActive == false)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[700]!, Colors.green[400]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: resetGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.replay, size: 24),
                                      SizedBox(width: 8),
                                      Text("PLAY AGAIN"),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreItem(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[300],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[700]!, Colors.amber[300]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Text(
            "$value",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCloud(double size) {
    return Container(
      width: size * 2,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.3,
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.7,
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.4,
            top: size * 0.3,
            child: Container(
              width: size,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPipeDecoration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Color(0xFF1B5E20),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

// Custom painter untuk ground dengan tekstur
class GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF654321)
      ..style = PaintingStyle.fill;
    
    final darkPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    // Base ground
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw texture lines
    double lineSpacing = 10;
    for (double i = 0; i < size.width; i += lineSpacing) {
      // Randomly vary the height
      double heightVariation = Random().nextDouble() * 5;
      canvas.drawRect(
        Rect.fromLTWH(i, 0, 5, 3 + heightVariation), 
        darkPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}