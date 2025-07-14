import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoriler'), centerTitle: true),
      body: const Center(
        child: Text('Henüz favori ürün yok.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
