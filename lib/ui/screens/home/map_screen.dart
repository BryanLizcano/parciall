import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_nav.dart';

class MapScreen extends StatelessWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de servicios')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.map_outlined, size: 70),
                          SizedBox(height: 12),
                          Text('Contenedor visual del mapa'),
                        ],
                      ),
                    ),
                    const Positioned(top: 90, left: 80, child: _MapPin(label: 'Diseño')),
                    const Positioned(top: 210, right: 70, child: _MapPin(label: 'Tutorías')),
                    const Positioned(bottom: 100, left: 150, child: _MapPin(label: 'Soporte')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Row(
                children: [
                  Icon(Icons.place_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('Zona seleccionada: Bogotá · Servicios cercanos visibles')),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;

  const _MapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}
