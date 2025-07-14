import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import 'admin_panel_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      User? user = userCredential.user;

      if (user == null) throw Exception("Giriş başarısız.");

      if (!user.emailVerified) {
        setState(() {
          _errorMessage =
              'E-posta adresiniz doğrulanmamış. Lütfen mailinizi kontrol edin.';
        });
        await FirebaseAuth.instance.signOut();
        return;
      }

      // Firestore'dan kullanıcının admin olup olmadığını kontrol et
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists && userDoc['isAdmin'] == true) {
        // Admin paneline yönlendir
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
        );
      } else {
        // Normal kullanıcı ana ekrana yönlendir
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
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

  Future<void> _resetPassword() async {
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen şifre sıfırlama için e-posta girin.'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama maili gönderildi. Lütfen e-postanızı kontrol edin.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Hata oluştu')));
    }
  }

  // İsteğe bağlı: Şifre ile admin girişi (manuel override)
  void _showAdminLoginDialog() {
    final TextEditingController _adminPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Admin Girişi'),
            content: TextField(
              controller: _adminPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Admin Şifresi',
                hintText: 'Şifre girin',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  const adminPassword = '123456'; // Manuel override
                  if (_adminPasswordController.text.trim() == adminPassword) {
                    Navigator.pop(context); // dialog kapat
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPanelScreen(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hatalı admin şifresi')),
                    );
                  }
                },
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value == null || !value.contains('@')
                            ? 'Geçerli e-posta girin'
                            : null,
                onChanged: (value) => _email = value.trim(),
                onSaved: (value) => _email = value!.trim(),
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
                    child: const Text('Giriş Yap'),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Hesabınız yok mu? Kayıt Ol'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Şifremi Unuttum?'),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showAdminLoginDialog,
                child: const Text('🔐 Admin Girişi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
