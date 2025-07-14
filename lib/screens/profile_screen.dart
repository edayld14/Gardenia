import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_update_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<DocumentSnapshot> _userDataFuture;
  late TabController _tabController;

  final _supportFormKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    _userDataFuture = _firestore.collection('users').doc(user.uid).get();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _sendSupportMessage() async {
    if (_supportFormKey.currentState!.validate()) {
      final message = _messageController.text.trim();

      await _firestore.collection('support_messages').add({
        'userId': user.uid,
        'email': user.email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'new',
      });

      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesajınız gönderildi. Teşekkürler!')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Şifre Değiştir"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Eski Şifre"),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Eski şifre zorunlu'
                                : null,
                  ),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Yeni Şifre"),
                    validator:
                        (value) =>
                            (value == null || value.length < 6)
                                ? 'Yeni şifre en az 6 karakter olmalı'
                                : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final cred = EmailAuthProvider.credential(
                        email: user.email!,
                        password: oldPasswordController.text.trim(),
                      );

                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(
                        newPasswordController.text.trim(),
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Şifre başarıyla güncellendi."),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Şifre güncellenemedi: $e")),
                      );
                    }
                  }
                },
                child: const Text("Değiştir"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'İndirim Kodları & Kampanyalar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(), _buildDiscountCodesTab()],
      ),
    );
  }

  Widget _buildProfileTab() {
    return FutureBuilder<DocumentSnapshot>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Kullanıcı bilgisi bulunamadı.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildInfoRow('Ad:', userData['firstName'] ?? ''),
              _buildInfoRow('Soyad:', userData['lastName'] ?? ''),
              _buildInfoRow('Kullanıcı Adı:', userData['username'] ?? ''),
              _buildInfoRow('E-posta:', userData['email'] ?? ''),
              _buildInfoRow('Telefon:', userData['phone'] ?? ''),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateProfileScreen(userData: userData),
                      ),
                    );
                    if (updated == true) {
                      setState(() {
                        _loadUserData();
                      });
                    }
                  },
                  child: const Text('Bilgileri Güncelle'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UsersOrdersScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text("Siparişlerim"),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock),
                  label: const Text("Şifreyi Değiştir"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Destek',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Form(
                key: _supportFormKey,
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mesajınızı yazınız',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Mesaj zorunlu'
                              : null,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _sendSupportMessage,
                child: const Text('Gönder'),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış Yap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscountCodesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('discountCodes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Aktif indirim kodu bulunmamaktadır.'),
          );
        }

        final discountCodes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: discountCodes.length,
          itemBuilder: (context, index) {
            final data = discountCodes[index].data()! as Map<String, dynamic>;
            final code = data['name'] ?? '';
            final discountPercent = data['percent'] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.green),
                title: Text('İndirim Kodu: $code'),
                subtitle: Text('%$discountPercent indirim'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
