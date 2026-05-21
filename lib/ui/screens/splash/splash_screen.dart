import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _dotsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ).drive(Tween<double>(begin: 0.4, end: 1.0));
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ).drive(Tween<double>(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ).drive(Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ));

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Animaciones de entrada
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _dotsController.repeat();

    // Esperamos DOS cosas en paralelo:
    // 1. Un mínimo de 1.2 s para que la animación sea visible
    // 2. Que checkAuthStatus() haya terminado de leer el token del storage
    // Usamos Future.wait para que ambas corran a la vez y esperamos a la más lenta.
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1200)),
      context.read<AuthProvider>().checkAuthStatus(),
    ]);

    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final session = context.read<AuthProvider>().currentSession;
    final destination =
    session != null ? HomeScreen.routeName : WelcomeScreen.routeName;
    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con bounce + fade
            AnimatedBuilder(
              animation: _logoController,
              builder: (_, __) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 52,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Nombre + tagline con slide-up
            AnimatedBuilder(
              animation: _textController,
              builder: (_, __) => FractionalTranslation(
                translation: _textSlide.value,
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: const Column(
                    children: [
                      Text(
                        'Conecta Local',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Talento cerca de ti',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 64),

            // Tres puntos pulsantes
            AnimatedBuilder(
              animation: _dotsController,
              builder: (_, __) =>
                  _PulsingDots(progress: _dotsController.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  final double progress;
  const _PulsingDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final start = i / 3.0;
        final t = ((progress - start) / 0.33).clamp(0.0, 1.0);
        final brightness = t <= 0.5 ? t * 2 : (1.0 - t) * 2;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3 + brightness * 0.7),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}