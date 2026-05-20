class ApiConfig {
  // 1. Configuración de Red Centralizada
  static const String _ip = '192.168.1.45';
  static const String baseUrl = 'http://$_ip:8080';

  // Cabeceras comunes reutilizables
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // =========================================================================
  // MÓDULO 1 y 2: Autenticación y Perfil de Usuario
  // =========================================================================
  static const String register = '$baseUrl/authenticate/register'; // HU-01
  static const String login    = '$baseUrl/authenticate/login';    // HU-02
  static const String ownProfile = '$baseUrl/users/me';            // HU-04 y HU-05

  /// HU-06: Perfil público de un emprendedor por ID
  static String entrepreneurProfile(int id) => '$baseUrl/users/entrepreneur/$id';


  // =========================================================================
  // MÓDULO 3 y 4: Gestión de Servicios, Búsqueda y Geolocalización
  // =========================================================================
  static const String services    = '$baseUrl/services';     // HU-08 y HU-13
  static const String servicesMap = '$baseUrl/services/map'; // HU-14

  /// HU-09, HU-10, HU-12: Operaciones sobre un servicio específico (Editar, Eliminar, Detalle)
  static String serviceDetail(int id) => '$baseUrl/services/$id';

  /// HU-11: Cambiar estado activo/inactivo de un servicio
  static String serviceStatus(int id) => '$baseUrl/services/$id/status';


  // =========================================================================
  // MÓDULO 5: Chat Privado
  // =========================================================================
  static const String conversations = '$baseUrl/chat/conversations'; // HU-16
  static const String sendChatMessage = '$baseUrl/chat/messages';     // HU-17

  /// HU-17: Obtener historial de mensajes con un usuario específico
  static String chatHistory(int partnerId) => '$baseUrl/chat/messages/$partnerId';

  /// HU-17: Marcar mensajes de una conversación como leídos
  static String readChatMessages(int partnerId) => '$baseUrl/chat/messages/read/$partnerId';


  // =========================================================================
  // MÓDULO 6: Calificaciones y Reseñas
  // =========================================================================
  static const String createReview = '$baseUrl/reviews'; // HU-18

  /// HU-19: Obtener listado de reseñas de un emprendedor
  static String entrepreneurReviews(int id) => '$baseUrl/reviews/entrepreneur/$id';

  /// HU-19 CA-2: Obtener resumen/distribución de calificaciones de un emprendedor
  static String entrepreneurReviewsSummary(int id) => '$baseUrl/reviews/entrepreneur/$id/summary';


  // =========================================================================
  // MÓDULO 7: Gestión de Imágenes
  // =========================================================================
  static const String uploadImage = '$baseUrl/images/upload'; // HU-20

  /// HU-20: Obtener o Eliminar una imagen del servidor por su nombre de archivo UUID
  static String imageUrl(String filename) => '$baseUrl/images/$filename';
}