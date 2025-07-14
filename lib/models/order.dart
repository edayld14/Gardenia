import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // JSON decode için

class Order {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final double total;
  final String status;
  final String userId;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.total,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromFirestore(String id, Map<String, dynamic> data) {
    final itemsRaw = data['items'];

    List<Map<String, dynamic>> itemsList = [];

    if (itemsRaw is String) {
      // items string ise tek elemanlı listeye dönüştür
      itemsList = [
        {'name': itemsRaw},
      ];
    } else if (itemsRaw is List) {
      itemsList =
          itemsRaw.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>)
              return item;
            else
              return {};
          }).toList();
    }

    return Order(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'Beklemede',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      items: itemsList,
    );
  }
}
