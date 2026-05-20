import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'application/providers/user_provider.dart';
import 'injection.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/image_provider.dart' as image;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializamos GetIt
  await initInjection();

  // 2. Envolvemos la app con MultiProvider (preparándonos para futuros providers)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<AuthProvider>()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<UserProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<image.ImageProvider>(),
        ),
      ],
      child: const EmprendeApp(),
    ),
  );
}