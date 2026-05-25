import 'package:flutter/material.dart';
import 'package:parcial/application/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'application/providers/user_provider.dart';
import 'injection.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/image_provider.dart' as image;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initInjection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<AuthProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<UserProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<image.ImageProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<ChatProvider>(),
        ),
      ],
      child: const EmprendeApp(),
    ),
  );
}
