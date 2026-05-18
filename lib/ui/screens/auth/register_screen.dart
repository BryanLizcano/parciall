import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../domain/model/role.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  Role _selectedRole = Role.client;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final provider = context.read<AuthProvider>();

    final success = await provider.register(
      _usernameController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
              'Únete a la plataforma para conectar con talento local.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            // NOTA: Quité los campos de Nombre y Ubicación porque HU-01 no los contempla en el DTO inicial.
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario (único)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Role>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(value: Role.client, child: Text('Cliente')),
                DropdownMenuItem(value: Role.entrepreneur, child: Text('Emprendedor')),
              ],
              onChanged: (role) {
                if (role != null) setState(() => _selectedRole = role);
              },
              decoration: const InputDecoration(labelText: 'Tipo de usuario'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _handleRegister,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}