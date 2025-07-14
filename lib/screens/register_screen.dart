import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _phone = '';
  String _password = '';

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Kullanıcı oluştur
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      User? user = userCredential.user;
      if (user == null) throw Exception("Kullanıcı oluşturulamadı.");

      // 2) Firestore'da users koleksiyonuna kullanıcı bilgilerini kaydet
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'username': _username,
        'email': _email,
        'phone': _phone,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3) E-posta doğrulama maili gönder
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kayıt başarılı! Lütfen e-posta adresinize gelen doğrulama mailini kontrol edin.',
          ),
        ),
      );

      // 4) Kayıt sonrası istersen giriş ekranına yönlendir
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Beklenmedik bir hata oluştu.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[300],
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ad'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Ad girin' : null,
                  onSaved: (value) => _firstName = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Soyad'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Soyad girin' : null,
                  onSaved: (value) => _lastName = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Kullanıcı adı girin'
                              : null,
                  onSaved: (value) => _username = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value == null || !value.contains('@')
                              ? 'Geçerli e-posta girin'
                              : null,
                  onSaved: (value) => _email = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Telefon Numarası',
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value == null || value.length < 10
                              ? 'Geçerli telefon girin'
                              : null,
                  onSaved: (value) => _phone = value!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator:
                      (value) =>
                          value == null || value.length < 6
                              ? 'En az 6 karakter şifre'
                              : null,
                  onSaved: (value) => _password = value!.trim(),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Kayıt Ol'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
