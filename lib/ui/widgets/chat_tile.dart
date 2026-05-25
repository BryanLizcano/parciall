// lib/ui/widgets/chat_tile.dart

import 'package:flutter/material.dart';
import '../../../domain/model/conversation.dart';

/// Widget de ítem de conversación real conectado al dominio.
class ChatTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback
      onTap; // Manejamos la navegación desde la pantalla principal

  const ChatTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  /// Helper para formatear la hora del último mensaje de forma amigable (HH:MM)
  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Si la foto es nula o vacía, usaremos un avatar por defecto
    final bool hasPhoto = conversation.partnerPhoto != null &&
        conversation.partnerPhoto!.isNotEmpty;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage:
            hasPhoto ? NetworkImage(conversation.partnerPhoto!) : null,
        onBackgroundImageError: hasPhoto ? (_, __) {} : null,
        child: !hasPhoto
            ? const Icon(Icons.person, size: 28, color: Colors.grey)
            : null,
      ),
      title: Text(
        conversation.partnerName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Muestra el último mensaje dinámico; si está vacío, pone un texto base
          Text(
            conversation.lastMessage.isNotEmpty
                ? conversation.lastMessage
                : 'No hay mensajes aún',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: conversation.unreadCount > 0
                  ? Colors.black87
                  : Colors.grey[600],
              fontWeight: conversation.unreadCount > 0
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.lastMessageAt),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 8),
          // HU-16: Si hay mensajes sin leer, pintamos el indicador con el contador exacto o el punto índigo
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              // Busca esta sección dentro de tu ChatTile:
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, //
              ),
            ),
        ],
      ),
    );
  }
}
