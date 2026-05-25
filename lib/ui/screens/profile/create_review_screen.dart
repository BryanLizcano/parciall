// lib/ui/screens/profile/create_review_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/review_provider.dart';
import '../../theme/app_theme.dart';

/// Argumentos que deben pasarse via Navigator.pushNamed:
/// {'entrepreneurId': int, 'servicePostId': int, 'entrepreneurName': String}
class CreateReviewScreen extends StatefulWidget {
  static const routeName = '/create-review';

  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  // Extraídos de los arguments de la ruta
  late int _entrepreneurId;
  late int _servicePostId;
  late String _entrepreneurName;

  // Etiquetas descriptivas para cada nivel de estrella
  static const _ratingLabels = {
    1: 'Muy malo',
    2: 'Malo',
    3: 'Regular',
    4: 'Bueno',
    5: 'Excelente',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _entrepreneurId = args?['entrepreneurId'] as int? ?? 0;
    _servicePostId = args?['servicePostId'] as int? ?? 0;
    _entrepreneurName = args?['entrepreneurName'] as String? ?? 'Emprendedor';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una estrella para calificar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<ReviewProvider>();
    final success = await provider.createReview(
      entrepreneurId: _entrepreneurId,
      servicePostId: _servicePostId,
      rating: _selectedRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña enviada correctamente! Gracias por tu opinión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // devolvemos true para indicar éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al enviar la reseña.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSending = context.watch<ReviewProvider>().isSending;

    return Scaffold(
      appBar: AppBar(title: const Text('Calificar emprendedor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.storefront_outlined,
                        color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estás calificando a:',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _entrepreneurName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Selector de estrellas ─────────────────────────────────────
            Text('Tu calificación *',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Toca las estrellas para seleccionar',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),

            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      final isSelected = starNumber <= _selectedRating;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRating = starNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: isSelected ? 48 : 44,
                            color: isSelected
                                ? AppTheme.warning
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedRating > 0
                        ? Container(
                      key: ValueKey(_selectedRating),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                        AppTheme.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _ratingLabels[_selectedRating]!,
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    )
                        : const SizedBox(height: 34, key: ValueKey(0)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Comentario ────────────────────────────────────────────────
            Text('Comentario (opcional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Cuéntale a otros usuarios tu experiencia con este emprendedor.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Ej: Excelente atención, muy profesional...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón enviar ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isSending ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isSending
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Enviar reseña'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}