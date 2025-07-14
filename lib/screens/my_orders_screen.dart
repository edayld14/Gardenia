import 'package:flutter/material.dart';
import 'package:gardenia/models/user_order.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../services/user_order_service.dart';

class UsersOrdersScreen extends StatelessWidget {
  UsersOrdersScreen({Key? key}) : super(key: key);

  final UserOrderService _orderService = UserOrderService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Giriş yapılmamış.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Siparişlerim')),
      body: StreamBuilder<List<UserOrder>>(
        stream: _orderService.getUserOrders(currentUser.uid),

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
                      Text(
                        "Ürünler:",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...order.items.map(
                        (item) => Text(
                          "${item.name} - Adet: ${item.quantity}, Fiyat: ₺${item.price.toStringAsFixed(2)}",
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Durum: ${order.status}"),
                          ElevatedButton(
                            onPressed:
                                order.status == "İptal Edildi"
                                    ? null
                                    : () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                "Siparişi İptal Et",
                                              ),
                                              content: const Text(
                                                "Bu siparişi iptal etmek istediğinize emin misiniz?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                  child: const Text("Hayır"),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(true),
                                                  child: const Text("Evet"),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await _orderService.cancelOrder(
                                            order.id,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Sipariş iptal edildi.",
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "İptal işlemi başarısız: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            child: const Text("İptal Et"),
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
