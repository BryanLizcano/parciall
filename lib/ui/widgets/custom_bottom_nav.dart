import 'package:flutter/material.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/map_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/profile/profile_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  CustomBottomNav({super.key, required this.currentIndex});

  final List<String> _routes = [
    HomeScreen.routeName,
    SearchScreen.routeName,
    MapScreen.routeName,
    ChatListScreen.routeName,
    ProfileScreen.routeName,
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE0E7FF),
      onDestinationSelected: (index) {
        // No navegamos si ya estamos en esa pantalla
        if (index == currentIndex) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
        NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
        NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        NavigationDestination(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
