import '../../domain/model/role.dart';
import '../../domain/model/user.dart';

class UserDto {
  final int id;
  final String username;
  final String role;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  const UserDto({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      fullName: json['fullName'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      address: json['address'],
      // Nos aseguramos de parsear correctamente a double si el back manda num
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  User toDomain() {
    return User(
      id: id,
      username: username,
      role: role == 'ENTREPRENEUR' ? Role.entrepreneur : Role.client,
      fullName: fullName,
      photoUrl: photoUrl,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}