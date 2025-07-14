import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gardenia/services/firestore_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService firestoreService = FirestoreService();

  bool _isLoading = true;
  bool _isFavorite = false;
  double _userRating = 0;
  double _averageRating = 0;
  int _ratingCount = 0;
  List<Map<String, dynamic>> _comments = [];

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final favIds = await firestoreService.getFavoriteIds();
      bool fav = favIds.contains(widget.product.id);

      final ratingData = await firestoreService.getProductRating(
        widget.product.id,
      );
      final comments = await firestoreService.getProductComments(
        widget.product.id,
      );

      setState(() {
        _isFavorite = fav;
        _averageRating = ratingData['average'] ?? 0;
        _ratingCount = ratingData['count'] ?? 0;
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
      );
    }
  }

  void _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await firestoreService.removeFromFavorites(widget.product.id);
      } else {
        await firestoreService.addToFavorites(widget.product.id);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori güncellenirken hata oluştu: $e')),
      );
    }
  }

  void _addToCart() async {
    try {
      await firestoreService.addToCart(
        productId: widget.product.id,
        name: widget.product.name,
        price: widget.product.price,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.name} sepete eklendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepete eklenirken hata oluştu: $e')),
      );
    }
  }

  void _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty || _userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yorum ve puan giriniz')),
      );
      return;
    }

    try {
      await firestoreService.addProductComment(
        productId: widget.product.id,
        comment: commentText,
        rating: _userRating,
      );

      final ratingData = await firestoreService.getProductRating(
        widget.product.id,
      );
      final comments = await firestoreService.getProductComments(
        widget.product.id,
      );

      setState(() {
        _averageRating = ratingData['average'] ?? 0;
        _ratingCount = ratingData['count'] ?? 0;
        _comments = comments;
        _commentController.clear();
        _userRating = 0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yorumunuz kaydedildi')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum kaydedilirken hata oluştu: $e')),
      );
    }
  }

  Widget _buildStarRating(
    double rating, {
    bool interactive = false,
    void Function(double)? onRatingChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        Icon icon;
        if (starIndex <= rating) {
          icon = const Icon(Icons.star, color: Colors.amber);
        } else if (starIndex - rating < 1) {
          icon = const Icon(Icons.star_border, color: Colors.amber);
        } else {
          icon = const Icon(Icons.star_border, color: Colors.amber);
        }

        return IconButton(
          icon: icon,
          onPressed:
              interactive
                  ? () => onRatingChanged?.call(starIndex.toDouble())
                  : null,
          iconSize: 30,
          splashRadius: interactive ? 20 : null,
          padding: const EdgeInsets.all(0),
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.product.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : Colors.white,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.imageurl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    p.imageurl,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            Text(
              p.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kategori: ${p.category ?? "Bilinmeyen"}'),
            const SizedBox(height: 8),
            Text(
              '${p.price.toStringAsFixed(2)} ₺',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                if (_ratingCount > 0) _buildStarRating(_averageRating),
                if (_ratingCount > 0) const SizedBox(width: 8),
                Text(
                  _ratingCount > 0
                      ? '($_ratingCount değerlendirme)'
                      : 'Henüz değerlendirme yok',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                child: const Text('Sepete Ekle'),
              ),
            ),

            const Divider(height: 32),

            const Text(
              'Yorum Yap & Puanla',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildStarRating(
              _userRating,
              interactive: true,
              onRatingChanged: (val) {
                setState(() {
                  _userRating = val;
                });
              },
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Yorumunuz',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitComment,
                child: const Text('Gönder'),
              ),
            ),

            const Divider(height: 32),

            const Text(
              'Yorumlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_comments.isEmpty)
              const Text('Henüz yorum yok.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final commentRating = (comment['rating'] ?? 0).toDouble();
                  final commentText = comment['comment'] ?? '';

                  DateTime? timestamp;
                  final rawTimestamp = comment['timestamp'];
                  if (rawTimestamp != null) {
                    if (rawTimestamp is Timestamp) {
                      timestamp = rawTimestamp.toDate();
                    } else if (rawTimestamp is DateTime) {
                      timestamp = rawTimestamp;
                    }
                  }

                  return ListTile(
                    leading: _buildStarRating(commentRating),
                    title: Text(commentText),
                    subtitle:
                        timestamp != null
                            ? Text('${timestamp.toLocal()}'.split(' ')[0])
                            : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
