import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatelessWidget {
  final ProductService productService = ProductService();

  ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çiçekler')),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ürün bulunamadı.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading:
                    product.imageurl.isNotEmpty
                        ? Image.network(
                          product.imageurl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 60);
                          },
                        )
                        : const Icon(Icons.image_not_supported, size: 60),
                title: Text(product.name),
                subtitle: Text('${product.price.toStringAsFixed(2)} ₺'),
              );
            },
          );
        },
      ),
    );
  }
}
