import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet'), centerTitle: true),
      body: const Center(
        child: Text(
          'Sohbet ekranı yakında gelecek.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
