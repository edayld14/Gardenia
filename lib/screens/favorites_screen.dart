import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart'; // Eğer ayrı servis dosyası varsa

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final CartService _cartService = CartService(); // Sepet servisi

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapmanız gerekiyor.')),
      );
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Favori ürün bulunamadı.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favoriteIds = List<String>.from(data['favorites'] ?? []);

          if (favoriteIds.isEmpty) {
            return const Center(child: Text('Henüz favori ürününüz yok.'));
          }

          final limitedFavorites =
              favoriteIds.length > 10
                  ? favoriteIds.sublist(0, 10)
                  : favoriteIds;

          return FutureBuilder<QuerySnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('products')
                    .where(FieldPath.documentId, whereIn: limitedFavorites)
                    .get(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!productSnapshot.hasData ||
                  productSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Favori ürün bulunamadı.'));
              }

              final products = productSnapshot.data!.docs;

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final productDoc = products[index];
                  final product = productDoc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading:
                          product['image_url'] != null
                              ? Image.network(
                                product['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.local_florist, size: 50),
                      title: Text(product['name'] ?? ''),
                      subtitle: Text('${product['price']} ₺'),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Bu satır taşmayı engeller
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _favoritesService.removeFromFavorites(
                                productDoc.id,
                              );
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              await _cartService.addToCart(
                                productId: productDoc.id,
                                productData: product,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ürün sepete eklendi'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
