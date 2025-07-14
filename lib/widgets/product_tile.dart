import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class ProductTile extends StatefulWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;

  const ProductTile({
    super.key,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  final FavoritesService _favoritesService = FavoritesService();
  bool isFavorited = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await _favoritesService.isFavorite(widget.productId);
    setState(() {
      isFavorited = fav;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(),
      );

    return ListTile(
      leading:
          widget.imageUrl.isNotEmpty
              ? Image.network(
                widget.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
              : const Icon(Icons.local_florist),
      title: Text(widget.name),
      subtitle: Text('${widget.price} ₺'),
      trailing: IconButton(
        icon: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () async {
          if (isFavorited) {
            await _favoritesService.removeFromFavorites(widget.productId);
          } else {
            await _favoritesService.addToFavorites(widget.productId);
          }
          setState(() {
            isFavorited = !isFavorited;
          });
        },
      ),
    );
  }
}
