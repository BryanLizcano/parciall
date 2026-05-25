import '../model/user.dart';
import '../model/entrepreneur_profile.dart';

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
  Future<EntrepreneurProfile> getEntrepreneurProfile(int id);
}
