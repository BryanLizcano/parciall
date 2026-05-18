import 'package:flutter/material.dart';

import '../../data/mock_data.dart';

class ChatDetailScreen extends StatelessWidget {
  static const routeName = '/chat-detail';

  final MockChat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(chat.avatarUrl)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.name, style: const TextStyle(fontSize: 16)),
                Text(chat.role, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _MessageBubble(message: 'Hola, me interesa tu servicio.', isMe: true),
                SizedBox(height: 12),
                _MessageBubble(message: '¡Hola! Claro, cuéntame qué necesitas.', isMe: false),
                SizedBox(height: 12),
                _MessageBubble(message: 'Quiero una propuesta visual para mi emprendimiento.', isMe: true),
                SizedBox(height: 12),
                _MessageBubble(message: 'Perfecto, te comparto referencias y una cotización.', isMe: false),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Escribe un mensaje...'))),
                  const SizedBox(width: 10),
                  IconButton.filled(onPressed: () {}, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
      ),
    );
  }
}
