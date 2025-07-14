import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

class OrderService {
  final _orderCollection = FirebaseFirestore.instance.collection('orders');

  Stream<List<Order>> getOrders() {
    return _orderCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Order.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderCollection.doc(orderId).update({'status': newStatus});
  }
}
