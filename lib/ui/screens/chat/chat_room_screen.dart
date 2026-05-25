// lib/ui/screens/chat/chat_room_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/chat_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final int partnerId;
  final String partnerName;

  const ChatRoomScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // HU-17: Cargar historial y limpiar notificaciones de no leído en el backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.loadChatHistory(widget.partnerId);
      chatProvider.markMessagesAsRead(widget.partnerId);
    });
  }

  void _onSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await context.read<ChatProvider>().sendNewMessage(
            receiverId: widget.partnerId,
            content: text,
          );
      _messageController.clear();

      // Auto-scrollear al inicio del listado (abajo de la pantalla) al enviar
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el mensaje: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
      ),
      body: Column(
        children: [
          // Área del historial de mensajes
          Expanded(
            child: chatProvider.isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.messages.isEmpty
                    ? const Center(
                        child: Text(
                            'Escribe tu primer mensaje para iniciar el chat.'))
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Crucial para aplicaciones de chat
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          final isMe = message.isMine;

                          // En lib/ui/screens/chat/chat_room_screen.dart

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              // 1. ELIMINA 'maxWidth' de aquí arriba
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),

                              // 2. AÑADE ESTA LÍNEA para aplicar el ancho máximo de forma correcta:
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),

                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Caja de texto inferior para enviar el mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _onSendMessage(),
                    ),
                  ),
                  chatProvider.isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: _onSendMessage,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
