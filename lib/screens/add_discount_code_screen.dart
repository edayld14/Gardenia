import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCodeManagerScreen extends StatefulWidget {
  const DiscountCodeManagerScreen({Key? key}) : super(key: key);

  @override
  State<DiscountCodeManagerScreen> createState() =>
      _DiscountCodeManagerScreenState();
}

class _DiscountCodeManagerScreenState extends State<DiscountCodeManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _editingDocId; // Güncellenen doküman ID'si

  @override
  void dispose() {
    _codeController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> _submitDiscountCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String code = _codeController.text.trim();
    final double? percent = double.tryParse(_percentController.text.trim());

    if (percent == null || percent < 0 || percent > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İndirim oranı 0 ile 100 arasında olmalıdır.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (_editingDocId == null) {
        // Yeni indirim kodu ekle
        await _firestore.collection('discountCodes').add({
          'name': code,
          'percent': percent,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İndirim kodu başarıyla eklendi.')),
        );
      } else {
        // Var olan kodu güncelle
        await _firestore.collection('discountCodes').doc(_editingDocId).update({
          'name': code,
          'percent': percent,
          // İstersen createdAt güncellenmesin ya da güncellenebilir
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İndirim kodu başarıyla güncellendi.')),
        );
      }

      _codeController.clear();
      _percentController.clear();
      setState(() {
        _editingDocId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startEditing(DocumentSnapshot doc) {
    setState(() {
      _editingDocId = doc.id;
      _codeController.text = doc['name'] ?? '';
      _percentController.text = (doc['percent']?.toString() ?? '');
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingDocId = null;
      _codeController.clear();
      _percentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İndirim Kodları Yönetimi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form kısmı
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Kod Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kod adı boş olamaz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _percentController,
                    decoration: const InputDecoration(
                      labelText: 'İndirim Oranı (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final percent = double.tryParse(value ?? '');
                      if (percent == null || percent < 0 || percent > 100) {
                        return 'Geçerli bir indirim oranı girin (0-100).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitDiscountCode,
                              child: Text(
                                _editingDocId == null ? 'Ekle' : 'Güncelle',
                              ),
                            ),
                          ),
                          if (_editingDocId != null) ...[
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              onPressed: _cancelEditing,
                              child: const Text('İptal'),
                            ),
                          ],
                        ],
                      ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // İndirim kodları listesi
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('discountCodes')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Veri alınırken hata oluştu.'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(child: Text('Henüz indirim kodu yok.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(
                          'İndirim Oranı: %${data['percent'] ?? ''}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _startEditing(doc),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
