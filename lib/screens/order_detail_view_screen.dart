import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailViewScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailViewScreen({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': 'İptal Edildi'},
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sipariş iptal edildi.")));

      Navigator.pop(context); // Sipariş listesine geri dön
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("İptal edilemedi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // items'ı güvenli şekilde alıyoruz
    final rawItems = orderData['items'] as List<dynamic>? ?? [];
    final items =
        rawItems
            .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();

    final total = orderData['total'] ?? 0;
    final status = orderData['status'] ?? '';
    final name = orderData['name'] ?? '';
    final address = orderData['address'] ?? '';
    final phone = orderData['phone'] ?? '';

    final canCancel = status == 'Hazırlanıyor';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sipariş Detayı"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sipariş Durumu: $status",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Ad: $name"),
            Text("Telefon: $phone"),
            Text("Adres: $address"),
            const Divider(height: 30),
            const Text(
              "Ürünler:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final quantity = item['quantity']?.toString() ?? '0';
                  final price = item['price']?.toString() ?? '0';
                  final itemName = item['name'] ?? 'Ürün';

                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text("Adet: $quantity"),
                    trailing: Text("$price ₺"),
                  );
                },
              ),
            ),
            const Divider(height: 30),
            Text(
              "Toplam Tutar: $total ₺",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (canCancel)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _cancelOrder(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Siparişi İptal Et"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
