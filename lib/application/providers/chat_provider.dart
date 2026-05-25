// lib/application/providers/chat_provider.dart

import 'package:flutter/material.dart';
import '../../domain/model/chat_message.dart';
import '../../domain/model/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatProvider({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  // Estados de la UI
  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  bool _isLoadingConversations = false;
  bool _isLoadingHistory = false;
  bool _isSending = false;

  // Getters públicos para que la UI los consuma
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSending => _isSending;

  /// HU-16: Cargar listado de conversaciones activas
  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      _conversations = await _chatRepository.getConversations();
    } catch (e) {
      debugPrint('Error en loadConversations: $e');
      rethrow;
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// HU-17: Cargar historial con un usuario específico
  Future<void> loadChatHistory(int partnerId, {int page = 0}) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final pagedResult = await _chatRepository.getHistory(
        partnerId: partnerId,
        page: page,
      );

      if (page == 0) {
        _messages = pagedResult.content;
      } else {
        _messages.addAll(pagedResult.content);
      }
    } catch (e) {
      debugPrint('Error en loadChatHistory: $e');
      rethrow;
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// HU-17: Enviar un mensaje nuevo
  Future<void> sendNewMessage({
    required int receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      // 1. Envía el mensaje al servidor a través del repositorio
      final sentMessage = await _chatRepository.sendMessage(
        receiverId: receiverId,
        content: content,
      );

      // 2. Lo agregamos al inicio de la lista local para actualizar la UI al instante
      _messages.insert(0, sentMessage);
    } catch (e) {
      debugPrint('Error en sendNewMessage: $e');
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// HU-17: Marcar mensajes como leídos
  Future<void> markMessagesAsRead(int partnerId) async {
    try {
      await _chatRepository.markAsRead(partnerId);
      // Opcional: Actualizar el contador local de no leídos de la conversación
      final index = _conversations.indexWhere((c) => c.partnerId == partnerId);
      if (index != -1) {
        // Asumiendo que tu modelo Conversation permite copias o modificaciones menores
        loadConversations(); // Refresca la lista global de conversaciones
      }
    } catch (e) {
      debugPrint('Error en markMessagesAsRead: $e');
    }
  }
}
