import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_order.dart';

class UserOrderService {
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  Stream<List<UserOrder>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserOrder.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _ordersCollection.doc(orderId).update({'status': newStatus});
  }

  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, "İptal Edildi");
  }
}
