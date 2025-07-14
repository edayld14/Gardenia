import 'package:flutter/material.dart';
import 'bank_transfer_screen.dart';
import 'cash_on_delivery_screen.dart';
import 'paymet_screen.dart'; // Kart ile ödeme ekranı

class PaymentMethodSelectionScreen extends StatelessWidget {
  final int amount; // Kuruş cinsinden toplam tutar
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> items; // Sepet ürünleri

  const PaymentMethodSelectionScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.address,
    required this.phone,
    required this.items,
  });

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme Yöntemi Seçin")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.credit_card),
              label: const Text("Kart ile Ödeme"),
              onPressed:
                  () => _navigateTo(
                    context,
                    PaymentScreen(
                      amount: amount,
                      name: name,
                      address: address,
                      phone: phone,
                      items: items,
                    ),
                  ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance),
              label: const Text("Havale/EFT ile Ödeme"),
              onPressed:
                  () => _navigateTo(
                    context,
                    BankTransferScreen(
                      amount: amount,
                      name: name,
                      address: address,
                      phone: phone,
                      items: items,
                    ),
                  ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.delivery_dining),
              label: const Text("Kapıda Ödeme"),
              onPressed:
                  () => _navigateTo(
                    context,
                    CashOnDeliveryScreen(
                      amount: amount,
                      name: name,
                      address: address,
                      phone: phone,
                      items: items,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
