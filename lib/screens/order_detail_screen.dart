import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_method_selection_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const OrderDetailScreen({super.key, required this.cartItems});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double _calculateTotalAmount(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as int?) ?? 1;
      total += price * quantity;
    }
    return total;
  }

  Future<void> _saveOrderToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final orderData = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'items': widget.cartItems,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Hazırlanıyor',
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      final totalAmount =
          (_calculateTotalAmount(widget.cartItems) * 100).toInt();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaymentMethodSelectionScreen(
                amount: totalAmount,
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
                phone: _phoneController.text.trim(),
                items: widget.cartItems,
              ),
        ),
      );
    } catch (e) {
      // Hata yönetimi (örneğin, kullanıcıya hata mesajı gösterebilirsin)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş kaydedilirken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teslimat Bilgileri')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adres'),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveOrderToFirestore,
                    child: const Text('Ödeme Yöntemi Seçim Sayfasına Geç'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
