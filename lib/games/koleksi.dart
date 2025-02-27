import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/navbar.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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

class _CollectionScreenState extends State<CollectionScreen> with SingleTickerProviderStateMixin {
  int currentCoins = 0;
  String selectedSort = "All";
  List<Map<String, String>> filteredCollection = [];
  late AnimationController _controller;
  bool isDetailView = false;
  Map<String, String>? selectedItem;
  
  @override
  void initState() {
    super.initState();
    _loadCoins();
    filteredCollection = List.from(widget.collection);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        return Colors.grey.shade400;
      case "2":
        return Colors.blue.shade400;
      case "3":
        return Colors.amber.shade400;
      default:
        return Colors.transparent;
    }
  }
  
  String _getRarityName(String rarity) {
    switch (rarity) {
      case "1":
        return "Common";
      case "2":
        return "Rare";
      case "3":
        return "Legendary";
      default:
        return "Unknown";
    }
  }
  
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case "1":
        return Colors.grey.shade300;
      case "2":
        return Colors.blue.shade300;
      case "3":
        return Colors.amber.shade300;
      default:
        return Colors.white;
    }
  }
  
  void _showItemDetail(Map<String, String> item) {
    setState(() {
      selectedItem = item;
      isDetailView = true;
    });
  }
  
  void _closeDetail() {
    setState(() {
      isDetailView = false;
      selectedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Navbar(coins: currentCoins),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black87,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main collection view
              Column(
                children: [
                  // Header with animation
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, Widget? child) {
                      return Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade700,
                              Colors.deepPurple.shade800,
                            ],
                            transform: GradientRotation(_controller.value * 2 * math.pi),
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Koleksi Kartu",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.purple.shade300,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Total: ${filteredCollection.length} item${filteredCollection.length != 1 ? 's' : ''}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter row
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _filterChip("All", selectedSort == "All"),
                        _filterChip("1", selectedSort == "1"),
                        _filterChip("2", selectedSort == "2"),
                        _filterChip("3", selectedSort == "3"),
                      ],
                    ),
                  ),
                  
                  // Collection grid
                  Expanded(
                    child: filteredCollection.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.collections_outlined,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Belum ada koleksi",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Mainkan Gacha untuk mendapatkan kartu",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(12),
                          child: AnimationLimiter(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: filteredCollection.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: Duration(milliseconds: 500),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    scale: 0.9,
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: () => _showItemDetail(filteredCollection[index]),
                                        child: Hero(
                                          tag: 'card-${filteredCollection[index]["image"]}',
                                          child: _buildCollectionCard(filteredCollection[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                  ),
                ],
              ),
              
              // Detail view overlay
              if (isDetailView && selectedItem != null)
                GestureDetector(
                  onTap: _closeDetail,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Hero(
                        tag: 'card-${selectedItem!["image"]}',
                        child: GestureDetector(
                          onTap: () {}, // Prevent tap propagation
                          child: TweenAnimationBuilder(
                            duration: Duration(milliseconds: 300),
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.85,
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getBorderColor(selectedItem!["rarity"]!).withOpacity(0.8),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    color: Colors.grey.shade900,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: _getBorderColor(selectedItem!["rarity"]!),
                                        width: 3,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(17),
                                            ),
                                            child: Image.network(
                                              selectedItem!["image"]!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.grey.shade800,
                                                  Colors.grey.shade900,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(17),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color: _getRarityColor(selectedItem!["rarity"]!).withOpacity(0.2),
                                                    border: Border.all(
                                                      color: _getBorderColor(selectedItem!["rarity"]!),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _getRarityName(selectedItem!["rarity"]!),
                                                    style: TextStyle(
                                                      color: _getRarityColor(selectedItem!["rarity"]!),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Text(
                                                  "Tap di luar kartu untuk kembali",
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 12,
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
                            },
                          ),
                        ),
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
  
  Widget _filterChip(String rarity, bool isSelected) {
    String label = rarity == "All" ? "Semua" : _getRarityName(rarity);
    Color chipColor = rarity == "All" 
        ? Colors.purple 
        : _getBorderColor(rarity);
    
    return GestureDetector(
      onTap: () => _sortCollection(rarity),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCollectionCard(Map<String, String> item) {
    String rarity = item["rarity"] ?? "1";
    
    return Stack(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getBorderColor(rarity).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _getBorderColor(rarity),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          item["image"]!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: _getBorderColor(rarity),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getBorderColor(rarity).withOpacity(0.2),
                          _getBorderColor(rarity).withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getRarityName(rarity),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Rarity indicator badge
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.7),
              border: Border.all(
                color: _getBorderColor(rarity),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                rarity,
                style: TextStyle(
                  color: _getBorderColor(rarity),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // "Tap to view" hint
        Positioned(
          right: 0,
          left: 0,
          bottom: 40,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            color: Colors.black.withOpacity(0.7),
            child: Text(
              "Tap untuk melihat",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}