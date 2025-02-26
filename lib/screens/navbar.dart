// navbar.dart
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final int coins;

  const Navbar({Key? key, required this.coins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Lets Play The Games "),
      actions: [
        Row(
          children: [
            Image.asset("assets/gambar/default.gif", width: 30, height: 30),
            const SizedBox(width: 5),
            Text(
              "$coins",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
