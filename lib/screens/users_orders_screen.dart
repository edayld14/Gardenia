import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class UsersOrdersScreen extends StatelessWidget {
  UsersOrdersScreen({super.key});

  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siparişler')),
      body: StreamBuilder<List<Order>>(
        stream: _orderService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('Henüz sipariş bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final formattedDate = DateFormat(
                'dd.MM.yyyy HH:mm',
              ).format(order.createdAt);

              final statusOptions = [
                'Ödeme Bekleniyor',
                'Hazırlanıyor',
                'Kargoda',
                'Teslim Edildi',
              ];

              final isCurrentStatusInList = statusOptions.contains(
                order.status,
              );

              final dropdownItems = <DropdownMenuItem<String>>[
                if (!isCurrentStatusInList)
                  DropdownMenuItem(
                    value: order.status,
                    child: Text(order.status),
                  ),
                ...statusOptions.map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                ),
              ];

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ad: ${order.name}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Telefon: ${order.phone}"),
                      Text("E-posta: ${order.email}"),
                      Text("Adres: ${order.address}"),
                      Text("Tarih: $formattedDate"),
                      Text("Tutar: ₺${order.total.toStringAsFixed(2)}"),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Durum: ${order.status}"),
                          DropdownButton<String>(
                            value: order.status,
                            items: dropdownItems,
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                _orderService.updateOrderStatus(
                                  order.id,
                                  newStatus,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
