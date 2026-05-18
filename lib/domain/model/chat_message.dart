// Un mensaje dentro del historial (HU-17).
class ChatMessage {
  final int id;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final bool isMine; // true si el usuario autenticado es el sender
  final int senderId;
  final int receiverId;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.isRead,
    required this.isMine,
    required this.senderId,
    required this.receiverId,
  });
}