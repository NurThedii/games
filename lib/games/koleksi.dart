import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/navbar.dart';

class CollectionScreen extends StatefulWidget {
  final int coins;
  final List<Map<String, String>> collection;

  const CollectionScreen({
    Key? key,
    required this.coins,
    required this.collection,
  }) : super(key: key);

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int currentCoins = 0;
  String selectedSort = "All";
  List<Map<String, String>> filteredCollection = [];

  @override
  void initState() {
    super.initState();
    _loadCoins();
    filteredCollection = List.from(widget.collection);
  }

  Future<void> _loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCoins = prefs.getInt('coins') ?? widget.coins;
    });
  }

  void _sortCollection(String rarity) {
    setState(() {
      selectedSort = rarity;
      if (rarity == "All") {
        filteredCollection = List.from(widget.collection);
      } else {
        filteredCollection =
            widget.collection
                .where((item) => item["rarity"] == rarity)
                .toList();
      }
    });
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Dropdown untuk sortir berdasarkan rarity
            DropdownButton<String>(
              value: selectedSort,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _sortCollection(newValue);
                }
              },
              items:
                  ["All", "1", "2", "3"]
                      .map(
                        (rarity) => DropdownMenuItem(
                          value: rarity,
                          child: Text(
                            rarity == "All" ? "Semua" : "Rarity $rarity",
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),

            Expanded(
              child:
                  filteredCollection.isEmpty
                      ? const Center(
                        child: Text(
                          "Belum ada koleksi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: filteredCollection.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _getBorderColor(
                                  filteredCollection[index]["rarity"]!,
                                ),
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      filteredCollection[index]["image"]!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Rarity: ${filteredCollection[index]["rarity"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
