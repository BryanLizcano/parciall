import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'injection.dart';
import 'application/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializamos GetIt
  await initInjection();

  // 2. Envolvemos la app con MultiProvider (preparándonos para futuros providers)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<AuthProvider>()..checkAuthStatus(), // Verificamos sesión al iniciar
        ),
      ],
      child: const EmprendeApp(),
    ),
  );
}