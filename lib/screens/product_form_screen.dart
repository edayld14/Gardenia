import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late String _name;
  late double _price;
  late String _imageUrl;
  late String _category;
  int? _stock; // Yeni alan: Stok

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _price = widget.product?.price ?? 0.0;
    _imageUrl = widget.product?.imageurl ?? '';
    _category = widget.product?.category ?? '';
    _stock = widget.product?.stock; // null olabilir
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final product = Product(
      id: widget.product?.id ?? '',
      name: _name,
      price: _price,
      imageurl: _imageUrl,
      category: _category.isNotEmpty ? _category : null,
      stock: _stock,
    );

    try {
      if (widget.product == null) {
        await _productService.addProduct(product);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ürün başarıyla eklendi')));
      } else {
        await _productService.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla güncellendi')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ürünü Güncelle' : 'Yeni Ürün Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Boş bırakılamaz'
                            : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _price != 0.0 ? _price.toString() : '',
                decoration: const InputDecoration(labelText: 'Fiyat (₺)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Geçerli bir fiyat girin';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: 'Görsel URL'),
                onSaved: (value) => _imageUrl = value ?? '',
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                onSaved: (value) => _category = value ?? '',
              ),
              TextFormField(
                initialValue: _stock?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Stok (Adet)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final stockVal = int.tryParse(value);
                    if (stockVal == null || stockVal < 0) {
                      return 'Geçerli bir stok miktarı girin';
                    }
                  }
                  return null;
                },
                onSaved:
                    (value) =>
                        _stock =
                            value != null && value.isNotEmpty
                                ? int.parse(value)
                                : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(isEditing ? 'Güncelle' : 'Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
