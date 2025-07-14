import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: true),
      body: const Center(
        child: Text(
          'Kullanıcı bilgileri burada görüntülenecek.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
