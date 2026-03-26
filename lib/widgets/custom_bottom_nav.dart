import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE0E7FF),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
        NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
