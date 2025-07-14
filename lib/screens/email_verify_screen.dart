import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  final User user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _isEmailVerified = widget.user.emailVerified;

    if (!_isEmailVerified) {
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await widget.user.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      setState(() {
        _isEmailVerified = true;
      });
      _timer?.cancel();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();
      setState(() {
        _canResendEmail = false;
      });
      await Future.delayed(const Duration(seconds: 30));
      setState(() {
        _canResendEmail = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama maili gönderilemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isEmailVerified
        ? const Scaffold(body: Center(child: Text('Yönlendiriliyor...')))
        : Scaffold(
          appBar: AppBar(title: const Text('E-posta Doğrulama')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Lütfen e-posta adresinizi doğrulayın. Doğrulama linki gönderildi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _canResendEmail ? sendVerificationEmail : null,
                  child: const Text('Doğrulama Maili Yeniden Gönder'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          ),
        );
  }
}
