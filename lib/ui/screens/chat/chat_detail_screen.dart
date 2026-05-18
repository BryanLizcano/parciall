import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  static const routeName = '/chat-detail';

  // TODO: recibir partnerId (int) cuando se implemente GetChatHistoryUseCase
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: mostrar nombre real del partner
                Text('Usuario', style: TextStyle(fontSize: 16)),
                Text('Emprendedor', style: TextStyle(fontSize: 12)),
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
                _MessageBubble(
                    message: 'Hola, me interesa tu servicio.', isMe: true),
                SizedBox(height: 12),
                _MessageBubble(
                    message: '¡Hola! Claro, cuéntame qué necesitas.',
                    isMe: false),
                SizedBox(height: 12),
                _MessageBubble(
                    message:
                    'Quiero una propuesta visual para mi emprendimiento.',
                    isMe: true),
                SizedBox(height: 12),
                _MessageBubble(
                    message:
                    'Perfecto, te comparto referencias y una cotización.',
                    isMe: false),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration:
                      InputDecoration(hintText: 'Escribe un mensaje...'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // TODO: llamar SendMessageUseCase al presionar
                  IconButton.filled(
                      onPressed: () {}, icon: const Icon(Icons.send)),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message,
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black87)),
      ),
    );
  }
}