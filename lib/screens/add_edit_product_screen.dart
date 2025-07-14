import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../models/product.dart';
import '../services/product_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  String _name = '';
  double _price = 0.0;
  String? _category;
  String _imageUrl = '';
  int _stock = 0;

  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _price = widget.product!.price;
      _category = widget.product!.category;
      _imageUrl = widget.product!.imageurl;
      _stock = widget.product!.stock ?? 0;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path);
          _imageUrl = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken hata oluştu: $e')),
      );
    }
  }

  Future<String> _uploadImage(File file) async {
    final fileName = path.basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
      'product_images/$fileName',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrlToSave = _imageUrl;
      if (_imageFile != null) {
        imageUrlToSave = await _uploadImage(_imageFile!);
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _name,
        price: _price,
        imageurl: imageUrlToSave,
        category: _category,
        stock: _stock,
      );

      if (widget.product == null) {
        await _productService.addProduct(product);
      } else {
        await _productService.updateProduct(product);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Ürün başarıyla eklendi'
                : 'Ürün başarıyla güncellendi',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Yeni Ürün Ekle' : 'Ürünü Düzenle',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child:
                      _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : _imageUrl.isNotEmpty
                          ? Image.network(_imageUrl, fit: BoxFit.cover)
                          : const Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Colors.grey,
                          ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Resim Seç'),
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Ürün adı girin'
                            : null,
                onSaved: (value) => _name = value!.trim(),
              ),
              TextFormField(
                initialValue: _price == 0.0 ? '' : _price.toString(),
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Fiyat girin';
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) return 'Geçerli fiyat girin';
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: const InputDecoration(labelText: 'Stok Miktarı'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Stok miktarı girin';
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) return 'Geçerli stok girin';
                  return null;
                },
                onSaved: (value) => _stock = int.parse(value!),
              ),
              TextFormField(
                initialValue: _category ?? '',
                decoration: const InputDecoration(labelText: 'Kategori'),
                onSaved: (value) {
                  final val = value?.trim();
                  _category = (val == null || val.isEmpty) ? null : val;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(widget.product == null ? 'Ekle' : 'Güncelle'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
