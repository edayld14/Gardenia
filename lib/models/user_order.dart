import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrder {
  final String id;
  final String name; // Sipariş veren kişi adı
  final String phone;
  final String email;
  final String address;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String status;
  final double total;
  final String userId;

  UserOrder({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt,
    required this.items,
    required this.status,
    required this.total,
    required this.userId,
  });

  factory UserOrder.fromFirestore(String id, Map<String, dynamic> data) {
    var itemsData = data['items'] as List<dynamic>? ?? [];

    List<OrderItem> items =
        itemsData.map((item) {
          return OrderItem.fromMap(item as Map<String, dynamic>);
        }).toList();

    return UserOrder(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      items: items,
      status: data['status'] ?? '',
      total: (data['total'] as num).toDouble(),
      userId: data['userId'] ?? '',
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] as num).toDouble(),
    );
  }
}
