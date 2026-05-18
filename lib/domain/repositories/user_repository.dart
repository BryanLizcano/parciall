import 'package:parcial/domain/model/user.dart';

// Necesitamos importar el perfil público también
// (definido en shared_entities.dart, aquí usamos el nombre completo)

abstract interface class UserRepository {
  /// HU-04: perfil propio del usuario autenticado.
  Future<User> getOwnProfile();

  /// HU-05: actualiza campos opcionales del perfil.
  /// Los campos null no sobreescriben los existentes.
  Future<User> updateOwnProfile({
    String? fullName,
    String? photoUrl,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
  });

  /// HU-06: perfil público de un emprendedor por ID.
  /// Lanza excepción si el ID no existe o no es ENTREPRENEUR.
  Future<EntrepreneurPublicProfile> getEntrepreneurProfile(int id);
}

/// Perfil público separado para no mezclar con User autenticado.
class EntrepreneurPublicProfile {
  final int id;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? averageRating;
  final int totalReviews;

  const EntrepreneurPublicProfile({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.averageRating,
    required this.totalReviews,
  });
}