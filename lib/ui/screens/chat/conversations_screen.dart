// lib/ui/screens/chat/conversations_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/chat_provider.dart';
import '../../widgets/chat_tile.dart';
import 'chat_room_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    // HU-16: Cargar la lista de conversaciones al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mensajes'),
        centerTitle: true,
      ),
      body: chatProvider.isLoadingConversations
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes conversaciones activas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => chatProvider.loadConversations(),
                  child: ListView.builder(
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = chatProvider.conversations[index];

                      // Usamos tu widget personalizado 'ChatTile' pasándole la acción de navegación
                      return ChatTile(
                        conversation: conversation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                partnerId: conversation.partnerId,
                                partnerName: conversation.partnerName,
                              ),
                            ),
                          ).then((_) {
                            // Al regresar a la lista, refrescamos para actualizar contadores de no leídos
                            context.read<ChatProvider>().loadConversations();
                          });
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
