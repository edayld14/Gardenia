import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'my_orders_screen.dart';
import 'main_screen.dart'; // Anasayfa ekranını eklemeyi unutma

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> items;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.address,
    required this.phone,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        'pk_test_51RTrvuQNnHdMx6w4lgYWYysmQr7jantxJZKFoQSmkiGAnHNfUOneDM1Y3V89HMwAeclzAJJvAnhoxYVDsdOxu46p00ZAaNslui';
  }

  Future<void> _placeOrder(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen giriş yapınız.')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/your_backend/create-payment-intent.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': widget.amount}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ödeme intent oluşturulamadı: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Gardenia',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'email': user.email ?? '',
        'name': widget.name,
        'address': widget.address,
        'phone': widget.phone,
        'items': widget.items,
        'total': widget.amount / 100,
        'status': 'Ödendi',
        'paymentMethod': 'Kart ile Ödeme',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarılı! Siparişiniz alınmıştır.'),
        ),
      );

      // Burada anasayfaya yönlendirme yapılıyor:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ), // Anasayfa ekranını buraya koy
        (route) => false,
      );
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ödeme iptal edildi.')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalText = (widget.amount / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: const Text('Kart ile Ödeme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lütfen ödeme işlemini aşağıdaki butona tıklayarak tamamlayınız.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Ad: ${widget.name}'),
            Text('Telefon: ${widget.phone}'),
            Text('Adres: ${widget.address}'),
            const SizedBox(height: 24),
            Text(
              'Tutar: $totalText ₺',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            Center(
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                        icon: const Icon(Icons.lock),
                        onPressed: () => _placeOrder(context),
                        label: Text('Ödemeyi Tamamla ($totalText ₺)'),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
