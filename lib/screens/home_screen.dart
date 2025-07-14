import 'package:flutter/material.dart';
import 'package:gardenia/services/firestore_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final ProductService productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Set<String> _categories = {}; // Kategori listesi
  String _selectedCategory = 'Tümü';
  Set<String> _favoriteProductIds = {}; // Favoriler

  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    // Favorileri Firestore’dan çek
    firestoreService.getFavoriteIds().then((ids) {
      setState(() {
        _favoriteProductIds = ids.toSet();
      });
    });

    // Ürünleri dinle ve kategorileri ayarla
    productService.getProducts().listen((products) {
      final categories = {
        'Tümü',
        ...products.map((p) => p.category ?? 'Bilinmeyen'),
      };
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _categories = categories.toSet();
        _isLoading = false;
      });
    });
  }

  void _filterProducts(String query) {
    final filtered =
        _allProducts.where((product) {
          final nameLower = product.name.toLowerCase();
          final queryLower = query.toLowerCase();
          final matchesSearch = nameLower.contains(queryLower);
          final matchesCategory =
              _selectedCategory == 'Tümü' ||
              (product.category ?? 'Bilinmeyen') == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

    setState(() {
      _searchText = query;
      _filteredProducts = filtered;
    });
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory == null) return;
    final filtered =
        _allProducts.where((product) {
          final matchesCategory =
              newCategory == 'Tümü' ||
              (product.category ?? 'Bilinmeyen') == newCategory;
          final matchesSearch = product.name.toLowerCase().contains(
            _searchText.toLowerCase(),
          );
          return matchesSearch && matchesCategory;
        }).toList();

    setState(() {
      _selectedCategory = newCategory;
      _filteredProducts = filtered;
    });
  }

  void _toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      await firestoreService.removeFromFavorites(productId);
      setState(() {
        _favoriteProductIds.remove(productId);
      });
    } else {
      await firestoreService.addToFavorites(productId);
      setState(() {
        _favoriteProductIds.add(productId);
      });
    }
  }

  void _navigateToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gardenia - Anasayfa')),
      body: Column(
        children: [
          // Arama ve kategori seçici
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Ürün Ara',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _filterProducts,
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  onChanged: _onCategoryChanged,
                  items:
                      _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          // Ürün listesi
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? const Center(child: Text('Ürün bulunamadı.'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isFavorite = _favoriteProductIds.contains(
                          product.id,
                        );

                        return GestureDetector(
                          onTap: () => _navigateToDetail(product),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child:
                                            product.imageurl.isNotEmpty
                                                ? Image.network(
                                                  product.imageurl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.broken_image,
                                                      size: 60,
                                                    );
                                                  },
                                                )
                                                : const Icon(
                                                  Icons.image_not_supported,
                                                  size: 60,
                                                ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFavorite
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                          onPressed:
                                              () => _toggleFavorite(product.id),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${product.price.toStringAsFixed(2)} ₺",
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              await firestoreService.addToCart(
                                                productId: product.id,
                                                name: product.name,
                                                price: product.price,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} sepete eklendi',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Sepete eklenirken hata: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Sepete Ekle'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
