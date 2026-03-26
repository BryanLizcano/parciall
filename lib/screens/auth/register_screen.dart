import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear cuenta', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              'Registro visual para cliente o emprendedor. Sin lógica de validación por ahora.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            const TextField(decoration: InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Correo electrónico')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Ubicación')),
            const SizedBox(height: 16),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                DropdownMenuItem(value: 'Emprendedor', child: Text('Emprendedor')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: 'Tipo de usuario'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, HomeScreen.routeName),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Continuar')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
