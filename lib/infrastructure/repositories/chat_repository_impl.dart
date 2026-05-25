// lib/infrastructure/repositories/chat_repository_impl.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../constants/api_config.dart';
import '../../domain/model/chat_message.dart';
import '../../domain/model/conversation.dart';
import '../../domain/model/paged_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/dto/chat_dto.dart';

class ChatRepositoryImpl implements ChatRepository {
  final http.Client _httpClient;
  final AuthRepository
      _authRepository; // <- Para recuperar el JWT local de forma limpia

  ChatRepositoryImpl({
    required AuthRepository authRepository,
    http.Client? httpClient,
  })  : _authRepository = authRepository,
        _httpClient = httpClient ?? http.Client();

  /// Helper privado para inyectar los headers comunes y el token JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepository.getStoredToken();
    if (token == null) {
      throw Exception('Usuario no autenticado. Token ausente.');
    }
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse(ApiConfig.conversations),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => ConversationDto.fromJson(json).toDomain())
            .toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Error al obtener las conversaciones');
      }
    } on SocketException {
      throw Exception(
          'Sin conexión a internet. No se pudieron cargar los chats.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      final headers = await _getHeaders();
      final bodyDto =
          SendMessageRequestDto(receiverId: receiverId, content: content);

      final response = await _httpClient.post(
        Uri.parse(ApiConfig.sendChatMessage), // <- Tu constante real
        headers: headers,
        body: jsonEncode(bodyDto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final messageDto = ChatMessageDto.fromJson(jsonDecode(response.body));
        return messageDto.toDomain();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'No se pudo enviar el mensaje');
      }
    } on SocketException {
      throw Exception('Error de red. El mensaje no pudo ser enviado.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagedResult<ChatMessage>> getHistory({
    required int partnerId,
    int page = 0,
    int size = 30,
  }) async {
    try {
      final headers = await _getHeaders();

      // Construimos la URI base usando tu método y le inyectamos los query params de paginación
      final uri = Uri.parse(ApiConfig.chatHistory(partnerId)).replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      final response = await _httpClient.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);

        // 1. Parseamos el JSON usando el DTO de paginación
        final pagedDto = PagedResultDto.fromJson(jsonMap);

        // 2. Mapeamos la lista interna de elementos dinámicos a ChatMessageDto y luego a Dominio
        final List<ChatMessage> domainMessages = pagedDto.content.map((item) {
          final dto = ChatMessageDto.fromJson(item as Map<String, dynamic>);
          return dto.toDomain();
        }).toList();

        // 3. Retornamos el PagedResult puro del dominio
        return PagedResult<ChatMessage>(
          content: domainMessages,
          totalElements: pagedDto.totalElements,
          totalPages: pagedDto.totalPages,
          currentPage: pagedDto.currentPage,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al cargar el historial');
      }
    } on SocketException {
      throw Exception('Error de red al recuperar el historial.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> markAsRead(int partnerId) async {
    try {
      final headers = await _getHeaders();

      // CAMBIA ESTA LÍNEA: Usa 'readChatMessages' en lugar de 'markAsRead'
      final url = ApiConfig.readChatMessages(partnerId);

      final response = await _httpClient.patch(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return jsonMap['count'] ?? 0;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ??
            'No se pudieron marcar los mensajes como leídos');
      }
    } on SocketException {
      throw Exception('Fallo de red al actualizar estado de lectura.');
    } catch (e) {
      rethrow;
    }
  }
}
