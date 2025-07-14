import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'favorites': FieldValue.arrayUnion([productId]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.update({
      'favorites': FieldValue.arrayRemove([productId]),
    });
  }

  Future<List<String>> getFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) return [];

    final data = userDoc.data();
    final favorites = data?['favorites'] as List<dynamic>? ?? [];

    return List<String>.from(favorites);
  }

  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }
}
