import 'package:flutter/material.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/custom_bottom_nav.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chat-list';
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        // TODO: cargar conversaciones reales con GetConversationsUseCase
        itemCount: 3,
        itemBuilder: (_, index) {
          // Datos temporales de ejemplo
          const names      = ['Laura Méndez', 'Andrés Rojas', 'Carlos Pérez'];
          const roles      = ['Diseñadora', 'Tutor', 'Soporte técnico'];
          const messages   = ['Te envío la propuesta esta tarde.', 'Tengo disponibilidad mañana.', 'Puedo ir a tu domicilio.'];
          const times      = ['2:30 PM', 'Ayer', 'Lun'];
          const unreads    = [true, false, false];

          return ChatTile(
            name:        names[index],
            role:        roles[index],
            lastMessage: messages[index],
            time:        times[index],
            unread:      unreads[index],
          );
        },
        separatorBuilder: (_, __) => const Divider(),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}