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

class _GachaState extends State<Gacha> {
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
  int revealIndex = -1;
  int gachaCount = 0;
  int nextGoldGacha = 40;

  @override
  void initState() {
    super.initState();
    currentCoins = widget.coins;
    _loadGachaProgress();
  }

  Future<void> _loadGachaProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gachaCount = prefs.getInt('gachaCount') ?? 0;
      nextGoldGacha = prefs.getInt('nextGoldGacha') ?? 40;
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
      revealIndex = -1;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      currentCoins -= count;
      widget.onCoinsChange(-count);

      for (int i = 0; i < count; i++) {
        gachaCount++;

        if (gachaCount >= nextGoldGacha) {
          lastResults.add(_getGuaranteedItem("3")); // Jaminan kartu emas
          gachaCount = 0; // Reset setelah mendapatkan emas
          nextGoldGacha = 40; // Reset ke 40 kali lagi
        } else {
          lastResults.add(_getRandomItem());
        }

        widget.onAddToCollection(lastResults[i]);
      }

      _saveGachaProgress();

      isLoading = false;
      revealIndex = lastResults.length - 1;
    });
  }

  Map<String, String> _getRandomItem() {
    int chance = Random().nextInt(100);
    String rarity =
        (chance < 75)
            ? "1"
            : (chance < 95)
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

  Color _getBorderColor(String rarity) {
    switch (rarity) {
      case "1":
        return Colors.grey;
      case "2":
        return Colors.blue;
      case "3":
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(coins: currentCoins),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading && lastResults.isEmpty)
              Image.asset(
                "assets/gambar/banner.jpeg",
                width: 300,
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            if (!isLoading && lastResults.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    lastResults.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> item = entry.value;
                      bool isRevealed = index <= revealIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isRevealed
                                    ? _getBorderColor(item["rarity"]!)
                                    : Colors.transparent,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child:
                            isRevealed
                                ? Image.asset(
                                  item["image"]!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.black38,
                                ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 20),
            Text(
              "Gacha ${nextGoldGacha - gachaCount}x lagi untuk jaminan emas!",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : (currentCoins > 0 ? () => _randomize(1) : null),
              child: const Text("Gacha 1x (1 Koin)"),
            ),
            ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : (currentCoins >= 10 ? () => _randomize(10) : null),
              child: const Text("Gacha 10x (10 Koin)"),
            ),
          ],
        ),
      ),
    );
  }
}
