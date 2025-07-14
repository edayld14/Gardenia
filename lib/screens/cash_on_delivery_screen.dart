import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart'; // Anasayfa importu

class CashOnDeliveryScreen extends StatelessWidget {
  final int amount; // Kuruş cinsinden toplam tutar
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> items;

  const CashOnDeliveryScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.address,
    required this.phone,
    required this.items,
  });

  Future<void> _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı giriş yapmamış. Lütfen giriş yapınız.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'email': user.email ?? '',
        'name': name,
        'address': address,
        'phone': phone,
        'items': items,
        'total': amount / 100,
        'status': 'Hazırlanıyor',
        'paymentMethod': 'Kapıda Ödeme',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sipariş alındı. Kapıda ödeme ile tamamlandı."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sipariş kaydedilemedi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalText = (amount / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: const Text("Kapıda Ödeme")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Siparişiniz teslimat sırasında kapıda ödeme yöntemiyle alınacaktır.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Tutar: $totalText ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              "Lütfen teslimat sırasında nakit veya POS cihazı ile ödeme yapmaya hazır olun.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _placeOrder(context),
                child: const Text("Siparişi Onayla"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
