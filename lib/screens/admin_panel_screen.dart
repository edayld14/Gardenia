import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenia/screens/login_screen.dart';
import 'package:gardenia/screens/add_discount_code_screen.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'add_edit_product_screen.dart';
import 'users_orders_screen.dart';
import 'admin_statistics_dashboard.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ProductService _productService = ProductService();
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildProductsTab(),
      UsersOrdersScreen(), // 🔁 const kaldırıldı
      DiscountCodeManagerScreen(), // 🔁 const kaldırıldı
      const AdminStatisticsDashboard(),
    ];
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Çıkış yaparken hata oluştu: $e')));
    }
  }

  Widget _buildProductsTab() {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text('Hiç ürün yok.'));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            final stockText =
                product.stock == null
                    ? 'Stok: Bilinmiyor'
                    : (product.stock! <= 0
                        ? 'Stok: Tükendi'
                        : 'Stok: ${product.stock}');

            final stockColor =
                product.stock == null
                    ? Colors.grey
                    : (product.stock! <= 0 ? Colors.red : Colors.black);

            return ListTile(
              leading:
                  product.imageurl.isNotEmpty
                      ? Image.network(
                        product.imageurl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      )
                      : const Icon(Icons.image_not_supported),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${product.price.toStringAsFixed(2)} ₺'),
                  Text(
                    stockText,
                    style: TextStyle(
                      color: stockColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Düzenle',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AddEditProductScreen(product: product),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Sil',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Silme Onayı'),
                              content: const Text(
                                'Bu ürünü silmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Evet'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _productService.deleteProduct(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ürün başarıyla silindi.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditProductScreen(),
                    ),
                  );
                },
                tooltip: 'Yeni Ürün Ekle',
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[700],
        showUnselectedLabels: true,
        onTap:
            (index) => setState(() {
              _currentIndex = index;
            }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Ürünler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'İndirim Kodları', // ✅ "Promosyonlar" yerine bu oldu
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'İstatistik',
          ),
        ],
      ),
    );
  }
}
