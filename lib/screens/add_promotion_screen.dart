import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddPromotionDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _discountController = TextEditingController();
    DateTime? _startDate;
    DateTime? _endDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Yeni İndirim Kodu Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Başlık'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Açıklama'),
                    ),
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'İndirim Oranı (%)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _startDate == null
                                ? 'Başlangıç Tarihi Seçilmedi'
                                : 'Başlangıç: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Seç'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _endDate == null
                                ? 'Bitiş Tarihi Seçilmedi'
                                : 'Bitiş: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Seç'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        _discountController.text.isEmpty ||
                        _startDate == null ||
                        _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen tüm alanları doldurun.'),
                        ),
                      );
                      return;
                    }

                    final discountValue = double.tryParse(
                      _discountController.text,
                    );
                    if (discountValue == null ||
                        discountValue < 0 ||
                        discountValue > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'İndirim oranı 0 ile 100 arasında olmalıdır.',
                          ),
                        ),
                      );
                      return;
                    }

                    await _firestore.collection('discountCodes').add({
                      'name': _titleController.text,
                      'percent': discountValue,
                      'startDate': Timestamp.fromDate(_startDate!),
                      'endDate': Timestamp.fromDate(_endDate!),
                      'createdAt': Timestamp.now(),
                    });

                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPromotionDialog(DocumentSnapshot promo) {
    final data = promo.data() as Map<String, dynamic>;
    final _titleController = TextEditingController(text: data['name']);
    final _discountController = TextEditingController(
      text: data['percent'].toString(),
    );
    DateTime? _startDate = (data['startDate'] as Timestamp).toDate();
    DateTime? _endDate = (data['endDate'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('İndirim Kodunu Güncelle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Başlık'),
                    ),
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'İndirim Oranı (%)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Başlangıç: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Seç'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: _startDate!,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bitiş: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Seç'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: _endDate!,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty ||
                        _discountController.text.isEmpty ||
                        _startDate == null ||
                        _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen tüm alanları doldurun.'),
                        ),
                      );
                      return;
                    }

                    final discountValue = double.tryParse(
                      _discountController.text,
                    );
                    if (discountValue == null ||
                        discountValue < 0 ||
                        discountValue > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'İndirim oranı 0 ile 100 arasında olmalıdır.',
                          ),
                        ),
                      );
                      return;
                    }

                    await _firestore
                        .collection('discountCodes')
                        .doc(promo.id)
                        .update({
                          'name': _titleController.text,
                          'percent': discountValue,
                          'startDate': Timestamp.fromDate(_startDate!),
                          'endDate': Timestamp.fromDate(_endDate!),
                        });

                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İndirim Kodları')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPromotionDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('discountCodes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz indirim kodu yok.'));
          }

          final promoDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: promoDocs.length,
            itemBuilder: (ctx, index) {
              final promo = promoDocs[index];
              final data = promo.data() as Map<String, dynamic>;
              final endDate = (data['endDate'] as Timestamp).toDate();
              final bool isExpired = endDate.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    data['name'] ?? 'Başlık yok',
                    style: TextStyle(
                      color: isExpired ? Colors.grey : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('İndirim: %${data['percent']}'),
                      const SizedBox(height: 4),
                      Text(
                        'Bitiş Tarihi: ${endDate.day}/${endDate.month}/${endDate.year}',
                        style: TextStyle(
                          color: isExpired ? Colors.red : Colors.black54,
                          fontWeight:
                              isExpired ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isExpired)
                        const Text(
                          '⚠️ İndirim süresi dolmuş',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditPromotionDialog(promo),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _firestore
                              .collection('discountCodes')
                              .doc(promo.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
