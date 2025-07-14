import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UpdateProfileScreen({super.key, required this.userData});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userData['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userData['lastName'] ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.userData['username'] ?? '',
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'username': _usernameController.text.trim(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil güncellendi')));
      Navigator.of(context).pop(true); // profil ekranına "güncellendi" bildir
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Güncelleme başarısız')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Bilgilerini Güncelle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_firstNameController, 'Ad', true),
              _buildTextField(_lastNameController, 'Soyad', true),
              _buildTextField(_usernameController, 'Kullanıcı Adı', true),
              const SizedBox(height: 16),
              _buildTextField(
                TextEditingController(text: widget.userData['email'] ?? ''),
                'E-posta',
                false,
              ),
              _buildTextField(
                TextEditingController(text: widget.userData['phone'] ?? ''),
                'Telefon',
                false,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool editable,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: !editable,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            editable && controller.text.isEmpty
                ? (value) => '$label boş olamaz'
                : null,
      ),
    );
  }
}
