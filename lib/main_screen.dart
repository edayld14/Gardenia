import 'package:flutter/material.dart';
import 'package:gardenia/screens/home_screen.dart';
import 'package:gardenia/screens/favorites_screen.dart';
import 'package:gardenia/screens/cart_screen.dart';
import 'package:gardenia/screens/chat_screen.dart';
import 'package:gardenia/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Anasayfa
    FavoritesScreen(), // Favoriler
    CartScreen(), // Sepet
    ChatScreen(), // Sohbet
    ProfileScreen(), // Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sepet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Sohbet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
