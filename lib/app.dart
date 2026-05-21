import 'package:flutter/material.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/auth/welcome_screen.dart';
import 'ui/screens/chat/chat_detail_screen.dart';
import 'ui/screens/chat/chat_list_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/home/map_screen.dart';
import 'ui/screens/home/search_screen.dart';
import 'ui/screens/profile/edit_profile_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/screens/profile/reviews_screen.dart';
import 'ui/screens/services/create_service_screen.dart';
import 'ui/screens/services/my_services_screen.dart';
import 'ui/screens/services/service_detail_screen.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/theme/app_theme.dart';

class EmprendeApp extends StatelessWidget {
  const EmprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conecta Local',
      theme: AppTheme.lightTheme,
      initialRoute: SplashScreen.routeName, // '/' apunta al splash
      routes: {
        SplashScreen.routeName:       (_) => const SplashScreen(),
        WelcomeScreen.routeName:      (_) => const WelcomeScreen(),
        LoginScreen.routeName:        (_) => const LoginScreen(),
        RegisterScreen.routeName:     (_) => const RegisterScreen(),
        HomeScreen.routeName:         (_) => const HomeScreen(),
        SearchScreen.routeName:       (_) => const SearchScreen(),
        MapScreen.routeName:          (_) => const MapScreen(),
        ChatListScreen.routeName:     (_) => const ChatListScreen(),
        ProfileScreen.routeName:      (_) => const ProfileScreen(),
        EditProfileScreen.routeName:  (_) => const EditProfileScreen(),
        MyServicesScreen.routeName:   (_) => const MyServicesScreen(),
        CreateServiceScreen.routeName:(_) => const CreateServiceScreen(),
        ReviewsScreen.routeName:      (_) => const ReviewsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ServiceDetailScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const ServiceDetailScreen(),
          );
        }
        if (settings.name == ChatDetailScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const ChatDetailScreen(),
          );
        }
        return null;
      },
    );
  }
}