import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm ürünleri stream olarak getirir
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Yeni ürün ekleme
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  // Ürün güncelleme
  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  // Ürün silme
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Stok azaltma işlemi
  Future<void> reduceStock(String productId, int quantity) async {
    final productDoc = _firestore.collection('products').doc(productId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(productDoc);
      if (!snapshot.exists) {
        throw Exception("Ürün bulunamadı!");
      }

      final currentStock = snapshot.get('stock') as int? ?? 0;

      if (currentStock < quantity) {
        throw Exception("Yeterli stok yok!");
      }

      transaction.update(productDoc, {'stock': currentStock - quantity});
    });
  }
}
