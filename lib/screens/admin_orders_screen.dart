import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:gardenia/models/order.dart';

/// Sadece sipariş listesini dönen widget (Scaffold içermez)
class AdminOrdersList extends StatelessWidget {
  const AdminOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders =
            snapshot.data!.docs.map((doc) {
              return Order.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            }).toList();

        if (orders.isEmpty) {
          return const Center(child: Text('Henüz sipariş yok.'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text(
                "${order.email} - ${order.total.toStringAsFixed(2)} ₺",
              ),
              subtitle: Text(order.status),
              trailing: Text(
                order.createdAt != null
                    ? "${order.createdAt!.day}/${order.createdAt!.month}"
                    : "Tarih yok",
              ),
            );
          },
        );
      },
    );
  }
}

/// İstersen bu ekranı tek başına kullanabilirsin
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gelen Siparişler")),
      body: const AdminOrdersList(),
    );
  }
}
