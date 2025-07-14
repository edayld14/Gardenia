import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  Future<void> addProduct(String name, double price, String? imageUrl) {
    return products.add({
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(String docId, Map<String, dynamic> data) {
    return products.doc(docId).update(data);
  }

  Future<void> deleteProduct(String docId) {
    return products.doc(docId).delete();
  }
}
