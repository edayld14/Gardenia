import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> addToCart({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .set({
          'name': productData['name'],
          'price': productData['price'],
          'image_url': productData['image_url'],
          'quantity': 1,
        });
  }
}
