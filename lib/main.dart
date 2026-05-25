import 'package:flutter/material.dart';
import 'package:parcial/application/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'application/providers/auth_provider.dart';
import 'application/providers/category_provider.dart';
import 'application/providers/image_provider.dart' as image;
import 'application/providers/service_provider.dart';
import 'application/providers/user_provider.dart';
import 'injection.dart';

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
<<<<<<< HEAD
        ChangeNotifierProvider(
          create: (_) => sl<ChatProvider>(),
=======
        // Singleton: el caché de categorías vive durante toda la sesión (HU-15 CA-1)
        ChangeNotifierProvider(
          create: (_) => sl<CategoryProvider>(),
        ),
        // Factory: se crea una instancia fresca; el Provider la gestiona
        ChangeNotifierProvider(
          create: (_) => sl<ServiceProvider>(),
>>>>>>> 08ca8d88840e97d7483c4410567c4263ca767c74
        ),
      ],
      child: const EmprendeApp(),
    ),
  );
}
