import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/map_screen.dart';
import 'screens/home/search_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/reviews_screen.dart';
import 'screens/services/create_service_screen.dart';
import 'screens/services/my_services_screen.dart';
import 'screens/services/service_detail_screen.dart';
import 'theme/app_theme.dart';

class EmprendeApp extends StatelessWidget {
  const EmprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conecta Local',
      theme: AppTheme.lightTheme,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        MapScreen.routeName: (_) => const MapScreen(),
        ChatListScreen.routeName: (_) => const ChatListScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        MyServicesScreen.routeName: (_) => const MyServicesScreen(),
        CreateServiceScreen.routeName: (_) => const CreateServiceScreen(),
        ReviewsScreen.routeName: (_) => const ReviewsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ServiceDetailScreen.routeName) {
          final service = settings.arguments as MockService? ?? mockServices.first;
          return MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          );
        }

        if (settings.name == ChatDetailScreen.routeName) {
          final chat = settings.arguments as MockChat? ?? mockChats.first;
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chat: chat),
          );
        }

        return null;
      },
    );
  }
}
