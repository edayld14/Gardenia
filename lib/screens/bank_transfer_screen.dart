import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class BankTransferScreen extends StatelessWidget {
  final int amount;
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> items;

  const BankTransferScreen({
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen giriş yapınız.')));
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
        'status': 'Ödeme Bekleniyor',
        'paymentMethod': 'Havale/EFT',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sipariş alındı. Ödeme bekleniyor."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalText = (amount / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: const Text("Havale/EFT Bilgileri")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Lütfen aşağıdaki IBAN numarasına ödeme yapınız:"),
            const SizedBox(height: 12),
            const Text(
              "IBAN: TR12 3456 7890 1234 5678 9012 34",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Alıcı Adı: Gardenia Çiçekçilik"),
            const SizedBox(height: 16),
            Text(
              "Tutar: $totalText ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              "Lütfen ödeme dekontunu 'Profil > Destek' kısmından bize iletiniz.",
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
