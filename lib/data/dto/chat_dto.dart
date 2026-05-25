import '../../domain/model/chat_message.dart';
import '../../domain/model/conversation.dart';
import '../../domain/model/paged_result.dart';

/// DTO para la solicitud de enviar un mensaje (HU-17)
class SendMessageRequestDto {
  final int receiverId;
  final String content;

  SendMessageRequestDto({
    required this.receiverId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'content': content,
    };
  }
}

/// DTO para mapear un mensaje individual desde el JSON del Backend (HU-17)
/// DTO para mapear un mensaje individual desde el JSON del Backend (HU-17)
class ChatMessageDto {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String timestamp;
  final bool isRead;

  ChatMessageDto({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      //Convierte de forma segura a int por si viene como String o null
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,

      senderId: json['senderId'] is int
          ? json['senderId'] as int
          : int.tryParse(json['senderId']?.toString() ?? '') ?? 0,

      receiverId: json['receiverId'] is int
          ? json['receiverId'] as int
          : int.tryParse(json['receiverId']?.toString() ?? '') ?? 0,

      //Si el contenido llega null por alguna razón, evitamos el crash usando un String vacío
      content: json['content']?.toString() ?? '',

      timestamp: json['timestamp']?.toString() ??
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(),

      isRead: json['isRead'] == true || json['isRead'] == 1,
    );
  }

  /// Mapeo directo al modelo de Dominio puro
  ChatMessage toDomain({int? currentUserId}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      isRead: isRead,
      sentAt: DateTime.tryParse(timestamp) ??
          DateTime.now(), // 🛡️ Parseo tolerante
      isMine: currentUserId != null ? (senderId == currentUserId) : false,
    );
  }
}

/// DTO para mapear el listado de conversaciones activas (HU-16)

class ConversationDto {
  final int id;
  final Map<String, dynamic> partner; // Contiene id, name, photo, etc.
  final ChatMessageDto? lastMessage;
  final int unreadCount;

  ConversationDto({
    required this.id,
    required this.partner,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'] as int,
      partner: json['partner'] as Map<String, dynamic>? ?? {},
      lastMessage: json['lastMessage'] != null
          ? ChatMessageDto.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Conversation toDomain() {
    // 1. Extraemos los datos del partner de forma segura (ajusta las llaves 'id' y 'name' según tu backend)
    final int partnerId = partner['id'] as int? ?? 0;
    final String partnerName = partner['name'] as String? ??
        partner['username'] as String? ??
        'Usuario';
    final String? partnerPhoto = partner['photo'] as String?;

    // 2. Extraemos el contenido y la fecha del último mensaje si existe
    final String lastMsgContent = lastMessage?.content ?? '';
    // Si no hay último mensaje, usamos la fecha actual por defecto (o una fecha base)
    final DateTime lastMsgAt = lastMessage != null
        ? DateTime.parse(lastMessage!.timestamp)
        : DateTime.now();

    return Conversation(
      partnerId: partnerId,
      partnerName: partnerName,
      partnerPhoto: partnerPhoto,
      lastMessage: lastMsgContent,
      lastMessageAt: lastMsgAt,
      unreadCount: unreadCount,
    );
  }
}

/// DTO Genérico para manejar respuestas paginadas del Backend (HU-17 - getHistory)
// En lib/data/dto/chat_dto.dart

/// DTO Genérico para manejar respuestas paginadas del Backend (HU-17 - getHistory)
class PagedResultDto<T> {
  final List<dynamic> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  PagedResultDto({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PagedResultDto.fromJson(Map<String, dynamic> json) {
    return PagedResultDto(
      content: json['content'] as List<dynamic>? ?? [],
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
    );
  }

  /// Transforma el contenedor paginado al PagedResult original de tu Dominio
  PagedResult<R> toDomain<R>(R Function(dynamic) itemMapper) {
    return PagedResult<R>(
      content: content.map(itemMapper).toList(),
      totalElements: totalElements,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }
}
