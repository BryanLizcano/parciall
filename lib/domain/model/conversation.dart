// Un ítem de la bandeja de chats (HU-16).
class Conversation {
  final int partnerId;
  final String partnerName;
  final String? partnerPhoto;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.partnerId,
    required this.partnerName,
    this.partnerPhoto,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });
}