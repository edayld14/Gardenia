import 'package:flutter/material.dart';
import 'products_ekle.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductService _productService = ProductService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ürün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Fiyat'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Resim URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final double? price = double.tryParse(
                  priceController.text.trim(),
                );
                final String? imageUrl =
                    imageUrlController.text.trim().isEmpty
                        ? null
                        : imageUrlController.text.trim();

                if (name.isEmpty || price == null) {
                  setState(() {
                    errorMessage = 'Lütfen geçerli bir isim ve fiyat girin.';
                  });
                  return;
                }

                try {
                  await _productService.addProduct(name, price, imageUrl);
                  Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    errorMessage = 'Ürün eklenirken hata oluştu: $e';
                  });
                }
              },
              child: const Text('Ekle'),
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
