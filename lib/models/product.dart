class Product {
  final String id;
  final String name;
  final double price;
  final String imageurl;
  final String? category;
  final int? stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageurl,
    this.category,
    this.stock,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageurl: map['imageurl'] ?? '',
      category: map['category'],
      stock: map['stock'], // null olabilir
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageurl': imageurl,
      'category': category,
      'stock': stock,
    };
  }
}
