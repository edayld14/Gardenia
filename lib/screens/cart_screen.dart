import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _discountCodeController = TextEditingController();

  String? _discountCode;
  double? _discountPercent;
  String? _discountError;

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    final cartRef = firestore
        .collection('carts')
        .doc(user!.uid)
        .collection('items');

    if (newQuantity <= 0) {
      await cartRef.doc(docId).delete();
    } else {
      await cartRef.doc(docId).update({'quantity': newQuantity});
    }
  }

  Future<void> _applyDiscountCode() async {
    final code = _discountCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _discountError = 'Lütfen bir indirim kodu girin.';
        _discountPercent = null;
        _discountCode = null;
      });
      return;
    }

    try {
      final querySnapshot =
          await firestore
              .collection('discountCodes')
              .where('name', isEqualTo: code)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final percent = (data['percent'] as num?)?.toDouble();

        if (percent != null && percent > 0 && percent <= 100) {
          setState(() {
            _discountPercent = percent;
            _discountCode = code;
            _discountError = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('%$percent indirim uygulandı.')),
          );
        } else {
          setState(() {
            _discountError = 'Geçersiz indirim oranı.';
            _discountPercent = null;
            _discountCode = null;
          });
        }
      } else {
        setState(() {
          _discountError = 'Bu indirim kodu geçersiz.';
          _discountPercent = null;
          _discountCode = null;
        });
      }
    } catch (e) {
      setState(() {
        _discountError = 'İndirim kodu doğrulanırken hata oluştu.';
        _discountPercent = null;
        _discountCode = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapmanız gerekiyor.')),
      );
    }

    final cartRef = firestore
        .collection('carts')
        .doc(user!.uid)
        .collection('items');

    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartDocs = snapshot.data?.docs ?? [];

          if (cartDocs.isEmpty) {
            return const Center(child: Text('Sepetiniz boş.'));
          }

          final cartItems =
              cartDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'productId': data['productId'],
                  'name': data['name'],
                  'price': (data['price'] as num?)?.toDouble() ?? 0.0,
                  'quantity': (data['quantity'] as num?)?.toInt() ?? 0,
                };
              }).toList();

          final double total = cartItems.fold(
            0,
            (sum, item) => sum + (item['price'] * item['quantity']),
          );

          final double discountedTotal =
              _discountPercent != null
                  ? total * (1 - _discountPercent! / 100)
                  : total;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Dismissible(
                      key: Key(item['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await cartRef.doc(item['id']).delete();
                      },
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                final currentQty = item['quantity'] as int;
                                if (currentQty > 1) {
                                  _updateQuantity(item['id'], currentQty - 1);
                                } else {
                                  _updateQuantity(item['id'], 0);
                                }
                              },
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                final currentQty = item['quantity'] as int;
                                _updateQuantity(item['id'], currentQty + 1);
                              },
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${(item['price'] * item['quantity']).toStringAsFixed(2)} ₺',
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountCodeController,
                        decoration: InputDecoration(
                          labelText: 'İndirim Kodu',
                          errorText: _discountError,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _applyDiscountCode,
                      child: const Text('Uygula'),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toplam: ${total.toStringAsFixed(2)} ₺',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_discountPercent != null)
                          Text(
                            '- %${_discountPercent!.toStringAsFixed(0)} indirim',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ödenecek:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${discountedTotal.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(cartItems: cartItems),
                    ),
                  );
                },
                child: const Text('Sipariş Ver'),
              ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
