import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Revisamos si ya hay sesión guardada (token en FlutterSecureStorage).
    // checkAuthStatus() ya se llamó en main.dart al crear el provider,
    // pero puede que todavía esté corriendo cuando se construye este widget.
    // Esperamos un frame y luego evaluamos.
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfLoggedIn());
  }

  void _redirectIfLoggedIn() {
    final session = context.read<AuthProvider>().currentSession;
    if (session != null && mounted) {
      // Ya hay token válido en storage → saltamos directo al home
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider: si checkAuthStatus() termina DESPUÉS de que
    // se construyó el widget (caso habitual en cold start), reaccionamos igual.
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.currentSession != null) {
      // Usamos addPostFrameCallback para no navegar durante build()
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Conecta con talento local',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'Explora servicios, conversa con emprendedores y descubre opciones cerca de ti.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, LoginScreen.routeName),
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Iniciar sesión')),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RegisterScreen.routeName),
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Crear cuenta')),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}