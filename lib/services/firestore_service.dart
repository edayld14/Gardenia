import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Favorilere ürün ekle
  Future<void> addToFavorites(String productId) async {
    if (userId == null) return;
    final userDoc = _db.collection('users').doc(userId);
    await userDoc.set({
      'favorites': FieldValue.arrayUnion([productId]),
    }, SetOptions(merge: true));
  }

  // Favorilerden ürün çıkar
  Future<void> removeFromFavorites(String productId) async {
    if (userId == null) return;
    final userDoc = _db.collection('users').doc(userId);
    await userDoc.set({
      'favorites': FieldValue.arrayRemove([productId]),
    }, SetOptions(merge: true));
  }

  // Favori ürün ID'lerini getir
  Future<List<String>> getFavoriteIds() async {
    if (userId == null) return [];
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['favorites'] ?? []);
  }

  // Sepete ürün ekle
  Future<void> addToCart({
    required String productId,
    required String name,
    required double price,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış");

    final cartRef = _db.collection('carts').doc(user.uid).collection('items');

    final existing =
        await cartRef.where('productId', isEqualTo: productId).get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = doc['quantity'] ?? 1;
      await doc.reference.update({'quantity': currentQty + 1});
    } else {
      await cartRef.add({
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': 1,
      });
    }
  }

  // Sepetteki ürünleri getir
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');

    final cartRef = _db.collection('carts').doc(user.uid).collection('items');
    final snap = await cartRef.get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'productId': data['productId'],
        'name': data['name'],
        'price': (data['price'] as num).toDouble(),
        'quantity': (data['quantity'] as num).toInt(),
      };
    }).toList();
  }

  // Sepeti temizle
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');

    final cartRef = _db.collection('carts').doc(user.uid).collection('items');
    final snap = await cartRef.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // Siparişi kaydet
  Future<void> placeOrder({
    required String name,
    required String address,
    required String phone,
    required String paymentMethod,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Kullanıcı giriş yapmamış');

    final cartItems = await getCartItems();

    final double total = cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

    final order = {
      'userId': currentUser.uid,
      'email': currentUser.email,
      'name': name,
      'address': address,
      'phone': phone,
      'payment': paymentMethod,
      'items': cartItems,
      'total': total,
      'createdAt': Timestamp.now(),
      'status': 'Hazırlanıyor',
    };

    await _db.collection('orders').add(order);

    await clearCart();
  }

  // Ürüne yorum ve puan ekle
  Future<void> addProductComment({
    required String productId,
    required String comment,
    required double rating,
  }) async {
    if (userId == null) throw Exception('Kullanıcı giriş yapmamış');

    final commentData = {
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final commentRef =
        _db.collection('products').doc(productId).collection('comments').doc();

    await commentRef.set(commentData);

    // Ortalama puanı güncelle
    await _updateProductAverageRating(productId);
  }

  // Ortalama puanı ve yorum sayısını güncelle
  Future<void> _updateProductAverageRating(String productId) async {
    final commentsSnap =
        await _db
            .collection('products')
            .doc(productId)
            .collection('comments')
            .get();

    final ratings =
        commentsSnap.docs
            .map((doc) => (doc.data()['rating'] ?? 0).toDouble())
            .where((rating) => rating > 0)
            .toList();

    if (ratings.isEmpty) {
      await _db.collection('products').doc(productId).set({
        'averageRating': 0.0,
        'ratingCount': 0,
      }, SetOptions(merge: true));
      return;
    }

    final average = ratings.reduce((a, b) => a + b) / ratings.length;

    await _db.collection('products').doc(productId).set({
      'averageRating': average,
      'ratingCount': ratings.length,
    }, SetOptions(merge: true));
  }

  // Ürün için ortalama puan ve yorum sayısı getir
  Future<Map<String, dynamic>> getProductRating(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) return {'average': 0.0, 'count': 0};

    final data = doc.data();
    return {
      'average': (data?['averageRating'] ?? 0.0).toDouble(),
      'count': (data?['ratingCount'] ?? 0),
    };
  }

  // Ürüne ait yorumları getir
  Future<List<Map<String, dynamic>>> getProductComments(
    String productId,
  ) async {
    final snap =
        await _db
            .collection('products')
            .doc(productId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': data['userId'],
        'comment': data['comment'],
        'rating': (data['rating'] ?? 0).toDouble(),
        'timestamp':
            data['timestamp'] != null
                ? (data['timestamp'] as Timestamp).toDate()
                : null,
      };
    }).toList();
  }
}
