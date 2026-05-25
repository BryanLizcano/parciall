import '../model/chat_message.dart';
import '../model/conversation.dart';
import '../model/paged_result.dart';

abstract interface class ChatRepository {
  /// HU-16: lista de conversaciones del usuario autenticado.
  Future<List<Conversation>> getConversations();

  /// HU-17: envía un mensaje.
  Future<ChatMessage> sendMessage({
    required int receiverId,
    required String content,
  });

  /// HU-17: historial paginado con un partner.
  Future<PagedResult<ChatMessage>> getHistory({
    required int partnerId,
    int page = 0,
    int size = 30,
  });

  /// HU-17: marca mensajes de un partner como leídos.
  /// Devuelve el número de mensajes marcados.
  Future<int> markAsRead(int partnerId);
}
