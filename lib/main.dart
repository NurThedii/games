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
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardTheme(
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Navbar(coins: coins),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icons/background.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videogame_asset,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Pilih game favorit Anda",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                    children: [
                      GameCard(
                        title: "Tic-Tac-Toe",
                        image: "assets/icons/tiktaktoe.jpg",
                        description: "Bermain tic-tac-toe klasik",
                        icon: Icons.grid_3x3,
                        color: Colors.blue,
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
                        description: "Hindari rintangan",
                        icon: Icons.flight,
                        color: Colors.orange,
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlappySquareScreen(),
                              ),
                            ),
                      ),
                      GameCard(
                        title: "Color Match",
                        image: "assets/icons/colormatch.jpg",
                        description: "Cocokkan warna dengan cepat",
                        icon: Icons.color_lens,
                        color: Colors.green,
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ColorMatchScreen(),
                              ),
                            ),
                      ),
                      GameCard(
                        title: "Gacha",
                        image: "assets/icons/gacha.jpg",
                        description: "Buka hadiah acak",
                        icon: Icons.card_giftcard,
                        color: Colors.purple,
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
                        description: "Lihat koleksi Anda",
                        icon: Icons.collections,
                        color: Colors.pink,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    Key? key,
    required this.title,
    required this.image,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image with overlay
              Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, color.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
