import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../screens/navbar.dart';

class Gacha extends StatefulWidget {
  final int coins;
  final Function(int) onCoinsChange;
  final Function(Map<String, String>) onAddToCollection;

  const Gacha({
    Key? key,
    required this.coins,
    required this.onCoinsChange,
    required this.onAddToCollection,
  }) : super(key: key);

  @override
  _GachaState createState() => _GachaState();
}

class _GachaState extends State<Gacha> with TickerProviderStateMixin {
  final List<Map<String, String>> imageTextPairs = [
    {"image": "assets/gambar/foto_1.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_2.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_3.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_4.jpeg", "rarity": "1"},
    {"image": "assets/gambar/foto_5.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_6.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_7.jpeg", "rarity": "3"},
    {"image": "assets/gambar/foto_8.jpeg", "rarity": "1"},
    {"image": "assets/gambar/foto_9.jpeg", "rarity": "1"},
    {"image": "assets/gambar/foto_10.jpeg", "rarity": "2"},
    {"image": "assets/gambar/foto_11.jpeg", "rarity": "2"},
  ];

  List<Map<String, String>> lastResults = [];
  bool isLoading = false;
  int currentCoins = 0;
  int gachaCount = 0;
  int nextGoldGacha = 80;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    currentCoins = widget.coins;
    _loadGachaProgress();

    // Animasi untuk button
    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );

    _buttonAnimController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadGachaProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gachaCount = prefs.getInt('gachaCount') ?? 0;
      nextGoldGacha = prefs.getInt('nextGoldGacha') ?? 80;
    });
  }

  Future<void> _saveGachaProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gachaCount', gachaCount);
    await prefs.setInt('nextGoldGacha', nextGoldGacha);
  }

  void _randomize(int count) async {
    if (currentCoins < count) return;

    setState(() {
      isLoading = true;
      lastResults = [];
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      currentCoins -= count;
      widget.onCoinsChange(-count);

      for (int i = 0; i < count; i++) {
        gachaCount++;

        if (gachaCount >= nextGoldGacha) {
          lastResults.add(_getGuaranteedItem("3"));
          gachaCount = 0;
          nextGoldGacha = 80;
        } else {
          lastResults.add(_getRandomItem());
        }

        widget.onAddToCollection(lastResults[i]);
      }

      _saveGachaProgress();
      isLoading = false;
    });
  }

  Map<String, String> _getRandomItem() {
    int chance = Random().nextInt(100);
    String rarity =
        (chance < 80)
            ? "1"
            : (chance < 98)
            ? "2"
            : "3";

    List<Map<String, String>> filtered =
        imageTextPairs.where((item) => item['rarity'] == rarity).toList();

    return filtered[Random().nextInt(filtered.length)];
  }

  Map<String, String> _getGuaranteedItem(String rarity) {
    List<Map<String, String>> filtered =
        imageTextPairs.where((item) => item['rarity'] == rarity).toList();
    return filtered[Random().nextInt(filtered.length)];
  }

  String _getHighestRarity() {
    if (lastResults.isEmpty) return "1";
    return lastResults
        .map((item) => int.parse(item["rarity"]!))
        .reduce((a, b) => a > b ? a : b)
        .toString();
  }

  // Fungsi untuk mendapatkan warna border berdasarkan rarity
  Color _getRarityBorderColor(String rarity) {
    switch (rarity) {
      case "3":
        return Colors.amber.shade600; // Emas untuk rarity 3
      case "2":
        return Colors.blue.shade500; // Biru untuk rarity 2
      default:
        return Colors.grey.shade400; // Silver untuk rarity 1
    }
  }

  // Fungsi untuk mendapatkan gradien warna berdasarkan rarity
  List<Color> _getRarityGradientColors(String rarity) {
    switch (rarity) {
      case "3":
        return [
          Colors.amber.shade300,
          Colors.amber.shade700,
        ]; // Emas untuk rarity 3
      case "2":
        return [
          Colors.blue.shade300,
          Colors.blue.shade700,
        ]; // Biru untuk rarity 2
      default:
        return [
          Colors.grey.shade300,
          Colors.grey.shade600,
        ]; // Silver untuk rarity 1
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(coins: currentCoins),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        child: Center(
          child:
              isLoading
                  ? GachaLoadingAnimation(highestRarity: _getHighestRarity())
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (lastResults.isEmpty)
                        Container(
                          width: 320,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              "assets/gambar/banner.jpeg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      if (lastResults.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _getRarityBorderColor(_getHighestRarity()),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Hasil Gacha Kamu",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getRarityBorderColor(
                                    _getHighestRarity(),
                                  ),
                                  shadows: [
                                    Shadow(
                                      color: _getRarityBorderColor(
                                        _getHighestRarity(),
                                      ).withOpacity(0.7),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 15,
                                runSpacing: 15,
                                children:
                                    lastResults.map((item) {
                                      final rarity = item["rarity"]!;
                                      return Container(
                                        width: 85,
                                        height: 85,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: _getRarityGradientColors(
                                              rarity,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getRarityBorderColor(
                                                rarity,
                                              ).withOpacity(0.6),
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(
                                          3,
                                        ), // Padding untuk border gradient
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            item["image"]!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.7),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              "Gacha Emas dalam ${nextGoldGacha - gachaCount} kali lagi!",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      AnimatedBuilder(
                        animation: _buttonAnimController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScaleAnimation.value,
                            child: Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple, Colors.deepPurple],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    isLoading || currentCoins < 1
                                        ? null
                                        : () => _randomize(1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  "Gacha 1x (1 Koin)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isLoading || currentCoins < 1
                                            ? Colors.grey
                                            : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.indigo],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              isLoading || currentCoins < 10
                                  ? null
                                  : () => _randomize(10),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            "Gacha 10x (10 Koin)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isLoading || currentCoins < 10
                                      ? Colors.grey
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class GachaLoadingAnimation extends StatefulWidget {
  final String highestRarity;

  const GachaLoadingAnimation({Key? key, required this.highestRarity})
    : super(key: key);

  @override
  _GachaLoadingAnimationState createState() => _GachaLoadingAnimationState();
}

class _GachaLoadingAnimationState extends State<GachaLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi rotasi
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Animasi pulse (denyut)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.3,
    )..repeat(reverse: true);

    // Animasi partikel
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color _getMainColorFromRarity(String rarity) {
    switch (rarity) {
      case "3":
        return Colors.amber.shade600; // Emas
      case "2":
        return Colors.blue.shade500; // Biru
      default:
        return Colors.grey.shade400; // Silver
    }
  }

  List<Color> _getGradientFromRarity(String rarity) {
    switch (rarity) {
      case "3":
        return [
          Colors.amber.shade300,
          Colors.amber.shade700,
          Colors.orange.shade700,
        ]; // Gradien emas
      case "2":
        return [
          Colors.blue.shade300,
          Colors.blue.shade600,
          Colors.indigo.shade800,
        ]; // Gradien biru
      default:
        return [
          Colors.grey.shade300,
          Colors.grey.shade600,
          Colors.blueGrey.shade700,
        ]; // Gradien silver
    }
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = _getMainColorFromRarity(widget.highestRarity);
    List<Color> gradientColors = _getGradientFromRarity(widget.highestRarity);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particles circle
          ...List.generate(12, (index) {
            final angle = index * (pi / 6);
            return AnimatedBuilder(
              animation: Listenable.merge([
                _particleController,
                _pulseController,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    cos(angle + _particleController.value * 2 * pi) *
                        100 *
                        _pulseController.value,
                    sin(angle + _particleController.value * 2 * pi) *
                        100 *
                        _pulseController.value,
                  ),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main circle with rotation and pulse
          AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing ring
                  Container(
                    width: 150 * _pulseController.value,
                    height: 150 * _pulseController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          mainColor.withOpacity(0.7),
                          mainColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  // Inner rotating ring
                  Transform.rotate(
                    angle: _rotationController.value * 2 * pi,
                    child: Container(
                      width: 100 * _pulseController.value,
                      height: 100 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: gradientColors),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center circle
                  Container(
                    width: 60 * _pulseController.value,
                    height: 60 * _pulseController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.white, mainColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.8),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getRarityIcon(widget.highestRarity),
                        color: Colors.white,
                        size: 30 * _pulseController.value,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Text di bawah
          Positioned(
            bottom: -80,
            child: Column(
              children: [
                Text(
                  "Menarik Kartu...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: mainColor.withOpacity(0.8), blurRadius: 10),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Text(
                      _getRarityText(widget.highestRarity),
                      style: TextStyle(
                        fontSize: 14 + (2 * _pulseController.value),
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRarityIcon(String rarity) {
    switch (rarity) {
      case "3":
        return Icons.star; // Ikon untuk rarity 3
      case "2":
        return Icons.auto_awesome; // Ikon untuk rarity 2
      default:
        return Icons.category; // Ikon untuk rarity 1
    }
  }

  String _getRarityText(String rarity) {
    switch (rarity) {
      case "3":
        return "Rarity Tinggi Terdeteksi!";
      case "2":
        return "Rarity Menengah Terdeteksi";
      default:
        return "Rarity Umum";
    }
  }
}
