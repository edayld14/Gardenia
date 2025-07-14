import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String? _errorMessage;
  bool _isLoading = false;

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = FirebaseAuth.instance;

    try {
      if (_isLogin) {
        // Giriş yap
        await auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        // Kayıt ol
        await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        await auth.currentUser?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Doğrulama maili gönderildi. Lütfen e-postanı kontrol et.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu. Lütfen tekrar dene.';
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
      appBar: AppBar(title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol')),
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
                key: const ValueKey('email'),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !value.contains('@'))
                    return 'Geçerli email girin';
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              TextFormField(
                key: const ValueKey('password'),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Şifre'),
                validator: (value) {
                  if (value == null || value.length < 6)
                    return 'En az 6 karakterli şifre girin';
                  return null;
                },
                onSaved: (value) => _password = value!.trim(),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _trySubmit,
                  child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Hesabın yok mu? Kayıt ol'
                      : 'Zaten hesabın var mı? Giriş yap',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
