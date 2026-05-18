import 'package:flutter/material.dart';
import '../screens/chat/chat_detail_screen.dart';

/// Widget de ítem de conversación en la bandeja de chats.
/// TODO: recibir Conversation del dominio cuando se implementen los repositorios.
class ChatTile extends StatelessWidget {
  // Datos temporales — se reemplazarán por Conversation cuando el repo esté listo
  final String name;
  final String role;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool unread;

  const ChatTile({
    super.key,
    this.name        = 'Usuario',
    this.role        = 'Emprendedor',
    this.avatarUrl   = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    this.lastMessage = 'Último mensaje',
    this.time        = '--',
    this.unread      = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () =>
          Navigator.pushNamed(context, ChatDetailScreen.routeName),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: avatarUrl.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(role),
          const SizedBox(height: 4),
          Text(lastMessage,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time),
          const SizedBox(height: 8),
          if (unread)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}