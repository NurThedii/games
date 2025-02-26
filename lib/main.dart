import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/game_mode.dart';
import 'games/tiktaktoe.dart';
import 'games/color_match.dart';
import 'games/flappy_bird.dart';
import 'games/gacha.dart';
import 'games/koleksi.dart';
import 'screens/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int coins = 0;
  List<Map<String, String>> koleksiGacha = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      String? koleksiString = prefs.getString('koleksiGacha');
      if (koleksiString != null) {
        koleksiGacha = List<Map<String, String>>.from(
          json
              .decode(koleksiString)
              .map((item) => Map<String, String>.from(item)),
        );
      }
    });
  }

  void updateCoins(int change) async {
    setState(() {
      coins += change;
      if (coins < 0) coins = 0;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }

  void addToKoleksi(Map<String, String> item) async {
    setState(() {
      koleksiGacha.add(item);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('koleksiGacha', json.encode(koleksiGacha));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameListScreen(
        coins: coins,
        onCoinsChange: updateCoins,
        koleksiGacha: koleksiGacha,
        addToKoleksi: addToKoleksi,
      ),
    );
  }
}

class GameListScreen extends StatelessWidget {
  final int coins;
  final Function(int) onCoinsChange;
  final List<Map<String, String>> koleksiGacha;
  final Function(Map<String, String>) addToKoleksi;

  const GameListScreen({
    Key? key,
    required this.coins,
    required this.onCoinsChange,
    required this.koleksiGacha,
    required this.addToKoleksi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(coins: coins),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icons/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            GameCard(
              title: "Tic-Tac-Toe",
              image: "assets/icons/tiktaktoe.jpg",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => GameSelector(
                            coins: coins,
                            onCoinsChange: onCoinsChange,
                          ),
                    ),
                  ),
            ),
            GameCard(
              title: "Flappy Square",
              image: "assets/icons/flappy_bird.jpg",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FlappySquareScreen()),
                  ),
            ),
            GameCard(
              title: "Color Match",
              image: "assets/icons/colormatch.jpg",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ColorMatchScreen()),
                  ),
            ),
            GameCard(
              title: "Gacha",
              image: "assets/icons/gacha.jpg",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => Gacha(
                            coins: coins,
                            onCoinsChange: onCoinsChange,
                            onAddToCollection: addToKoleksi,
                          ),
                    ),
                  ),
            ),
            GameCard(
              title: "Koleksi",
              image: "assets/icons/koleksi.jpg",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CollectionScreen(
                            coins: coins,
                            collection: koleksiGacha,
                          ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const GameCard({
    Key? key,
    required this.title,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 80, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
